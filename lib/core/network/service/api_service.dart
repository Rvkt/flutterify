// This file contains functions that call api_client and use defined endpoints.
// It acts like a bridge between UI/business logic and the actual api call.

import 'package:flutterify/core/network/client/api_urls.dart';
import 'package:flutterify/features/products/data/models/product_model.dart';

import '../client/api_client.dart';
import '../client/api_endpoints.dart';
import '../handler/api_handler.dart';
import '../handler/failed_response.dart';

class ApiService {
  final ApiClient _client = ApiClient();

  Future<ApiResult<List<Product>>> getAllProducts() async {
    try {
      final response = await _client.get(APIUrl.products);
      if (response.statusCode == 200) {
        final products = (response.data as List).map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
        return ApiResult.success(products);
      } else {
        return ApiResult.error(
          FailedResponse(status: response.statusCode ?? 500, message: "Failed to load products"),
        );
      }
    } catch (e) {
      return ApiResult.error(
        FailedResponse(status: 0, message: e.toString()),
      );
    }
  }

  Future<dynamic> getProductById(int id) async {
    final response = await _client.get(ApiEndpoints.productById(id));
    return response.data;
  }
}
