import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// A single [http.Client] that logs every request and its response.
///
/// Every call goes through [send], including `MultipartRequest`, so adding a
/// new endpoint needs no extra logging — use `apiClient.get(...)` in place of
/// `http.get(...)` and the request shows up automatically.
///
/// Bodies are only logged in debug builds: they contain access tokens, OTPs and
/// personal data that should never reach a release log.
class LoggingClient extends http.BaseClient {
  LoggingClient(this._inner);

  final http.Client _inner;

  /// Responses longer than this are truncated so one big list response cannot
  /// bury everything else in the console.
  static const int _maxBodyLog = 4000;

  int _counter = 0;

  /// Invoked once when an authenticated request comes back 401, i.e. the
  /// access token expired or was revoked. Wired up in main.dart so this file
  /// stays free of UI and navigation.
  ///
  /// Handling it here rather than in each provider means every endpoint is
  /// covered, including ones added later.
  void Function()? onUnauthorized;

  bool _handlingUnauthorized = false;

  /// Endpoints reachable while logged out. A 401 from these is a normal
  /// failure, not an expired session, so it must not sign the user out.
  static const List<String> _publicPaths = [
    '/user/login',
    '/user/register',
    '/user/verify-account',
    '/user/verify-login',
    '/user/resend-otp',
  ];

  bool _isPublic(Uri url) =>
      _publicPaths.any((path) => url.path.endsWith(path));

  static const String _refreshPath = '/user/refresh-token';

  bool _isRefresh(Uri url) => url.path.endsWith(_refreshPath);

  /// The in-flight refresh, shared by every request that got a 401 at the same
  /// moment. Without this they would each refresh in parallel and invalidate
  /// one another's tokens.
  Future<String?>? _refreshInFlight;

  Future<String?> _refreshAccessToken(Uri origin) {
    _refreshInFlight ??= _performRefresh(origin).whenComplete(() {
      _refreshInFlight = null;
    });
    return _refreshInFlight!;
  }

  /// Exchanges the stored refresh token for a new access token. Goes straight
  /// to the inner client so it cannot recurse back through [send].
  /// Returns the new access token, or null if the refresh itself failed.
  Future<String?> _performRefresh(Uri origin) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? refreshToken = prefs.getString('refreshToken');
      if (refreshToken == null || refreshToken.isEmpty) return null;

      final request = http.Request(
        'POST',
        Uri.parse('${origin.origin}$_refreshPath'),
      )
        ..headers['Content-Type'] = 'application/json'
        ..headers['accept'] = 'application/json'
        ..body = jsonEncode({'refreshToken': refreshToken});

      final streamed = await _inner.send(request);
      final body = await streamed.stream.bytesToString();
      if (streamed.statusCode != 200 && streamed.statusCode != 201) {
        if (kDebugMode) print('!! token refresh failed: ${streamed.statusCode} $body');
        return null;
      }

      final Map<String, dynamic> json = jsonDecode(body);
      final String? accessToken = json['accessToken'];
      if (accessToken == null) return null;

      await prefs.setString('accessToken', accessToken);
      // The API rotates the refresh token too; keeping the old one would make
      // the next refresh fail.
      final String? newRefresh = json['refreshToken'];
      if (newRefresh != null) await prefs.setString('refreshToken', newRefresh);

      if (kDebugMode) print('   token refreshed');
      return accessToken;
    } catch (error) {
      if (kDebugMode) print('!! token refresh error: $error');
      return null;
    }
  }

  /// Only a plain [http.Request] can be rebuilt and sent again — a multipart
  /// body is a consumed stream by this point, so those are not retried.
  http.BaseRequest? _rebuild(http.BaseRequest original, String accessToken) {
    if (original is! http.Request) return null;
    final copy = http.Request(original.method, original.url)
      ..headers.addAll(original.headers)
      ..bodyBytes = original.bodyBytes
      ..followRedirects = original.followRedirects
      ..maxRedirects = original.maxRedirects
      ..persistentConnection = original.persistentConnection;
    copy.headers['Authorization'] = 'Bearer $accessToken';
    return copy;
  }

  void _handleUnauthorized(Uri url) {
    if (_isPublic(url) || onUnauthorized == null) return;
    // Several screens can fire requests at once; only react to the first 401
    // so the user is not shown the message repeatedly.
    if (_handlingUnauthorized) return;
    _handlingUnauthorized = true;
    onUnauthorized!.call();
    Future.delayed(const Duration(seconds: 5), () {
      _handlingUnauthorized = false;
    });
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final int id = ++_counter;
    final Stopwatch stopwatch = Stopwatch()..start();

    if (kDebugMode) {
      print('┌── #$id ${request.method} ${request.url}');
      final String? body = _requestBody(request);
      if (body != null && body.isNotEmpty) {
        print('│   body: ${_redact(body)}');
      }
    }

    try {
      http.StreamedResponse response = await _inner.send(request);
      stopwatch.stop();

      // An expired access token is recoverable: swap it for a fresh one and
      // replay the request, so the user never notices. Only sign them out if
      // the refresh itself fails.
      if (response.statusCode == 401 &&
          !_isPublic(request.url) &&
          !_isRefresh(request.url)) {
        final String? accessToken = await _refreshAccessToken(request.url);
        final http.BaseRequest? retry =
            accessToken == null ? null : _rebuild(request, accessToken);
        if (retry != null) {
          if (kDebugMode) print('   #$id retrying with refreshed token');
          response = await _inner.send(retry);
        } else {
          _handleUnauthorized(request.url);
        }
      }

      if (!kDebugMode) return response;

      // The stream can only be read once, so buffer it and hand back a fresh
      // StreamedResponse for the caller to read as normal.
      final List<int> bytes = await response.stream.toBytes();
      print(
        '└── #$id ${response.statusCode} ${request.method} ${request.url.path}'
        ' (${stopwatch.elapsedMilliseconds}ms)',
      );
      print('    ${_truncate(utf8.decode(bytes, allowMalformed: true))}');

      return http.StreamedResponse(
        Stream.value(bytes),
        response.statusCode,
        contentLength: response.contentLength,
        request: response.request,
        headers: response.headers,
        isRedirect: response.isRedirect,
        persistentConnection: response.persistentConnection,
        reasonPhrase: response.reasonPhrase,
      );
    } catch (error) {
      stopwatch.stop();
      if (kDebugMode) {
        print(
          '└── #$id FAILED ${request.method} ${request.url}'
          ' (${stopwatch.elapsedMilliseconds}ms): $error',
        );
      }
      rethrow;
    }
  }

  String? _requestBody(http.BaseRequest request) {
    if (request is http.Request) return request.body;
    if (request is http.MultipartRequest) {
      final String fields = jsonEncode(request.fields);
      final String files =
          request.files.map((f) => '${f.field}=${f.filename} (${f.length}b)').join(', ');
      return 'fields: $fields${files.isEmpty ? '' : ' | files: $files'}';
    }
    return null;
  }

  /// Keeps one-time codes out of the log even in debug — they are the one thing
  /// worth not leaving lying around in a shared console.
  String _redact(String body) =>
      body.replaceAllMapped(RegExp(r'("otp"\s*:\s*")([^"]*)(")'), (m) => '${m[1]}••••${m[3]}');

  String _truncate(String body) => body.length <= _maxBodyLog
      ? body
      : '${body.substring(0, _maxBodyLog)}… [${body.length} chars total]';

  @override
  void close() => _inner.close();
}

/// The client every provider should use.
final LoggingClient apiClient = LoggingClient(http.Client());
