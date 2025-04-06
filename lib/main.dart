import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midterm_project_suave/screens/splash_screen.dart';
import 'database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.init();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
