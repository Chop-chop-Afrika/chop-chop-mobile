import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../env/env.dart';

/// A single socket.io connection for the logged-in user, per the realtime docs
/// at /socket/docs. There is nothing to subscribe to and no room to join — the
/// server routes each event to the right people.
///
/// Events are best effort and never replayed, so every screen that listens must
/// also refetch from REST when [onReconnect] fires.
class SocketService {
  SocketService._internal();

  static final SocketService instance = SocketService._internal();

  io.Socket? _socket;

  /// order-status-update — an order moved to a new step.
  final List<void Function(OrderStatusEvent)> _orderStatusListeners = [];

  /// package-status-update — a package delivery moved to a new step.
  final List<void Function(PackageStatusEvent)> _packageStatusListeners = [];

  /// rider-location-update — where the rider is now, and the ETA.
  final List<void Function(RiderLocationEvent)> _riderLocationListeners = [];

  /// Fired after a reconnect so screens can refetch; events are not replayed.
  final List<void Function()> _reconnectListeners = [];

  bool get isConnected => _socket?.connected ?? false;

  /// Connects using the stored access token. Safe to call repeatedly — an
  /// existing live connection is reused, since the server allows one per user.
  Future<void> connect() async {
    if (_socket != null && _socket!.connected) return;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('accessToken');
    if (token == null) {
      print('Socket: not logged in, skipping connect');
      return;
    }

    _socket?.dispose();

    _socket = io.io(
      Env.BACKEND_URL,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .enableReconnection()
          .enableForceNew()
          // Connect explicitly below, once the listeners are attached, so no
          // event can arrive before anything is listening.
          .disableAutoConnect()
          .build(),
    );

    _socket!.onConnect((_) => print('Socket connected'));

    // The server disconnects the socket the moment the token expires, so a
    // reconnect has to pick up whatever token is current.
    _socket!.onDisconnect((reason) => print('Socket disconnected: $reason'));
    _socket!.onConnectError((e) => print('Socket connect error: $e'));

    _socket!.onReconnect((_) {
      print('Socket reconnected, screens should refetch');
      for (final listener in List.of(_reconnectListeners)) {
        listener();
      }
    });

    _socket!.on('order-status-update', (data) {
      if (data is! Map) return;
      final event = OrderStatusEvent.fromJson(Map<String, dynamic>.from(data));
      print('order-status-update: ${event.orderId} -> ${event.phase}');
      for (final listener in List.of(_orderStatusListeners)) {
        listener(event);
      }
    });

    _socket!.on('package-status-update', (data) {
      if (data is! Map) return;
      final event = PackageStatusEvent.fromJson(Map<String, dynamic>.from(data));
      print('package-status-update: ${event.packageId} -> ${event.phase}');
      for (final listener in List.of(_packageStatusListeners)) {
        listener(event);
      }
    });

    _socket!.on('rider-location-update', (data) {
      if (data is! Map) return;
      final event = RiderLocationEvent.fromJson(Map<String, dynamic>.from(data));
      for (final listener in List.of(_riderLocationListeners)) {
        listener(event);
      }
    });

    _socket!.connect();
  }

  /// Reconnects with the current token. Call after a token refresh.
  Future<void> reconnect() async {
    _socket?.dispose();
    _socket = null;
    await connect();
  }

  void disconnect() {
    _socket?.dispose();
    _socket = null;
  }

  void addOrderStatusListener(void Function(OrderStatusEvent) listener) =>
      _orderStatusListeners.add(listener);

  void removeOrderStatusListener(void Function(OrderStatusEvent) listener) =>
      _orderStatusListeners.remove(listener);

  void addPackageStatusListener(void Function(PackageStatusEvent) listener) =>
      _packageStatusListeners.add(listener);

  void removePackageStatusListener(void Function(PackageStatusEvent) listener) =>
      _packageStatusListeners.remove(listener);

  void addRiderLocationListener(void Function(RiderLocationEvent) listener) =>
      _riderLocationListeners.add(listener);

  void removeRiderLocationListener(void Function(RiderLocationEvent) listener) =>
      _riderLocationListeners.remove(listener);

  void addReconnectListener(void Function() listener) =>
      _reconnectListeners.add(listener);

  void removeReconnectListener(void Function() listener) =>
      _reconnectListeners.remove(listener);

  /// Explicit room join. Not normally needed — the server adds the customer to
  /// an order's room automatically when it is paid, confirmed or assigned.
  void joinOrderRoom(String orderId, {void Function(bool joined)? onResult}) {
    _socket?.emitWithAck(
      'joinOrderRoom',
      {'orderId': orderId},
      ack: (dynamic res) {
        final bool ok = res is Map && res['status'] == true;
        if (!ok) print('joinOrderRoom refused: $res');
        onResult?.call(ok);
      },
    );
  }
}

class OrderStatusEvent {
  final String? orderId;
  final int? status;
  final String? statusText;
  final String? phase;
  final DateTime? at;

  OrderStatusEvent({
    this.orderId,
    this.status,
    this.statusText,
    this.phase,
    this.at,
  });

  factory OrderStatusEvent.fromJson(Map<String, dynamic> json) {
    return OrderStatusEvent(
      orderId: json['orderId'],
      status: json['status'] is num ? (json['status'] as num).toInt() : null,
      statusText: json['statusText'],
      phase: json['phase'],
      at: json['at'] != null ? DateTime.tryParse(json['at']) : null,
    );
  }
}

/// package-status-update. Packages use the same tracking phases as orders but
/// their own status codes: 1 paid/waiting · 2 rider accepted or in transit ·
/// 3 delivered · 4 canceled · 5 delivery failed.
class PackageStatusEvent {
  final String? packageId;
  final int? status;
  final String? phase;
  final DateTime? at;

  PackageStatusEvent({this.packageId, this.status, this.phase, this.at});

  factory PackageStatusEvent.fromJson(Map<String, dynamic> json) {
    return PackageStatusEvent(
      packageId: json['packageId'],
      status: json['status'] is num ? (json['status'] as num).toInt() : null,
      phase: json['phase'],
      at: json['at'] != null ? DateTime.tryParse(json['at']) : null,
    );
  }
}

class RiderLocationEvent {
  final String? orderId;
  final String? packageId;
  final double? lat;
  final double? lng;

  /// to_vendor = heading to the store; to_customer = heading to the drop-off.
  final String? leg;
  final int? distanceMeters;
  final int? etaMinutes;

  /// google = driving time from Maps; estimate = straight-line fallback, so
  /// the ETA should be shown as approximate.
  final String? source;
  final DateTime? updatedAt;

  RiderLocationEvent({
    this.orderId,
    this.packageId,
    this.lat,
    this.lng,
    this.leg,
    this.distanceMeters,
    this.etaMinutes,
    this.source,
    this.updatedAt,
  });

  factory RiderLocationEvent.fromJson(Map<String, dynamic> json) {
    return RiderLocationEvent(
      orderId: json['orderId'],
      packageId: json['packageId'],
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      leg: json['leg'],
      distanceMeters: (json['distanceMeters'] as num?)?.toInt(),
      etaMinutes: (json['etaMinutes'] as num?)?.toInt(),
      source: json['source'],
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  bool get isEstimate => source == 'estimate';
}
