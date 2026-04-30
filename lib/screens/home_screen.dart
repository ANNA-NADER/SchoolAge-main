import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'notifications_screen.dart';
import 'search_criteria_screen.dart';
import 'thematic_map_screen.dart';
import '../services/school_service.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final int _currentIndex = 0;
  final _schoolService = SchoolService();
  final _authService = AuthService();
  
  int _selectedAppIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: user == null 
          ? const Center(child: Text('Please log in'))
          : StreamBuilder<List<Map<String, dynamic>>>(
              stream: _schoolService.getUserApplicationsStream(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final applications = snapshot.data ?? [];
                
                // Reset index if applications list changed and index is out of bounds
                if (_selectedAppIndex >= applications.length && applications.isNotEmpty) {
                  _selectedAppIndex = 0;
                }

                final selectedAppData = applications.isNotEmpty 
                    ? applications[_selectedAppIndex] 
                    : null;

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        // Search Bar
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.search, color: Colors.grey[600], size: 24),
                              const SizedBox(width: 12),
                              Text(
                                'Search',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Filter Buttons
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildFilterButton(Icons.favorite_border, 'Favorites'),
                              const SizedBox(width: 10),
                              _buildFilterButton(Icons.history, 'History'),
                              const SizedBox(width: 10),
                              _buildFilterButton(Icons.person_outline, 'Following'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),

                        // Map Card with Dropdown
                        _buildTopLocationCard(selectedAppData, applications),

                        const SizedBox(height: 25),

                        // Dynamic Application Feed
                        _buildApplicationFeed(selectedAppData),
                        
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                );
              },
            ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFD6EBE8),
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 1) {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationsScreen()));
          } else if (index == 2) {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ThematicMapScreen()));
          } else if (index == 3) {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => SearchCriteriaScreen()));
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.house_fill), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.bell), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.public), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.plus_app), label: 'Add'),
        ],
      ),
    );
  }

  Widget _buildTopLocationCard(Map<String, dynamic>? selectedAppData, List<Map<String, dynamic>> allApps) {
    final school = selectedAppData?['school'];
    final city = school?['governorate'] ?? 'Cairo';
    
    LatLng point = const LatLng(30.0444, 31.2357);
    if (school != null && school['latitude'] != null && school['longitude'] != null) {
      point = LatLng(school['latitude'], school['longitude']);
    }

    return Container(
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey.shade300),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          FlutterMap(
            key: ValueKey('map_${school?['id'] ?? 'default'}'),
            options: MapOptions(
              initialCenter: point,
              initialZoom: 14.0,
              interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.schoolage',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: point,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                  ),
                ],
              ),
            ],
          ),
          
          // Dropdown overlay for selecting location/school
          if (allApps.isNotEmpty)
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(230),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 10)
                    ],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _selectedAppIndex,
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                      onChanged: (int? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedAppIndex = newValue;
                          });
                        }
                      },
                      items: List.generate(allApps.length, (index) {
                        final app = allApps[index];
                        final s = app['school'];
                        final areaPrefix = s['area'] != null ? '${s['area']} - ' : '';
                        return DropdownMenuItem<int>(
                          value: index,
                          child: Text('$areaPrefix${s['name']}'),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),

          Positioned(
            bottom: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(200),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                city,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationFeed(Map<String, dynamic>? selectedAppData) {
    if (selectedAppData == null) {
      return _buildDefaultFeed();
    }

    final app = selectedAppData['application'];
    final school = selectedAppData['school'];
    final studentName = app['studentInfo']['fullName'];
    final createdAt = app['createdAt'] as Timestamp?;
    
    String dateStr = 'Just now';
    if (createdAt != null) {
      dateStr = DateFormat('MMM dd, yyyy - hh:mm a').format(createdAt.toDate());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFD6EBE8),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black12),
              ),
              child: const Icon(Icons.school, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    school['name'] ?? 'School Name',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    'Applied for: $studentName',
                    style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const Icon(Icons.more_horiz),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.asset(
            _getCleanPath(school['image_url'] ?? 'assets/images/city_internation_national.jpeg'),
            width: double.infinity,
            height: 350,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Image.asset(
              'assets/images/city_internation_national.jpeg',
              width: double.infinity,
              height: 350,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Application Submitted',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              dateStr,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F9F8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD6EBE8)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Your application for $studentName is being reviewed by the administration.',
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultFeed() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Icon(Icons.school_outlined, size: 80, color: Colors.grey[300]),
        const SizedBox(height: 16),
        const Text(
          'No Active Applications',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        const Text(
          'Start your journey by finding the perfect school for your child.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => SearchCriteriaScreen()));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2B3346),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: const Text('Find a School', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  String _getCleanPath(String path) {
    return path.replaceAll('assets/assets/', 'assets/').replaceAll(' ', '_');
  }

  Widget _buildFilterButton(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
