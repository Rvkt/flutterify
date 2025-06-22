// This file handles API responses. It wraps responses into success or failure models.
// Example: class ApiResult<T> { Success<T> or Error<String> }

import 'failed_response.dart';

class ApiResult<T> {
  final T? success;
  final FailedResponse? error;

  ApiResult._({this.success, this.error});

  /// Factory constructor to ensure only one of success or error is provided.
  factory ApiResult.success(T success) {
    return ApiResult._(success: success);
  }

  factory ApiResult.error(FailedResponse error) {
    return ApiResult._(error: error);
  }

  bool get isSuccess => success != null;

  factory ApiResult.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    if (json.containsKey('error')) {
      return ApiResult<T>.error(FailedResponse.fromJson(json['error']));
    } else {
      return ApiResult<T>.success(fromJsonT(json['success']));
    }
  }

  Map<String, dynamic> toJson() {
    return success != null ? {'success': success} : {'error': error?.toJson()};
  }
}
