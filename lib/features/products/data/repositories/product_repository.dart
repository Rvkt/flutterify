import 'package:flutterify/core/network/handler/api_handler.dart';
import 'package:flutterify/core/network/service/api_service.dart';
import 'package:flutterify/features/products/data/models/product_model.dart';
import 'package:flutterify/injection/injection_container.dart';

class ProductRepository {
  final ApiService apiService = sl<ApiService>();

  Future<ApiResult<List<Product>>> getProducts() {
    return apiService.getAllProducts();
  }
}
