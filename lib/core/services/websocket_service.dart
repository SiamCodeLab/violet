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
  
  // Timer variable for handling retries
  Timer? _retryTimer;

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
    // Cancel the retry timer when service is disposed to prevent memory leaks
    _retryTimer?.cancel();
    disconnect();
    super.onClose();
  }

  // ============================================
  // CONNECTION
  // ============================================

  void connect() {
    // If already connected, do nothing
    if (_isConnected) return;

    try {
      final token = StorageService.getAccessToken();

      // CHANGE: If token is empty, retry every 1 second instead of returning
      if (token.isEmpty) {
        Console.error('WS Token missing. Retrying in 1 second...');
        
        // Cancel any existing retry timer to avoid stacking multiple timers
        _retryTimer?.cancel();
        
        // Schedule a retry
        _retryTimer = Timer(const Duration(seconds: 1), () {
          // Double check if service is still registered and not connected
          // This prevents attempting to connect if the widget/service was disposed
          if (Get.isRegistered<WebSocketService>() && !_isConnected) {
            connect();
          }
        });
        
        return; 
      }

      final uri = Uri.parse('${ApiEndpoint.wsChat}?token=$token');
      Console.info('Connecting to WebSocket: $uri');

      _channel = WebSocketChannel.connect(uri);
      _isConnected = true;

      // Cancel retry timer once connection is initiated successfully
      _retryTimer?.cancel();

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
    _retryTimer?.cancel(); // Stop any pending retries
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