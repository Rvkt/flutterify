import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterify/features/products/presentation/widgets/product_card.dart';
import 'package:flutterify/injection/injection_container.dart';

import '../../bloc/product_bloc.dart';
import '../../bloc/product_event.dart';
import '../../bloc/product_state.dart';
import '../../data/models/product_model.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ScrollController _scrollController = ScrollController();
  late ProductBloc _productBloc;

  @override
  void initState() {
    super.initState();
    _productBloc = sl<ProductBloc>()..add(LoadProducts());

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        // Trigger next page load when 200px near the bottom
        _productBloc.add(LoadMoreProducts());
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _productBloc,
      child: Scaffold(
        appBar: AppBar(title: const Text('Products')),
        body: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            List<Product> products = [];
            bool isLoadingMore = false;

            if (state is ProductLoading) {
              products = state.oldProducts;
              isLoadingMore = !state.isFirstFetch;
            } else if (state is ProductLoaded) {
              products = state.products;
              isLoadingMore = false;
            } else if (state is ProductError) {
              return Center(child: Text(state.message));
            } else if (state is ProductInitial) {
              return const Center(child: Text('Press button to load products'));
            }

            if (products.isEmpty && isLoadingMore == false) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView.builder(
              controller: _scrollController,
              itemCount: isLoadingMore ? products.length + 1 : products.length,
              itemBuilder: (_, index) {
                if (index < products.length) {
                  return ProductCard(product: products[index]);
                } else {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}
