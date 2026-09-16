import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../env/env.dart';

/// Handles messages that arrive while the app is in the background or fully
/// closed. It runs in its own isolate, so Firebase has to be started again here
/// and nothing from the running app is available.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Background message received: ${message.messageId}');
}

class NotificationService {
  NotificationService._internal();

  static final NotificationService instance = NotificationService._internal();

  /// Android needs an explicit channel for heads-up notifications. The id must
  /// match the `default_notification_channel_id` meta-data in AndroidManifest.xml
  /// so that notifications sent while the app is closed land in the same place.
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'chop_chop_high_importance',
    'General Notifications',
    description: 'Order, delivery and package updates from Chop Chop Africa.',
    importance: Importance.high,
  );

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;

  /// The device's current FCM token, or null if it hasn't been fetched yet.
  String? get fcmToken => _fcmToken;

  /// Called when the user taps a notification. Set this from the UI layer to
  /// route the user to the right screen.
  void Function(RemoteMessage message)? onNotificationTapped;

  bool _initialized = false;

  /// Sets up permissions, the local notification channel and every message
  /// listener. Safe to call more than once. Call this after Firebase.initializeApp().
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      await _requestPermission();
      await _setUpLocalNotifications();

      // Show foreground notifications on iOS the same way the system does when
      // the app is closed. On Android this is handled by _localNotifications.
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      await getFcmToken();

      // Firebase rotates the token on reinstall, restore and app data clearing.
      _messaging.onTokenRefresh.listen((String token) async {
        print('FCM token refreshed');
        _fcmToken = token;
        await _cacheToken(token);
        await registerTokenWithBackend();
      });

      // App is open and in the foreground.
      FirebaseMessaging.onMessage.listen(_showLocalNotification);

      // App was in the background and the user tapped the notification.
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('Notification opened from background: ${message.messageId}');
        onNotificationTapped?.call(message);
      });

      // App was fully closed and was launched by tapping the notification.
      final RemoteMessage? initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        print('App launched from notification: ${initialMessage.messageId}');
        onNotificationTapped?.call(initialMessage);
      }
    } catch (error) {
      print('Notification setup error: $error');
    }
  }

  Future<void> _requestPermission() async {
    final NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('Notification permission: ${settings.authorizationStatus}');
  }

  Future<void> _setUpLocalNotifications() async {
    const InitializationSettings settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        // firebase_messaging already asked for these above.
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _localNotifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final String? payload = response.payload;
        if (payload == null || payload.isEmpty) return;
        try {
          final Map<String, dynamic> data =
              Map<String, dynamic>.from(jsonDecode(payload));
          onNotificationTapped?.call(RemoteMessage(data: data));
        } catch (error) {
          print('Could not read notification payload: $error');
        }
      },
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  void _showLocalNotification(RemoteMessage message) {
    print('Foreground message received: ${message.messageId}');
    final RemoteNotification? notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }

  /// Fetches the device's FCM token and caches it. Returns null if it can't be
  /// fetched, which happens on iOS when APNs hasn't registered the device yet.
  Future<String?> getFcmToken() async {
    try {
      if (Platform.isIOS) {
        // On iOS the FCM token isn't available until APNs hands one over.
        final String? apnsToken = await _messaging.getAPNSToken();
        if (apnsToken == null) {
          print('APNS token not ready yet, retrying once');
          await Future.delayed(const Duration(seconds: 3));
          if (await _messaging.getAPNSToken() == null) {
            print('APNS token unavailable, skipping FCM token fetch');
            return null;
          }
        }
      }

      final String? token = await _messaging.getToken();
      if (token == null) {
        print('FCM token was null');
        return null;
      }

      _fcmToken = token;
      await _cacheToken(token);
      print('FCM token: $token');
      return token;
    } catch (error) {
      print('Error getting FCM token: $error');
      return null;
    }
  }

  Future<void> _cacheToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcmToken', token);
  }

  /// Sends the token to the backend so it can target this device. Requires the
  /// user to be logged in; call it right after a successful verification and on
  /// app start for an already logged-in user.
  Future<bool> registerTokenWithBackend() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? accessToken = prefs.getString('accessToken');
    if (accessToken == null) {
      print('Not logged in, skipping device token registration');
      return false;
    }

    final String? token = _fcmToken ?? await getFcmToken();
    if (token == null) return false;

    try {
      final String url = "${Env.BACKEND_URL}/user/device-token";
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': "Bearer $accessToken",
        },
        body: jsonEncode({
          "device_token": token,
          "platform": Platform.isIOS ? "ios" : "android",
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Device token registered');
        return true;
      }

      print('Device token registration failed: ${response.statusCode} ${response.body}');
      return false;
    } catch (error) {
      print('Device token registration error: $error');
      return false;
    }
  }

  /// Clears the token so a logged-out device stops receiving notifications.
  /// Call this during logout.
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      _fcmToken = null;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('fcmToken');
      print('FCM token deleted');
    } catch (error) {
      print('Error deleting FCM token: $error');
    }
  }
}
