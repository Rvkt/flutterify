import '../data/models/product_model.dart';

abstract class ProductState {}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {
  final List<Product> oldProducts;
  final bool isFirstFetch;

  ProductLoading(this.oldProducts, {this.isFirstFetch = false});
}

class ProductLoaded extends ProductState {
  final List<Product> products;
  final bool hasMore;

  ProductLoaded(this.products, {this.hasMore = true});
}

class ProductError extends ProductState {
  final String message;

  ProductError(this.message);
}
