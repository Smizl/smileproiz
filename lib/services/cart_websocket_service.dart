import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class CartWebSocketService {
  WebSocketChannel? _channel;

  final StreamController<Map<String, dynamic>> _controller =
      StreamController.broadcast();

  Stream<Map<String, dynamic>> get stream => _controller.stream;

  int _reconnectAttempts = 0;
  bool _manuallyDisconnected = false;

  static const String _defaultHost = 'http://172.20.10.3:8080';
  static const String _hostKey = 'api_host';

  // -----------------------------
  // ✅ Получаем host динамически
  // -----------------------------
  Future<String> _getWsUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final host = prefs.getString(_hostKey) ?? _defaultHost;

    // http://192.168.1.7:8080 → ws://192.168.1.7:8080
    final wsHost = host.replaceFirst('http', 'ws');
    return '$wsHost/ws/cart';
  }

  Future<void> connect() async {
    _manuallyDisconnected = false;

    final url = await _getWsUrl();

    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
    } catch (e) {
      print('Ошибка подключения к WS: $e');
      _attemptReconnect();
      return;
    }

    _channel!.stream.listen(
      (event) {
        try {
          final data = jsonDecode(event);
          _controller.add(Map<String, dynamic>.from(data));
        } catch (e) {
          print('Ошибка декодирования WS-сообщения: $e');
        }
      },
      onError: (error) {
        print('WebSocket ошибка: $error');
        _attemptReconnect();
      },
      onDone: () {
        print('WebSocket закрыт.');
        _attemptReconnect();
      },
      cancelOnError: true,
    );

    _reconnectAttempts = 0;
    print('WebSocket подключен к $url');
  }

  void _attemptReconnect() {
    if (_manuallyDisconnected) return;

    _reconnectAttempts++;
    final seconds = _reconnectAttempts * 2;
    final delay = Duration(seconds: seconds > 10 ? 10 : seconds);

    print('Попытка переподключения через ${delay.inSeconds} секунд...');

    Future.delayed(delay, () async {
      if (!_manuallyDisconnected) {
        print('Переподключение...');
        await connect();
      }
    });
  }

  void disconnect() {
    _manuallyDisconnected = true;
    _channel?.sink.close();
    print('WebSocket вручную отключен.');
  }

  void send(Map<String, dynamic> message) {
    if (_channel != null) {
      try {
        _channel!.sink.add(jsonEncode(message));
      } catch (e) {
        print('Ошибка отправки WS-сообщения: $e');
      }
    } else {
      print('WebSocket не подключен. Сообщение не отправлено.');
    }
  }

  void dispose() {
    _controller.close();
    disconnect();
  }
}
