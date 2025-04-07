import 'package:isar/isar.dart';

part 'item.g.dart'; 

@Collection()
class Item {
  Id? id;  
  late String name;  
  late int quantity;  
  late bool inCart;  
  late bool ordered;  
  late double price;  

  Item({
    this.id,
    required this.name,
    required this.quantity,
    required this.inCart,
    required this.ordered,
    required this.price,
    
  });

  
  String? get imagePath => null;

  bool get isOutOfStock => quantity == 0;

  get status => null;
}
