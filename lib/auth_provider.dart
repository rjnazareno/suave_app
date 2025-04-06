// ignore: depend_on_referenced_packages
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';  // User model
import '../database.dart';  // Database service

final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) => AuthNotifier());

class AuthNotifier extends StateNotifier<User?> {
  AuthNotifier() : super(null);


  Future<bool> signIn(String username, String password) async {
    User? user = await DatabaseService.signIn(username, password);
    if (user != null) {
      state = user;
      return true;
    }
    return false;
  }

 Future<User?> signInWithReturn(String username, String password) async {
  User? user = await DatabaseService.signIn(username, password);
  if (user != null) {
    // If the user is admin, set their isAdmin flag to true
    if (user.username == 'admin' && user.password == 'adminpass') {
      user.isAdmin = true;
    } else {
      user.isAdmin = false;
    }
    state = user; // Set the user in the state
    return user;
  }
  return null; // If no user is found or credentials are incorrect
}

  void signOut() {
    state = null;
  }
}
