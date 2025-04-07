import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'models/item.dart';
import 'models/user.dart';
import 'models/product.dart';

class DatabaseService {
  static late Isar isar;



  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [ItemSchema, UserSchema, ProductSchema],
      directory: dir.path,
    );

    final admin = await isar.users.filter().usernameEqualTo('admin').findFirst();
    if (admin == null) {
      await isar.writeTxn(() async {
        await isar.users.put(User(username: 'admin', password: 'adminpass', isAdmin: true));
      });
    }

    final user = await isar.users.filter().usernameEqualTo('user').findFirst();
    if (user == null) {
      await isar.writeTxn(() async {
        await isar.users.put(User(username: 'user', password: 'userpass', isAdmin: false));
      });
    }

    final productCount = await isar.products.count();
    if (productCount == 0) {
      final sampleProducts = [
        Product(name: "Light Washed Denim", price: 4100, imagePath: "assets/s1.png", stock: 10),
Product(name: "Denim jacket pockets", price: 4295, imagePath: "assets/s2.png", stock: 10),
Product(name: "Cotton chambray shirt", price: 3995, imagePath: "assets/s10.png", stock: 10),
Product(name: "Pocketed denim jacket", price: 4200, imagePath: "assets/s4.png", stock: 10),
Product(name: "Lyocell linen overshirt with pockets", price: 4995, imagePath: "assets/s5.png", stock: 10),
Product(name: "Tencel One Size-fit overshirt", price: 5100, imagePath: "assets/s6.png", stock: 10),
Product(name: "Ribbed cotton knitted sweater", price: 3000, imagePath: "assets/s7.png", stock: 10),
Product(name: "Wool-blend flannel overshirt", price: 4600, imagePath: "assets/s8.png", stock: 10),
Product(name: "Printed cotton sweatshirt", price: 2500, imagePath: "assets/s9.png", stock: 10),
Product(name: "One Size-fit flannel jacket", price: 4200, imagePath: "assets/s3.png", stock: 10),

      ];
      await isar.writeTxn(() async {
        await isar.products.putAll(sampleProducts);
      });
    }
  }

  // ---------------- AUTH ---------------- //

  static Future<User?> signIn(String username, String password) async {
    final user = await isar.users.filter().usernameEqualTo(username).findFirst();
    return (user != null && user.password == password) ? user : null;
  }

  static Future<List<User>> getAllUsers() async => await isar.users.where().findAll();

  static Future<void> deleteUser(int userId) async {
    await isar.writeTxn(() async {
      await isar.users.delete(userId);
    });
  }

  static Stream<List<User>> watchUsers() =>
      isar.users.where().watch(fireImmediately: true);

  // ---------------- ITEM & CART ---------------- //

  static Future<void> addItem(String name, double price) async {
    final existingItem = await isar.items.filter().nameEqualTo(name).findFirst();

    await isar.writeTxn(() async {
      if (existingItem == null) {
        await isar.items.put(Item(
          name: name,
          quantity: 1,
          inCart: true,
          ordered: false,
          price: price,
        ));
      } else {
        existingItem.quantity++;
        existingItem.inCart = true;
        await isar.items.put(existingItem);
      }
    });
  }

  static Stream<List<Item>> watchItems() =>
      isar.items.where().watch(fireImmediately: true);

  static Stream<List<Item>> watchCartItems() =>
      isar.items.filter().inCartEqualTo(true).watch(fireImmediately: true);

  static Stream<List<Item>> watchOrders() =>
      isar.items.filter().orderedEqualTo(true).watch(fireImmediately: true);

  static Future<void> updateQuantity(int itemId, int newQuantity) async {
    final item = await isar.items.get(itemId);
    if (item != null) {
      await isar.writeTxn(() async {
        item.quantity = newQuantity;
        await isar.items.put(item);
      });

      if (newQuantity <= 0) {
        await removeFromCart(item);
      }
    }
  }

  static Future<void> removeFromCart(Item item) async {
    await isar.writeTxn(() async {
      await isar.items.delete(item.id!);
    });
  }

  static Future<void> checkout() async {
    final cartItems = await getCartItems(); 

    await isar.writeTxn(() async {
      for (var item in cartItems) {
        // Reduce stock in corresponding product
        final product = await isar.products.filter().nameEqualTo(item.name).findFirst();
        if (product != null && product.stock >= item.quantity) {
          product.stock -= item.quantity;
          await isar.products.put(product);
        }

        
        item.ordered = true;
        item.inCart = false;
        await isar.items.put(item);
      }
    });
  }

  static Future<void> deleteOrder(Item item) async {
    await isar.writeTxn(() async {
      await isar.items.delete(item.id!);
    });
  }

  static Future<List<Item>> getCartItems() async {
    final items = await isar.items.filter().inCartEqualTo(true).findAll();
    return items; 
  }

  // ---------------- PRODUCTS ---------------- //

  static Stream<List<Product>> watchProducts() =>
      isar.products.where().watch(fireImmediately: true);

  static Future<List<Product>> getProducts() =>
      isar.products.where().findAll();

  static Future<void> updateProductStock(int id, int newQuantity) async {
    final product = await isar.products.get(id);
    if (product != null) {
      await isar.writeTxn(() async {
        product.stock = newQuantity;
        await isar.products.put(product);
      });
    }
  }

  static Stream<int> watchCartItemCount() {
    return isar.items
        .filter()
        .inCartEqualTo(true)
        .watch(fireImmediately: true)
        .map((items) => items.fold(0, (sum, item) => sum + item.quantity));
  }
}
