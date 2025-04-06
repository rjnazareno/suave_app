// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midterm_project_suave/models/product.dart';
import 'package:midterm_project_suave/database.dart';

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  void _updateStock(BuildContext context, Product product) async {
    final controller = TextEditingController(text: product.stock.toString());

    final newValue = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Update Stock: ${product.name}', style: const TextStyle(color: Colors.black)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'New Quantity'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              Navigator.pop(context, value);
            },
            child: const Text("Next", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );

    if (newValue != null) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Update'),
          content: Text('Are you sure you want to update the stock to $newValue for "${product.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirm'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await DatabaseService.updateProductStock(product.id, newValue);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Stock updated to $newValue for ${product.name}.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Stocks', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder<List<Product>>(
        stream: DatabaseService.watchProducts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final products = snapshot.data!;
          if (products.isEmpty) {
            return const Center(
              child: Text('No products found.', style: TextStyle(color: Colors.black54)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: products.length,
            itemBuilder: (_, index) {
              final product = products[index];
              final outOfStock = product.stock <= 0;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: product.imagePath.isNotEmpty
                            ? Image.asset(product.imagePath, width: 60, height: 60, fit: BoxFit.cover)
                            : const Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              outOfStock ? 'Out of Stock' : 'Stock: ${product.stock}',
                              style: TextStyle(
                                color: outOfStock ? Colors.red : Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.black87),
                        onPressed: () => _updateStock(context, product),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
