import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'notifications_screen.dart';
import 'package:flutter/cupertino.dart';
import 'search_criteria_screen.dart';
import 'success_screen.dart';
import 'thematic_map_screen.dart';
import 'package:image_picker/image_picker.dart';

class InstapayScreen extends StatefulWidget {
  const InstapayScreen({super.key});

  @override
  State<InstapayScreen> createState() => _InstapayScreenState();
}

class _InstapayScreenState extends State<InstapayScreen> {
  final int _currentIndex = 0;
  String? _selectedFileName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios, size: 24, color: Colors.black),
                ),
              ),
              const SizedBox(height: 16),
              
              // Logo Placeholder/Asset
              Center(
                child: Image.asset(
                  'assets/images/instapay_logo.png',
                  height: 120,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback if asset is missing
                    return Column(
                      children: [
                        const Icon(Icons.payment, size: 80, color: Colors.purple),
                        const SizedBox(height: 8),
                        const Text(
                          'INSTAPAY',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 60),
              
              const Text(
                'Application Fee: 1,000 EGP',
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Pay via InstaPay to: 01XXXXXXXXX',
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                ),
              ),
              
              const SizedBox(height: 60),
              
              const Text(
                'Upload payment\nscreenshot to proceed',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.2,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // upload photo button
              Align(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    OutlinedButton(
                      onPressed: () async {
                        final picker = ImagePicker();
                        final image = await picker.pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          setState(() {
                            _selectedFileName = image.name;
                          });
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFEBEBEB),
                        side: const BorderSide(color: Colors.black, width: 1.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        minimumSize: const Size(200, 50),
                        elevation: 0,
                      ),
                      child: Text(
                        _selectedFileName != null ? 'change photo' : 'upload photo',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    if (_selectedFileName != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              _selectedFileName!,
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 80),
              
              // Submit button
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  height: 48,
                  width: 160,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SuccessScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF333333),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Submit',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Theme(
        data: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFFD6E6DF),
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          currentIndex: _currentIndex,
          iconSize: 28,
          onTap: (index) {
            if (index == 0) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => HomeScreen()),
              );
            } else if (index == 1) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => NotificationsScreen()),
              );
            } else if (index == 2) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ThematicMapScreen()),
            );
          } else if (index == 3) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => SearchCriteriaScreen()),
              );
            }
          },
          items: [
            const BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home),
              activeIcon: Icon(CupertinoIcons.house_fill),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  const Icon(CupertinoIcons.bell),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                    ),
                    child: const Text(
                      '1',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
              activeIcon: Stack(
                children: [
                  const Icon(CupertinoIcons.bell_fill),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                    ),
                    child: const Text(
                      '1',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
              label: 'Notifications',
            ),
            const BottomNavigationBarItem(
            icon: Icon(Icons.public),
            label: 'Map',
          ),
            const BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.plus_app),
              activeIcon: Icon(CupertinoIcons.plus_app_fill),
              label: 'Add',
            ),
          ],
        ),
      ),
    );
  }
}


