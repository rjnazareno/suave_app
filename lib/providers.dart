// ignore: depend_on_referenced_packages
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database.dart';
import 'models/item.dart';

//  StreamProvider to watch the list of orders
final ordersProvider = StreamProvider<List<Item>>((ref) {
  return DatabaseService.watchOrders();  // Watches the orders from the database
});


final cartProvider = StreamProvider<List<Item>>((ref) {
  return DatabaseService.watchCartItems();  // Watches the cart items from the database
});
