// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../database.dart';
import '../models/item.dart';
import '../models/product.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: Colors.white, // 🤍 Cart screen background
      appBar: AppBar(
        title: const Text("Your Cart", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: cartItems.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text("Your cart is empty.", style: TextStyle(fontSize: 16)));
          }

          return StreamBuilder<List<Product>>(
            stream: DatabaseService.watchProducts(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final products = snapshot.data!;
              double totalPrice = 0.0;

              for (var item in items) {
                final product = products.firstWhere(
                  (prod) => prod.name == item.name,
                  orElse: () => Product(name: item.name, price: 0, imagePath: ''),
                );
                totalPrice += product.price * item.quantity;
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final product = products.firstWhere(
                          (prod) => prod.name == item.name,
                          orElse: () => Product(name: item.name, price: 0, imagePath: ''),
                        );
                        final itemTotal = product.price * item.quantity;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: product.imagePath.isNotEmpty
                                  ? Image.asset(product.imagePath, width: 60, height: 60, fit: BoxFit.cover)
                                  : const Icon(Icons.image_not_supported, size: 40),
                            ),
                            title: Text(
                              item.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            subtitle: Text(
                              "₱${itemTotal.toStringAsFixed(0)}",
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle, color: Colors.redAccent),
                                  onPressed: () => _decreaseQuantity(context, item),
                                ),
                                Text("${item.quantity}", style: const TextStyle(fontSize: 16)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle, color: Colors.green),
                                  onPressed: () => _increaseQuantity(item),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
  padding: const EdgeInsets.fromLTRB(16, 24, 16, 30),
  decoration: BoxDecoration(
    color: Colors.black,
    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Align(
        alignment: Alignment.centerLeft, // 👈 Align text to the left
        child: Text(
          "Total: ₱${totalPrice.toStringAsFixed(0)}",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      const SizedBox(height: 16),
      ElevatedButton(
        onPressed: () => _checkout(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text(
          "Checkout",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
        error: (err, stack) => const Center(child: Text("Error loading cart.")),
      ),
    );
  }

  void _increaseQuantity(Item item) async {
    await DatabaseService.updateQuantity(item.id!, item.quantity + 1);
  }

  void _decreaseQuantity(BuildContext context, Item item) async {
    if (item.quantity > 1) {
      await DatabaseService.updateQuantity(item.id!, item.quantity - 1);
    } else {
      await DatabaseService.removeFromCart(item);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${item.name} removed from cart")),
      );
    }
  }

void _checkout(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Confirm Order"),
      content: const Text("Are you sure you want to place this order?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () async {
            final cartItems = await DatabaseService.getCartItems();
            final products = await DatabaseService.getProducts();

            for (var item in cartItems) {
              final product = products.firstWhere(
                (p) => p.name == item.name,
                orElse: () => Product(name: item.name, price: 0, stock: 0, imagePath: ''),
              );

              final newStock = product.stock - item.quantity;
              if (newStock >= 0) {
                await DatabaseService.updateProductStock(product.id, newStock);
              } else {
                // Optional: Show a message if stock isn't enough
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Not enough stock for ${item.name}")),
                );
                Navigator.pop(context);
                return;
              }
            }

            await DatabaseService.checkout();
            Navigator.pop(context);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Order placed!")),
            );
          },
          child: const Text("Confirm"),
        ),
      ],
    ),
  );
}
}
