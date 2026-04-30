import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../services/school_service.dart';
import 'home_screen.dart';
import 'notifications_screen.dart';
import 'search_criteria_screen.dart';
import 'school_details_screen.dart';
import 'thematic_map_screen.dart';

class SchoolsScreen extends StatefulWidget {
  final String? city;
  final String? area;
  final String? category;
  final String? schoolType;
  final String? primaryLanguage;
  final String? secondLanguage;

  const SchoolsScreen({
    super.key,
    this.city,
    this.area,
    this.category,
    this.schoolType,
    this.primaryLanguage,
    this.secondLanguage,
  });

  @override
  State<SchoolsScreen> createState() => _SchoolsScreenState();
}

class _SchoolsScreenState extends State<SchoolsScreen> {
  int _currentIndex = 0;
  final SchoolService _schoolService = SchoolService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_ios, size: 24, color: Colors.black),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.black),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Schools list is up to date!')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _schoolService.getSchoolsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final allSchools = snapshot.data ?? [];
                  
                  final schools = allSchools.where((school) {
                    bool matches = true;
                    // Filter by city (governorate in DB)
                    if (widget.city != null && school['governorate'] != widget.city) {
                      matches = false;
                    }
                    // Filter by schoolType (category in DB)
                    if (widget.schoolType != null) {
                      final dbCategory = (school['category'] ?? '').toString().toLowerCase();
                      final filterType = widget.schoolType!.toLowerCase();
                      if (!dbCategory.contains(filterType)) {
                        matches = false;
                      }
                    }
                    // Optional: Filter by area, category (gender), languages if they exist in DB
                    if (widget.area != null && school.containsKey('area') && school['area'] != widget.area) {
                      matches = false;
                    }
                    if (widget.category != null && school.containsKey('gender_category')) {
                      String filterCategory = widget.category!;
                      if (filterCategory == 'Both Boys and Girls') filterCategory = 'Mixed';
                      if (filterCategory == 'Boys only') filterCategory = 'Boys';
                      if (filterCategory == 'Girls only') filterCategory = 'Girls';
                      
                      if (school['gender_category'] != filterCategory) {
                        matches = false;
                      }
                    }
                    if (widget.primaryLanguage != null && school.containsKey('primary_language') && school['primary_language'] != widget.primaryLanguage) {
                      matches = false;
                    }
                    if (widget.secondLanguage != null && school.containsKey('second_language') && school['second_language'] != widget.secondLanguage) {
                      matches = false;
                    }
                    
                    return matches;
                  }).toList();

                  if (schools.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'No schools found.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black54, fontSize: 18),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 20),
                    itemCount: schools.length,
                    itemBuilder: (context, index) {
                      final school = schools[index];
                      final String imagePath = school['image_url'] ?? _getFallbackImage(school['name']);
                      final bool isLocalAsset = !imagePath.startsWith('http');
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: SchoolCard(
                          imagePath: imagePath,
                          name: school['name'] ?? 'Unknown School',
                          location: school['governorate'] ?? 'Unknown Location',
                          rating: school['rating']?.toString() ?? '5.0',
                          ratingText: 'Super',
                          priceRange: school['fees'] ?? '\$ Contact for fees',
                          schoolId: school['id'] ?? '',
                          isAsset: isLocalAsset,
                          schoolData: school,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Theme(
        data: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFFD6E6DF), // Matching the light teal/grey in mockup
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
                MaterialPageRoute(builder: (_) => const HomeScreen()),
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
                MaterialPageRoute(builder: (_) => const SearchCriteriaScreen()),
              );
            } else {
              setState(() {
                _currentIndex = index;
              });
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
                ],
              ),
              activeIcon: Stack(
                children: [
                  const Icon(CupertinoIcons.bell_fill),
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
  String _getFallbackImage(String? name) {
    if (name == null) return 'assets/images/city_internation_national.jpeg';
    if (name.contains('City')) return 'assets/images/city_internation_national.jpeg';
    if (name.contains('Dar')) return 'assets/images/dar_el_tarbiah.jpeg';
    return 'assets/images/city_internation_national.jpeg';
  }
}

class SchoolCard extends StatelessWidget {
  final String imagePath;
  final String name;
  final String location;
  final String rating;
  final String ratingText;
  final String priceRange;
  final String schoolId;
  final bool isAsset;
  final Map<String, dynamic>? schoolData;

  const SchoolCard({
    super.key,
    required this.imagePath,
    required this.name,
    required this.location,
    required this.rating,
    required this.ratingText,
    required this.priceRange,
    required this.schoolId,
    this.isAsset = true,
    this.schoolData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // School Image
        isAsset 
          ? Builder(
              builder: (context) {
                // Defensive path cleaning for Flutter Web
                String path = imagePath;
                if (path.startsWith('assets/assets/')) {
                  path = path.replaceFirst('assets/', '');
                }
                return Image.asset(
                  path,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 220,
                    color: Colors.grey[200],
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.broken_image, color: Colors.grey),
                        Text('Failed to load local asset', style: TextStyle(color: Colors.grey[600], fontSize: 10)),
                        if (path != imagePath) Text('Cleaned: $path', style: const TextStyle(fontSize: 8)),
                      ],
                    ),
                  ),
                );
              },
            )
          : Image.network(
              imagePath,
              height: 220,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Image.asset(
                'assets/images/city_internation_national.jpeg',
                height: 220,
                fit: BoxFit.cover,
              ),
            ),
        
        // School details
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name
              Text(
                name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Left side: Location and Rating
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 20, color: Colors.black54),
                            const SizedBox(width: 4),
                            Text(
                              location,
                              style: const TextStyle(
                                fontSize: 16, 
                                color: Colors.black54,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 20, color: Color(0xFFFFCC33)), // Amber/yellow star
                            const SizedBox(width: 4),
                            Text(
                              '$rating $ratingText',
                              style: const TextStyle(
                                fontSize: 16, 
                                color: Colors.black87,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Right side: Price and Button
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        priceRange,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 38,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SchoolDetailsScreen(
                                schoolId: schoolId,
                                schoolName: name,
                                schoolData: schoolData,
                              )),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF424242), // Dark grey color
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                          ),
                          child: const Text(
                            'More Info',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

