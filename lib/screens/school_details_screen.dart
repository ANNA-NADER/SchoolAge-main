import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'home_screen.dart';
import 'notifications_screen.dart';
import 'search_criteria_screen.dart';
import 'application_screen.dart';
import 'thematic_map_screen.dart';

class SchoolDetailsScreen extends StatefulWidget {
  final String schoolId;
  final String schoolName;
  final Map<String, dynamic>? schoolData;

  const SchoolDetailsScreen({
    super.key,
    this.schoolId = '',
    this.schoolName = '',
    this.schoolData,
  });

  @override
  State<SchoolDetailsScreen> createState() => _SchoolDetailsScreenState();
}

class _SchoolDetailsScreenState extends State<SchoolDetailsScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Header Image
                  Stack(
                    children: [
                      _buildHeaderImage(),
                      Positioned(
                        top: 16,
                        left: 16,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(76),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Content Sections
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoSection(
                          icon: Icons.school_outlined,
                          title: 'About ${widget.schoolName}:',
                          content: widget.schoolData?['description'] ??
                              '${widget.schoolName} aims to provide a balanced educational environment that focuses on academic excellence.',
                        ),
                        const SizedBox(height: 24),
                        _buildInfoSection(
                          icon: Icons.monetization_on_outlined,
                          title: 'Fees:',
                          content: widget.schoolData?['fees'] ?? 'Contact school for fees',
                        ),
                        const SizedBox(height: 24),
                        _buildInfoSection(
                          icon: Icons.phone_outlined,
                          title: 'Contact Information:',
                          content: widget.schoolData?['contact'] ?? 'Contact school for details',
                        ),
                        const SizedBox(height: 40),
                        
                        // Apply Now Button
                        SCenter(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ApplicationScreen(
                                    schoolId: widget.schoolId,
                                    schoolName: widget.schoolName,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2B3346),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 5,
                            ),
                            child: const Text(
                              'APPLY NOW',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFFD6EBE8),
          currentIndex: _selectedIndex,
          onTap: (index) {
            if (index == 0) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false,
              );
            } else if (index == 1) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            } else if (index == 2) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ThematicMapScreen()),
              );
            } else if (index == 3) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => SearchCriteriaScreen()),
              );
            } else {
              setState(() {
                _selectedIndex = index;
              });
            }
          },
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black87,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          iconSize: 28,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.notifications_none_outlined),
              activeIcon: Icon(Icons.notifications),
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

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: Colors.black),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            height: 1.4,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderImage() {
    final imageUrl = widget.schoolData?['image_url'] ?? widget.schoolData?['image'];
    const fallback = 'assets/images/school_building.png';

    if (imageUrl == null) {
      return Image.asset(
        'assets/images/screen2.png',
        fit: BoxFit.cover,
        height: 250,
        width: double.infinity,
      );
    }

    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        height: 250,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          fallback,
          fit: BoxFit.cover,
          height: 250,
          width: double.infinity,
        ),
      );
    } else {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        height: 250,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          fallback,
          fit: BoxFit.cover,
          height: 250,
          width: double.infinity,
        ),
      );
    }
  }
}

class SCenter extends StatelessWidget {
  final Widget child;
  const SCenter({super.key, required this.child});
  @override
  Widget build(BuildContext context) => Center(child: child);
}
