// ignore: depend_on_referenced_packages
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database.dart';
import 'models/item.dart';

// Define a StreamProvider to watch the list of orders
final ordersProvider = StreamProvider<List<Item>>((ref) {
  return DatabaseService.watchOrders();  // Watches the orders from the database
});

// If you have a cart provider, you can define it here
final cartProvider = StreamProvider<List<Item>>((ref) {
  return DatabaseService.watchCartItems();  // Watches the cart items from the database
});
