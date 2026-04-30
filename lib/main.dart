import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart';
import 'screens/logo_screen.dart';
import 'widgets/floating_form_bubble.dart';

// Global navigator key to allow navigation from outside the widget tree (like the floating bubble)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    if (kDebugMode) {
      print('Firebase initialization error: $e');
    }
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // Assign the global key here
      debugShowCheckedModeBanner: false,
      title: 'SchoolAge',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2B3346)),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return FloatingFormBubble(child: child!);
      },
      home: const LogoScreen(),
    );
  }
}
