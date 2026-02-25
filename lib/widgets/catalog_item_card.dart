import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smileproiz/provider/cart_provider.dart';

class CatalogItemCard extends StatelessWidget {
  final int productId;
  final String name;
  final int price;
  final String imageUrl;
  final String selectedSize; // если нет выбора, можно оставить ''
  final String selectedColor; // если нет выбора, можно оставить ''

  const CatalogItemCard({
    super.key,
    required this.productId,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.selectedSize = '',
    this.selectedColor = '',
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1A1A1A),
      child: Column(
        children: [
          Image.network(imageUrl, height: 120, fit: BoxFit.cover),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(color: Colors.white)),
          Text(
            '$price₸',
            style: const TextStyle(
              color: Color(0xFF00FF87),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () async {
              final cartProvider = Provider.of<CartProvider>(
                context,
                listen: false,
              );

              await cartProvider.addItem(
                productId: productId,
                name: name,
                price: price,
                imageUrl: imageUrl,
                selectedSize: selectedSize,
                selectedColor: selectedColor,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Товар добавлен в корзину'),
                  backgroundColor: Color(0xFF1A1A1A),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00FF87),
              foregroundColor: Colors.black,
            ),
            child: const Text('Добавить в корзину'),
          ),
        ],
      ),
    );
  }
}
