// This file contains functions that call api_client and use defined endpoints.
// It acts like a bridge between UI/business logic and the actual api call.

import 'dart:developer';

import 'package:flutterify/features/products/data/models/product_model.dart';

import '../client/api_client.dart';
import '../handler/api_handler.dart';
import '../handler/failed_response.dart';

class ApiService {
  final ApiClient _client = ApiClient();

  // Future<ApiResult<List<Product>>> getAllProducts() async {
  //   try {
  //     final response = await _client.get(APIUrl.products);
  //
  //     log(response.toString());
  //
  //     if (response.statusCode == 200) {
  //       final data = response.data as Map<String, dynamic>;
  //
  //       final products = (data['products'] as List).map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
  //
  //       return ApiResult.success(products);
  //     } else {
  //       return ApiResult.error(
  //         FailedResponse(status: response.statusCode ?? 500, message: "Failed to load products"),
  //       );
  //     }
  //   } catch (e) {
  //     log(e.toString());
  //     return ApiResult.error(
  //       FailedResponse(status: 0, message: e.toString()),
  //     );
  //   }
  // }

  Future<ApiResult<List<Product>>> getAllProducts({
    int limit = 10,
    int skip = 0,
    List<String> select = const ['title', 'price', 'images'],
  }) async {
    try {
      final uri = Uri.parse('https://dummyjson.com/products').replace(
        queryParameters: {
          'limit': limit.toString(),
          'skip': skip.toString(),
          'select': select.join(','),
        },
      );

      final response = await _client.get(uri.toString());

      log(response.toString());

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        final products = (data['products'] as List).map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();

        return ApiResult.success(products);
      } else {
        return ApiResult.error(
          FailedResponse(
            status: response.statusCode ?? 500,
            message: "Failed to load products",
          ),
        );
      }
    } catch (e) {
      log(e.toString());
      return ApiResult.error(
        FailedResponse(status: 0, message: e.toString()),
      );
    }
  }
}
