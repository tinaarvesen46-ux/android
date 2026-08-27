import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_config.dart';
import 'api_response.dart';

/// API Client for SwiftSnap
/// 
/// Handles all HTTP requests with authentication, error handling, and interceptors
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// In-memory cache of the current bearer token. Populated on every request
  /// and on login/logout so synchronous consumers (e.g. authed image loading
  /// for chat media) can attach the Authorization header without an await.
  static String? currentToken;

  // Storage keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  
  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.apiBaseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        sendTimeout: ApiConfig.sendTimeout,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
    
    _setupInterceptors();
  }
  
  void _setupInterceptors() {
    // Request interceptor - Add auth token to requests
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Handle 401 Unauthorized - Token expired
          if (error.response?.statusCode == 401) {
            // Try to refresh token
            final refreshed = await _refreshAccessToken();
            if (refreshed) {
              // Retry the request
              final options = error.requestOptions;
              final token = await getAccessToken();
              options.headers['Authorization'] = 'Bearer $token';
              
              try {
                final response = await _dio.fetch(options);
                return handler.resolve(response);
              } catch (e) {
                return handler.next(error);
              }
            } else {
              // Refresh failed, logout user
              await clearTokens();
              return handler.next(error);
            }
          }
          return handler.next(error);
        },
      ),
    );
    
    // Logging interceptor (disable in production)
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (obj) {
          // In production, replace with proper logging
          // ignore: avoid_print
          print(obj);
        },
      ),
    );
  }
  
  // Token management
  Future<String?> getAccessToken() async {
    final t = await _storage.read(key: _accessTokenKey);
    currentToken = t;
    return t;
  }
  
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }
  
  Future<void> setTokens(String accessToken, String refreshToken) async {
    currentToken = accessToken;
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }
  
  Future<void> clearTokens() async {
    currentToken = null;
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
  
  Future<bool> _refreshAccessToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) return false;
      
      final response = await _dio.post(
        ApiConfig.refreshToken,
        data: {'refresh_token': refreshToken},
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        await setTokens(
          data['access_token'],
          data['refresh_token'] ?? refreshToken,
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  // HTTP Methods
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return _handleError<T>(e);
    }
  }
  
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return _handleError<T>(e);
    }
  }
  
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return _handleError<T>(e);
    }
  }
  
  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return _handleError<T>(e);
    }
  }
  
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return _handleError<T>(e);
    }
  }
  
  // File upload
  Future<ApiResponse<T>> uploadFile<T>(
    String path,
    String filePath, {
    String fieldName = 'file',
    Map<String, dynamic>? additionalData,
    T Function(dynamic)? fromJson,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        ...?additionalData,
      });
      
      final response = await _dio.post(
        path,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
        onSendProgress: onSendProgress,
      );
      
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return _handleError<T>(e);
    }
  }
  
  // Response handling
  ApiResponse<T> _handleResponse<T>(
    Response response,
    T Function(dynamic)? fromJson,
  ) {
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      try {
        final data = response.data;
        T? result;
        
        if (fromJson != null && data != null) {
          // Unwrap Laravel pagination envelope {data:[...]} when present,
          // otherwise pass the raw payload (array or object) straight to the
          // service's parser, which is responsible for shaping it.
          dynamic payload = data;
          if (data is Map<String, dynamic> && data['data'] is List) {
            payload = data['data'];
          }
          result = fromJson(payload);
        }
        
        return ApiResponse.success(
          data: result,
          message: data is Map ? data['message'] as String? : null,
        );
      } catch (e) {
        return ApiResponse.error(
          message: 'Failed to parse response: $e',
          statusCode: response.statusCode,
        );
      }
    }
    
    return ApiResponse.error(
      message: 'Unexpected status code: ${response.statusCode}',
      statusCode: response.statusCode,
    );
  }
  
  // Error handling
  ApiResponse<T> _handleError<T>(DioException error) {
    String message;
    int? statusCode = error.response?.statusCode;
    
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.badResponse:
        message = _extractErrorMessage(error.response?.data);
        break;
      case DioExceptionType.cancel:
        message = 'Request cancelled';
        break;
      case DioExceptionType.connectionError:
        message = 'No internet connection';
        break;
      case DioExceptionType.badCertificate:
        message = 'Secure connection failed (certificate error). '
            'Please check your device date & time and try again.';
        break;
      default:
        // Surface the underlying cause so genuine device/TLS/socket errors
        // are diagnosable instead of a vague generic message.
        final underlying = error.message ?? error.error?.toString();
        message = (underlying != null && underlying.isNotEmpty)
            ? 'Network error: $underlying'
            : 'An unexpected error occurred';
    }
    
    return ApiResponse.error(
      message: message,
      statusCode: statusCode,
      errors: _extractErrors(error.response?.data),
    );
  }
  
  String _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      // Laravel validation error format
      if (data.containsKey('message')) {
        return data['message'] as String;
      }
      if (data.containsKey('error')) {
        return data['error'] as String;
      }
    }
    return 'An error occurred';
  }
  
  Map<String, List<String>>? _extractErrors(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('errors')) {
      final errors = data['errors'];
      if (errors is Map<String, dynamic>) {
        return errors.map((key, value) {
          if (value is List) {
            return MapEntry(key, value.cast<String>());
          }
          return MapEntry(key, [value.toString()]);
        });
      }
    }
    return null;
  }
}
