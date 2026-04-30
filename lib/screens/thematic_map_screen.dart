import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'home_screen.dart';
import 'notifications_screen.dart';
import 'search_criteria_screen.dart';
import '../services/school_service.dart';

class ThematicMapScreen extends StatefulWidget {
  const ThematicMapScreen({super.key});

  @override
  State<ThematicMapScreen> createState() => _ThematicMapScreenState();
}

class _ThematicMapScreenState extends State<ThematicMapScreen> {
  final MapController _mapController = MapController();
  Map<String, dynamic>? _selectedSchool;

  final SchoolService _schoolService = SchoolService();

  @override
  void initState() {
    super.initState();
    // No need to manually load, we will use StreamBuilder in the body
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else if (index == 1) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const NotificationsScreen()),
      );
    } else if (index == 2) {
      // Map - Already here
    } else if (index == 3) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SearchCriteriaScreen()),
      );
    }
  }

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom + 1);
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom - 1);
  }

  void _resetRotation() {
    _mapController.rotate(0);
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'american':
        return Colors.redAccent;
      case 'ig':
      case 'british':
        return Colors.blueAccent;
      case 'international':
        return Colors.purpleAccent;
      case 'national':
        return const Color(0xFF14B886); // Emerald green
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Schools Map', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
        ],
      ),
      body: Stack(
        children: [
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _schoolService.getSchoolsStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return const Center(child: Text('Error loading map data'));
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

              final schools = snapshot.data!;
              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: const LatLng(30.0444, 31.2357), // Center on Cairo
                  initialZoom: 10.0, // Zoom in closer to Cairo
                  cameraConstraint: CameraConstraint.contain(
                    bounds: LatLngBounds(
                      const LatLng(21.5, 24.0),
                      const LatLng(32.0, 37.0),
                    ),
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                    subdomains: const ['a', 'b', 'c', 'd'],
                    userAgentPackageName: 'com.example.schoolage',
                  ),
                  MarkerLayer(
                    markers: schools.map((school) {
                      final color = _getCategoryColor(school['category'] ?? '');
                      final double lat = (school['lat'] is int) ? (school['lat'] as int).toDouble() : (school['lat'] as double? ?? 0.0);
                      final double lng = (school['lng'] is int) ? (school['lng'] as int).toDouble() : (school['lng'] as double? ?? 0.0);
                      
                      return Marker(
                        point: LatLng(lat, lng),
                        width: 60,
                        height: 60,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedSchool = school;
                            });
                          },
                          child: Icon(
                            Icons.school,
                            color: color,
                            size: 30,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const Scalebar(
                    alignment: Alignment.bottomLeft,
                    textStyle: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                  ),
                ],
              );
            },
          ),
          // North Arrow
          Positioned(
            top: 16,
            right: 16,
            child: StreamBuilder<MapEvent>(
              stream: _mapController.mapEventStream,
              builder: (context, snapshot) {
                final rotation = _mapController.camera.rotation;
                return GestureDetector(
                  onTap: _resetRotation,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(200),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(50),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Transform.rotate(
                      angle: rotation * (3.14159 / 180),
                      child: const Icon(
                        Icons.navigation,
                        color: Color(0xFF14B886),
                        size: 28,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Zoom Controls
          Positioned(
            bottom: 32,
            right: 16,
            child: Column(
              children: [
                _buildControlButton(
                  icon: Icons.add,
                  onPressed: _zoomIn,
                ),
                const SizedBox(height: 12),
                _buildControlButton(
                  icon: Icons.remove,
                  onPressed: _zoomOut,
                ),
              ],
            ),
          ),
          // Legend
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegendItem('American', Colors.redAccent),
                  _buildLegendItem('IG/British', Colors.blueAccent),
                  _buildLegendItem('International', Colors.purpleAccent),
                  _buildLegendItem('National', const Color(0xFF14B886)),
                ],
              ),
            ),
          ),
          if (_selectedSchool != null)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  // Allow tapping the background to dismiss
                  setState(() {
                    _selectedSchool = null;
                  });
                },
                child: Container(
                  color: Colors.black54,
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () {}, // Prevent taps on the card from dismissing it
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Builder(
                            builder: (context) {
                              final String imageUrl = _selectedSchool!['image_url'] ?? 'https://via.placeholder.com/400x200?text=No+Image';
                              
                              Widget errorFallback(BuildContext ctx, Object error, StackTrace? stackTrace) {
                                return Container(
                                  height: 180,
                                  color: Colors.grey[200],
                                  child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                                );
                              }

                              if (imageUrl.startsWith('http')) {
                                return Image.network(
                                  imageUrl,
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: errorFallback,
                                );
                              } else {
                                // Defensive path cleaning for Flutter Web
                                String path = imageUrl;
                                if (path.startsWith('assets/assets/')) {
                                  path = path.replaceFirst('assets/', '');
                                }
                                return Image.asset(
                                  path,
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: errorFallback,
                                );
                              }
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedSchool!['name'],
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                                const SizedBox(height: 8),
                                Text('Category: ${_selectedSchool!['category']}'),
                                Text('Governorate: ${_selectedSchool!['governorate']}'),
                                if (_selectedSchool!['fees'] != null) ...[
                                  const SizedBox(height: 4),
                                  Text('Fees: ${_selectedSchool!['fees']}', style: const TextStyle(fontWeight: FontWeight.w500)),
                                ],
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedSchool = null;
                                  });
                                },
                                child: const Text('Cancel', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ), // Close ConstrainedBox
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFD6EBE8),
        selectedItemColor: Colors.black87,
        unselectedItemColor: Colors.black54,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: 2,
        onTap: _onItemTapped,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_none_outlined),
              ],
            ),
            label: 'Notifications',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.public),
            label: 'Map',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            label: 'Add',
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildControlButton({required IconData icon, required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(230),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(50),
              blurRadius: 4,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.black87,
          size: 24,
        ),
      ),
    );
  }
}

