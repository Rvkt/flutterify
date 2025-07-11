import 'dart:developer';

import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio = Dio();

  Future<Response> get(String path) async {
    try {
      return await _dio.get(path);
    } on DioException catch (e) {
      log(e.toString());
      throw Exception("API GET Error: ${e.message}");
    }
  }
}
