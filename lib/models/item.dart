import 'package:isar/isar.dart';

part 'item.g.dart'; // Ensure this is rebuilt using build_runner

@Collection()
class Item {
  Id? id;  // The unique identifier for the item
  late String name;  // Name of the item
  late int quantity;  // The quantity or stock of the item
  late bool inCart;  // Whether the item is in the user's cart
  late bool ordered;  // Whether the item is ordered
  late double price;  // The price of the item

  Item({
    this.id,
    required this.name,
    required this.quantity,
    required this.inCart,
    required this.ordered,
    required this.price,
    
  });

  // Returns the item image path (if available, you can adjust this later)
  String? get imagePath => null;
  
  // Check if the item is out of stock
  bool get isOutOfStock => quantity == 0;

  get status => null;
}
