class ApiEndpoints {
  static const String products = "/products";

  static String productById(int id) => "/products/$id";

  static String productsByCategory(String category) => "/products/category/$category";
}
