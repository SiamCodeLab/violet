import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:violet/core/services/snackbar_service.dart';
import 'package:violet/core/services/storage/storage_service.dart';
import 'package:violet/core/utils/console.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// API RESPONSE WRAPPER
/// ═══════════════════════════════════════════════════════════════════════════
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    required this.statusCode,
  });

  @override
  String toString() {
    return 'ApiResponse(success: $success, statusCode: $statusCode, message: $message)';
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// API SERVICE
/// Centralized HTTP client for all API requests
/// ═══════════════════════════════════════════════════════════════════════════
class ApiService {
  // ─────────────────────────────────────────────────────────────────────────
  // Timeout Duration
  // ─────────────────────────────────────────────────────────────────────────

  static const Duration _timeout = Duration(seconds: 30);

  // ─────────────────────────────────────────────────────────────────────────
  // Headers
  // ─────────────────────────────────────────────────────────────────────────

  /// Default headers (no auth)
  static Map<String, String> get _defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Headers with authentication
  static Map<String, String> get _authHeaders => {
    ..._defaultHeaders,
    'Authorization': 'Bearer ${StorageService.getAccessToken()}',
  };

  /// Multipart headers with authentication
  static Map<String, String> get _multipartAuthHeaders => {
    'Authorization': 'Bearer ${StorageService.getAccessToken()}',
  };

  // ─────────────────────────────────────────────────────────────────────────
  // GET Requests
  // ─────────────────────────────────────────────────────────────────────────

  /// GET request without authentication
  static Future<ApiResponse<dynamic>> get(
    String url, {
    Map<String, String>? queryParams,
  }) async {
    try {
      Uri uri = Uri.parse(url);
      if (queryParams != null) {
        uri = uri.replace(queryParameters: queryParams);
      }

      Console.api('GET: $uri');
      final response = await http
          .get(uri, headers: _defaultHeaders)
          .timeout(_timeout);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// GET request with authentication
  static Future<ApiResponse<dynamic>> getAuth(
    String url, {
    Map<String, String>? queryParams,
  }) async {
    try {
      Uri uri = Uri.parse(url);
      if (queryParams != null) {
        uri = uri.replace(queryParameters: queryParams);
      }

      Console.api('GET (Auth): $uri');
      final response = await http
          .get(uri, headers: _authHeaders)
          .timeout(_timeout);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // POST Requests
  // ─────────────────────────────────────────────────────────────────────────

  /// POST request without authentication
  static Future<ApiResponse<dynamic>> post(
    String url, {
    Map<String, dynamic>? body,
  }) async {
    try {
      Console.api('POST: $url');
      Console.debug('Body: $body');

      final response = await http
          .post(
            Uri.parse(url),
            headers: _defaultHeaders,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// POST request with authentication
  static Future<ApiResponse<dynamic>> postAuth(
    String url, {
    Map<String, dynamic>? body,
  }) async {
    try {
      Console.api('POST (Auth): $url');
      Console.debug('Body: $body');

      final response = await http
          .post(
            Uri.parse(url),
            headers: _authHeaders,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// POST form data (for login/signup - no JSON encoding)
  static Future<ApiResponse<dynamic>> postForm(
    String url, {
    required Map<String, String> body,
  }) async {
    try {
      Console.api('POST Form: $url');
      Console.debug('Body: $body');

      final response = await http
          .post(Uri.parse(url), body: body)
          .timeout(_timeout);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// POST form data with authentication
  static Future<ApiResponse<dynamic>> postFormAuth(
    String url, {
    required Map<String, String> body,
  }) async {
    try {
      Console.api('POST Form (Auth): $url');

      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer ${StorageService.getAccessToken()}',
            },
            body: body,
          )
          .timeout(_timeout);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PUT/PATCH Requests
  // ─────────────────────────────────────────────────────────────────────────

  /// PATCH request with authentication
  static Future<ApiResponse<dynamic>> patchAuth(
    String url, {
    Map<String, dynamic>? body,
  }) async {
    try {
      Console.api('PATCH (Auth): $url');

      final response = await http
          .patch(
            Uri.parse(url),
            headers: _authHeaders,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// PUT request with authentication
  static Future<ApiResponse<dynamic>> putAuth(
    String url, {
    Map<String, dynamic>? body,
  }) async {
    try {
      Console.api('PUT (Auth): $url');

      final response = await http
          .put(
            Uri.parse(url),
            headers: _authHeaders,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DELETE Requests
  // ─────────────────────────────────────────────────────────────────────────

  /// DELETE request with authentication
  static Future<ApiResponse<dynamic>> deleteAuth(
    String url, {
    Map<String, dynamic>? body,
  }) async {
    try {
      Console.api('DELETE (Auth): $url');

      final http.Response response;

      if (body != null) {
        // With body
        response = await http
            .delete(
              Uri.parse(url),
              headers: _authHeaders,
              body: jsonEncode(body),
            )
            .timeout(_timeout);
      } else {
        // Without body
        response = await http
            .delete(Uri.parse(url), headers: _authHeaders)
            .timeout(_timeout);
      }

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Multipart/File Upload
  // ─────────────────────────────────────────────────────────────────────────

  /// Upload files with multipart request
  static Future<ApiResponse<dynamic>> uploadMultipart({
    required String url,
    required String method, // 'POST' or 'PATCH'
    Map<String, String>? fields,
    Map<String, File>? files,
  }) async {
    try {
      Console.api('$method Multipart: $url');

      var request = http.MultipartRequest(method, Uri.parse(url));
      request.headers.addAll(_multipartAuthHeaders);

      // Add text fields
      if (fields != null) {
        request.fields.addAll(fields);
        Console.debug('Fields: $fields');
      }

      // Add files
      if (files != null) {
        for (var entry in files.entries) {
          request.files.add(
            await http.MultipartFile.fromPath(entry.key, entry.value.path),
          );
          Console.debug('File: ${entry.key} -> ${entry.value.path}');
        }
      }

      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Response Handling
  // ─────────────────────────────────────────────────────────────────────────

  static ApiResponse<dynamic> _handleResponse(http.Response response) {
    Console.api('Status: ${response.statusCode}');

    final statusCode = response.statusCode;
    dynamic data;

    try {
      if (response.body.isNotEmpty) {
        data = jsonDecode(response.body);
      }
    } catch (e) {
      data = response.body;
    }

    // Success responses (2xx)
    if (statusCode >= 200 && statusCode < 300) {
      Console.success('API Success');
      return ApiResponse(success: true, data: data, statusCode: statusCode);
    }

    // Error responses
    String message = 'Request failed';
    if (data is Map) {
      message =
          data['message'] ??
          data['detail'] ??
          data['error'] ??
          'Request failed';
    }

    Console.error('API Error: $message');

    return ApiResponse(
      success: false,
      data: data,
      message: message,
      statusCode: statusCode,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Error Handling
  // ─────────────────────────────────────────────────────────────────────────

  static ApiResponse<dynamic> _handleError(dynamic error) {
    Console.error('API Exception: $error');

    String message = 'Something went wrong';

    if (error is SocketException) {
      message = 'No internet connection';
    } else if (error is TimeoutException) {
      message = 'Server not responding. Please try again.';
    } else if (error is FormatException) {
      message = 'Invalid response format';
    } else if (error is HttpException) {
      message = 'Server error';
    }

    // Show snackbar error
    SnackbarService.error(message);

    return ApiResponse(success: false, message: message, statusCode: 0);
  }
}
