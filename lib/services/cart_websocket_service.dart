import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class CartWebSocketService {
  WebSocketChannel? _channel;

  final StreamController<Map<String, dynamic>> _controller =
      StreamController.broadcast();

  Stream<Map<String, dynamic>> get stream => _controller.stream;

  int _reconnectAttempts = 0;
  bool _manuallyDisconnected = false;

  final String _url;

  CartWebSocketService({String url = 'ws://172.20.10.3:8080/ws/cart'})
    : _url = url;

  void connect() {
    _manuallyDisconnected = false;

    try {
      _channel = WebSocketChannel.connect(Uri.parse(_url));
    } catch (e) {
      print('Ошибка подключения к WS: $e');
      _attemptReconnect();
      return;
    }

    _channel!.stream.listen(
      (event) {
        try {
          final data = jsonDecode(event);
          _controller.add(data);
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

    _reconnectAttempts = 0; // Сброс попыток при успешном подключении
    print('WebSocket подключен к $_url');
  }

  void _attemptReconnect() {
    if (_manuallyDisconnected) return;

    _reconnectAttempts++;
    final seconds = _reconnectAttempts * 2;
    final delay = Duration(seconds: seconds > 10 ? 10 : seconds);

    print('Попытка переподключения через ${delay.inSeconds} секунд...');
    Future.delayed(delay, () {
      if (!_manuallyDisconnected) {
        print('Переподключение...');
        connect();
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
}
