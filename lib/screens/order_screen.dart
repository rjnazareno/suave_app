// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../database.dart';
import '../models/item.dart';
import '../models/product.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Orders", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.white,
      body: orders.when(
        data: (ordersList) {
          if (ordersList.isEmpty) {
            return const Center(
              child: Text(
                "No orders placed yet.",
                style: TextStyle(color: Colors.black54, fontSize: 18),
              ),
            );
          }

          return StreamBuilder<List<Product>>(
            stream: DatabaseService.watchProducts(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final products = snapshot.data!;

              double total = 0;

              final orderCards = ordersList.map((item) {
                final product = products.firstWhere(
                  (prod) => prod.name == item.name,
                  orElse: () => Product(name: item.name, price: 0, imagePath: ''),
                );

                final itemTotalPrice = product.price * item.quantity;
                total += itemTotalPrice;

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                item.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.shopping_bag, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Qty: ${item.quantity}",
                                    style: const TextStyle(color: Colors.black87, fontSize: 13),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(Icons.price_change, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    "₱${itemTotalPrice.toStringAsFixed(0)}",
                                    style: const TextStyle(color: Colors.black87, fontSize: 13),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () => _confirmCancelOrder(context, item),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList();

              return Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(12),
                      children: orderCards,
                    ),
                  ),
                  Container(
  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32), // more spacing inside
  decoration: const BoxDecoration(
    color: Colors.black,
    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      const Text(
        "Total",
        style: TextStyle(
          fontSize: 18,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(
        "₱${total.toStringAsFixed(0)}",
        style: const TextStyle(
          fontSize: 18,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  ),
),

                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => const Center(
          child: Text("Something went wrong!", style: TextStyle(color: Colors.red)),
        ),
      ),
    );
  }

 void _confirmCancelOrder(BuildContext context, Item item) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text("Cancel Order?", style: TextStyle(color: Colors.black)),
      content: const Text(
        "Are you sure you want to cancel this order?",
        style: TextStyle(color: Colors.black87),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("No", style: TextStyle(color: Colors.grey)),
        ),
        TextButton(
          onPressed: () async {
            // Fetch all products
            final products = await DatabaseService.getProducts();
            final product = products.firstWhere(
              (p) => p.name == item.name,
              orElse: () => Product(name: item.name, price: 0, imagePath: '', stock: 0),
            );

            // Return the stock
            await DatabaseService.updateProductStock(product.id, product.stock + item.quantity);

            // Delete the order
            await DatabaseService.deleteOrder(item);

            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Order cancelled and stock updated")),
            );
          },
          child: const Text("Yes, Cancel", style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}

}