import 'package:flutter/material.dart';

import '../../data/models/product_model.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            product.images![0],
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
          ),
        ),
        title: Text(product.title!, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('₹${product.price!.toStringAsFixed(2)}'),
      ),
    );
  }
}
