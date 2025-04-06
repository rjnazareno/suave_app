// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midterm_project_suave/auth_provider.dart';
import 'package:midterm_project_suave/screens/admin_welcome_screen.dart';

import 'home_screen.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _authenticate() async {
    final auth = ref.read(authProvider.notifier);
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    final user = await auth.signInWithReturn(username, password);
    if (user != null) {
      if (user.isAdmin) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminWelcomeScreen()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid credentials")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    height: 100,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(labelText: "Username"),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Password"),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _authenticate,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Sign In", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
