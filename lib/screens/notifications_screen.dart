import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'home_screen.dart';
import 'search_criteria_screen.dart';
import 'thematic_map_screen.dart';
import '../services/school_service.dart';
import '../services/auth_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final int _currentIndex = 1;
  final _schoolService = SchoolService();
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios, size: 24),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
            ),

            // Notification List
            Expanded(
              child: user == null 
                ? const Center(child: Text('Please log in to see notifications'))
                : StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _schoolService.getNotificationsStream(user.uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      final notifications = snapshot.data ?? [];
                      
                      if (notifications.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.notifications_none, size: 64, color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              const Text(
                                'No notifications yet',
                                style: TextStyle(color: Colors.grey, fontSize: 18),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Submit an application to receive updates',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final notification = notifications[index];
                          final type = notification['type'] ?? 'info';
                          final id = notification['id'];
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: _buildNotificationCard(
                              id: id,
                              icon: _getIconForType(type),
                              iconColor: _getColorForType(type),
                              iconBgColor: _getColorForType(type).withAlpha(25),
                              title: notification['title'] ?? 'Update',
                              description: notification['message'] ?? '',
                              actionButton: type == 'acceptance' 
                                ? Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2B3346),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Confirm Attendance',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  )
                                : null,
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFD6EBE8),
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HomeScreen()));
          } else if (index == 2) {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ThematicMapScreen()));
          } else if (index == 3) {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => SearchCriteriaScreen()));
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.house), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.bell_fill), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.public), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.plus_app), label: 'Add'),
        ],
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'acceptance': return Icons.calendar_today;
      case 'processed': return Icons.check_circle_outline;
      case 'congratulations': return Icons.check_circle;
      default: return Icons.info_outline;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'acceptance': return Colors.deepPurple;
      case 'processed': return Colors.blue;
      case 'congratulations': return Colors.orange;
      default: return Colors.orange;
    }
  }

  Widget _buildNotificationCard({
    required String id,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String description,
    Widget? actionButton,
    Widget? customContent,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.black, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2B3346),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _schoolService.deleteNotification(id),
                          child: const Icon(Icons.close, color: Colors.grey, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (actionButton != null) ...[
            const SizedBox(height: 16),
            actionButton,
          ],
          customContent ?? const SizedBox.shrink(),
        ],
      ),
    );
  }
}