class Scalebar extends StatelessWidget {
  final Alignment alignment;
  final TextStyle textStyle;

  const Scalebar({
    super.key,
    this.alignment = Alignment.bottomLeft,
    this.textStyle = const TextStyle(color: Colors.black, fontSize: 12),
  });

  @override
  Widget build(BuildContext context) {
    // In flutter_map 8.x, use MapCamera.of(context) to get real-time updates
    final camera = MapCamera.of(context);
    final zoom = camera.zoom;
    final latitude = camera.center.latitude;

        // Meters per pixel calculation for Web Mercator projection
        // metersPerPixel = (cos(lat * pi/180) * 2 * pi * 6378137) / (256 * 2^zoom)
        final metersPerPixel = (cos(latitude * pi / 180) * 2 * pi * 6378137) / (256 * pow(2, zoom));

        // We want a bar that is roughly 100-150 pixels wide
        const targetWidth = 100.0;
        final distanceInMeters = targetWidth * metersPerPixel;

        // Round to a "pretty" number (1, 2, 5, 10, 20, 50, 100, 200, 500, 1000...)
        double prettyDistance;
        String unit = 'm';

        if (distanceInMeters >= 1000) {
          final distanceInKm = distanceInMeters / 1000;
          prettyDistance = _getPrettyNumber(distanceInKm);
          unit = 'km';
        } else {
          prettyDistance = _getPrettyNumber(distanceInMeters);
        }

        final finalDistanceInMeters = unit == 'km' ? prettyDistance * 1000 : prettyDistance;
        final finalWidth = finalDistanceInMeters / metersPerPixel;

        return Align(
          alignment: alignment,
          child: Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 80),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${prettyDistance.toStringAsFixed(prettyDistance < 10 && unit == 'km' ? 1 : 0)} $unit',
                  style: textStyle,
                ),
                const SizedBox(height: 4),
                Container(
                  width: finalWidth,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withAlpha(150),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
  }

  double _getPrettyNumber(double n) {
    if (n <= 0) return 0;
    final pow10 = pow(10, (log(n) / ln10).floor());
    final d = n / pow10;
    if (d < 2) return 1 * pow10.toDouble();
    if (d < 5) return 2 * pow10.toDouble();
    if (d < 10) return 5 * pow10.toDouble();
    return 10 * pow10.toDouble();
  }
}

