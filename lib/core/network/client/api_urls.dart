import 'api_endpoints.dart';

class APIUrl {
  static String get _baseUrl {
    return "https://fakestoreapi.com/";
  }

  static String products = "$_baseUrl${ApiEndpoints.products}";
}
