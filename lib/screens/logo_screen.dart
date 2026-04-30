import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'welcome_screen.dart';
import 'home_screen.dart';
import 'admin/admin_dashboard_screen.dart';
import '../services/auth_service.dart';

class LogoScreen extends StatefulWidget {
  const LogoScreen({super.key});

  @override
  State<LogoScreen> createState() => _LogoScreenState();
}

class _LogoScreenState extends State<LogoScreen> {
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), _navigateNext);
  }

  Future<void> _navigateNext() async {
    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Not logged in → Welcome screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
      return;
    }

    // User is already logged in — check their role
    try {
      final userData = await _authService.getUserData(user.uid);
      final role = userData?['role'] ?? 'parent';

      if (kDebugMode) {
        print('LogoScreen: user role = $role, data = $userData');
      }

      if (!mounted) return;

      if (role == 'admin') {
        final schoolId = userData?['schoolId'] ?? '';
        String schoolName = 'My School';

        if (schoolId.isNotEmpty) {
          final schoolDoc = await FirebaseFirestore.instance
              .collection('schools')
              .doc(schoolId)
              .get();
          schoolName = schoolDoc.data()?['name'] ?? 'My School';
        }

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => AdminDashboardScreen(
                schoolId: schoolId,
                schoolName: schoolName,
              ),
            ),
          );
        }
      } else {
        // Regular parent — go home
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) print('LogoScreen routing error: $e');
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox.expand(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Image.asset(
            'assets/images/anna_logo.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Text(
                  'Please make sure logo.png is correctly placed.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
