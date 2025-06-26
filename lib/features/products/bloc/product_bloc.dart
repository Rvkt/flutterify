import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterify/core/network/service/api_service.dart';
import 'package:flutterify/features/products/data/models/product_model.dart';

import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ApiService apiService;

  bool _hasMore = true;
  final int _pageSize = 10;
  bool _isLoading = false; // <-- Add this

  ProductBloc({required this.apiService}) : super(ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<LoadMoreProducts>(_onLoadMoreProducts);
  }

  Future<void> _onLoadProducts(LoadProducts event, Emitter<ProductState> emit) async {
    if (_isLoading) return; // Prevent overlapping loads
    _isLoading = true;

    try {
      List<Product> oldProducts = [];

      if (state is ProductLoaded) {
        oldProducts = (state as ProductLoaded).products;
      } else if (state is ProductLoading) {
        oldProducts = (state as ProductLoading).oldProducts;
      }

      final isFirstFetch = oldProducts.isEmpty;
      emit(ProductLoading(oldProducts, isFirstFetch: isFirstFetch));

      final skip = oldProducts.length;
      final limit = _pageSize;

      final result = await apiService.getAllProducts(limit: limit, skip: skip);

      if (result.isSuccess) {
        final newProducts = result.success as List<Product>;
        final allProducts = [...oldProducts, ...newProducts];

        _hasMore = newProducts.length == limit;

        emit(ProductLoaded(allProducts, hasMore: _hasMore));
      } else {
        emit(ProductError(result.error!.message));
      }
    } finally {
      _isLoading = false;
    }
  }

  Future<void> _onLoadMoreProducts(LoadMoreProducts event, Emitter<ProductState> emit) async {
    // Only load more if more products available
    if (_hasMore) {
      await _onLoadProducts(LoadProducts(), emit);
    }
  }

  void resetPagination() {
    _hasMore = true;
  }

  bool get hasMore => _hasMore;
}
