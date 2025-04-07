import 'package:isar/isar.dart';

part 'user.g.dart';

@Collection()
class User {
  Id id = Isar.autoIncrement;

  late String username;
  late String password;
  
  bool isAdmin = false; 

  User({required this.username, required this.password, required this.isAdmin});
}
