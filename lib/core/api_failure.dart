import 'package:dio/dio.dart';

/// A backend or transport failure translated into copy that is safe to show
/// directly in the interface.
class ApiFailure implements Exception {
  final String message;
  final int? statusCode;

  const ApiFailure(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Wraps every repository call so no raw [DioException] reaches the provider
/// or UI layer.
Future<T> guardApi<T>(Future<T> Function() action) async {
  try {
    return await action();
  } on ApiFailure {
    rethrow;
  } on DioException catch (e) {
    throw ApiFailure(_describe(e), statusCode: e.response?.statusCode);
  } catch (_) {
    throw const ApiFailure('Something went wrong. Please try again.');
  }
}

String _describe(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return 'The server took too long to respond. Check your connection and retry.';
    case DioExceptionType.connectionError:
    case DioExceptionType.unknown:
      return 'SwiftSnap could not reach the server. Check your connection and retry.';
    case DioExceptionType.cancel:
      return 'The request was cancelled.';
    case DioExceptionType.badCertificate:
      return 'The server certificate could not be verified.';
    case DioExceptionType.badResponse:
      return _describeResponse(e.response);
  }
}

String _describeResponse(Response<dynamic>? response) {
  final status = response?.statusCode ?? 0;
  final data = response?.data;

  // Laravel returns { message, errors? } for validation and auth failures.
  if (data is Map) {
    final errors = data['errors'];
    if (errors is Map && errors.isNotEmpty) {
      final first = errors.values.first;
      if (first is List && first.isNotEmpty) return '${first.first}';
      if (first is String) return first;
    }
    final message = data['message'];
    if (message is String && message.trim().isNotEmpty) return message;
  }

  switch (status) {
    case 401:
    case 419:
      return 'Your session has expired. Please sign in again.';
    case 403:
      return 'You do not have access to this.';
    case 404:
      return 'This is not available on the server yet.';
    case 422:
      return 'Some of the details entered are not valid.';
    case 429:
      return 'Too many attempts. Please wait a moment and retry.';
    default:
      if (status >= 500) {
        return 'The server reported an error. Please retry shortly.';
      }
      return 'The request could not be completed.';
  }
}
