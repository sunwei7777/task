import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';
import '../config/api_config.dart';
import 'storage_service.dart';

typedef WsMessageCallback = void Function(Map<String, dynamic> message);

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;

  WebSocketService._internal();

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  bool _disposed = false;

  final List<WsMessageCallback> _listeners = [];

  /// 连接 WebSocket
  Future<void> connect() async {
    final token = await StorageService.getToken();
    if (token == null || token.isEmpty) return;

    // 清理旧连接，防止重复调用导致泄漏
    _disposed = false;
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    _subscription?.cancel();
    _channel?.sink.close();

    try {
      final uri = Uri.parse('${ApiConfig.wsUrl}?token=$token');
      print(uri);
      _channel = WebSocketChannel.connect(uri);

      _subscription = _channel!.stream.listen(
        _onMessage,
        onError: (error) {
          print('WebSocket error: $error');
          _heartbeatTimer?.cancel();
          _scheduleReconnect();
        },
        onDone: () {
          print('WebSocket connection closed');
          _heartbeatTimer?.cancel();
          if (!_disposed) _scheduleReconnect();
        },
      );

      // 连接成功，启动心跳
      _startHeartbeat();
    } catch (e) {
      print('WebSocket connect failed: $e');
      _heartbeatTimer?.cancel();
      _scheduleReconnect();
    }
  }

  void _onMessage(dynamic data) {
    try {
      final json = jsonDecode(data as String) as Map<String, dynamic>;
      print("----------------------------");
      print(json);
      for (final cb in _listeners) {
        cb(json);
      }
    } catch (e) {
      print('WebSocket parse error: $e');
    }
  }

  /// 注册消息监听
  void addListener(WsMessageCallback callback) {
    if (!_listeners.contains(callback)) {
      _listeners.add(callback);
    }
  }

  /// 移除消息监听
  void removeListener(WsMessageCallback callback) {
    _listeners.remove(callback);
  }

  /// 断线重连（5秒后）
  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: 5), () {
      if (!_disposed) connect();
    });
  }

  /// 心跳（每30秒）
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_disposed || _channel == null) {
        _heartbeatTimer?.cancel();
        return;
      }
      try {
        final msg = jsonEncode({
          'category': 'heartbeat',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
        _channel!.sink.add(msg);
      } catch (e) {
        print('Heartbeat send failed: $e');
      }
    });
  }

  /// 断开连接
  void disconnect() {
    _disposed = true;
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    _subscription?.cancel();
    _channel?.sink.close();
    _listeners.clear();
  }
}
