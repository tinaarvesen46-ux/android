/// API Response wrapper for consistent response handling
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;
  final Map<String, List<String>>? errors;
  
  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
    this.errors,
  });
  
  factory ApiResponse.success({
    T? data,
    String? message,
    int? statusCode,
  }) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message ?? 'Success',
      statusCode: statusCode ?? 200,
    );
  }
  
  factory ApiResponse.error({
    String? message,
    int? statusCode,
    Map<String, List<String>>? errors,
  }) {
    return ApiResponse<T>(
      success: false,
      message: message ?? 'An error occurred',
      statusCode: statusCode,
      errors: errors,
    );
  }
  
  bool get isSuccess => success;
  bool get isError => !success;
  
  String get errorMessage => message ?? 'Unknown error';
  
  List<String> getFieldErrors(String field) {
    return errors?[field] ?? [];
  }
  
  String? getFirstFieldError(String field) {
    final fieldErrors = getFieldErrors(field);
    return fieldErrors.isNotEmpty ? fieldErrors.first : null;
  }
}
