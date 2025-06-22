import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterify/core/network/service/api_service.dart';
import 'package:flutterify/features/products/data/models/product_model.dart';

import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ApiService apiService;

  ProductBloc({required this.apiService}) : super(ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
  }

  Future<void> _onLoadProducts(LoadProducts event, Emitter<ProductState> emit) async {
    emit(ProductLoading());

    final result = await apiService.getAllProducts();

    if (result.isSuccess) {
      final products = result.success as List<Product>;
      emit(ProductLoaded(products));
    } else {
      emit(ProductError(result.error!.message));
    }
  }
}
