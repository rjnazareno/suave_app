// product.dart
import 'package:isar/isar.dart';

part 'product.g.dart';

@collection
class Product {
  Id id = Isar.autoIncrement; // Auto-generated ID

  late String name;
  late int price;
  late String imagePath;
  late int stock;

  Product({
    required this.name,
    required this.price,
    required this.imagePath,
    this.stock = 10,
  });
}
