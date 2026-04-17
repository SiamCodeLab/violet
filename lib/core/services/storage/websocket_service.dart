import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart' as getx;
import 'package:get/get.dart';
import 'package:violet/core/const/api_endpoint.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:violet/core/services/storage/storage_service.dart';
import 'package:violet/core/utils/console.dart';

class WebSocketService extends getx.GetxService {
  // Singleton pattern
  static WebSocketService get to => Get.find();

  WebSocketChannel? _channel;
  StreamSubscription? _streamSubscription;

  // Callbacks for the Controller to listen to
  Function(String)? onMessage;
  Function()? onDone;
  Function(dynamic error)? onError;

  bool _isConnected = false;

  @override
  void onInit() {
    super.onInit();
    connect();
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }

  // ============================================
  // CONNECTION
  // ============================================

  void connect() {
    if (_isConnected) return;

    try {
      final token = StorageService.getAccessToken();
      if (token.isEmpty) {
        Console.error('Cannot connect WS: No token');
        return;
      }

      final uri = Uri.parse('${ApiEndpoint.wsChat}?token=$token');
      Console.info('Connecting to WebSocket: $uri');

      _channel = WebSocketChannel.connect(uri);
      _isConnected = true;

      _streamSubscription = _channel!.stream.listen(
        _handleIncomingData,
        onError: (error) {
          Console.error('WS Stream Error: $error');
          _isConnected = false;
          if (onError != null) onError!(error);
          _reconnect();
        },
        onDone: () {
          Console.error('WS Stream Closed');
          _isConnected = false;
          if (onDone != null) onDone!();
          _reconnect();
        },
        cancelOnError: false,
      );
    } catch (e) {
      Console.error('WS Connection Exception: $e');
      _isConnected = false;
      _reconnect();
    }
  }

  void disconnect() {
    _streamSubscription?.cancel();
    _channel?.sink.close();
    _isConnected = false;
  }

  void _reconnect() {
    // Prevent multiple reconnect loops
    Future.delayed(const Duration(seconds: 3), () {
      if (!_isConnected) {
        Console.info('Attempting to reconnect WebSocket...');
        connect();
      }
    });
  }

  // ============================================
  // DATA HANDLING
  // ============================================

  void _handleIncomingData(dynamic message) {
    // We pass the raw string/bytes to the controller via callback.
    // The controller will parse JSON to check for 'done' signals.
    // This keeps the service purely for transport.
    if (onMessage != null) {
      onMessage!(message.toString());
    }
  }

  // ============================================
  // SENDING
  // ============================================

  void sendMessage(Map<String, dynamic> payload) {
    if (_channel != null) {
      try {
        _channel!.sink.add(jsonEncode(payload));
      } catch (e) {
        Console.error('WS Send Error: $e');
      }
    } else {
      Console.error('WS is not connected. Message not sent.');
    }
  }
}
