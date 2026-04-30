import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/school_service.dart';
import '../../services/auth_service.dart';
import 'admin_application_review_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final String schoolId;
  final String schoolName;

  const AdminDashboardScreen({
    super.key, 
    required this.schoolId,
    required this.schoolName,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _schoolService = SchoolService();
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Admin Dashboard', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(widget.schoolName, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
        backgroundColor: const Color(0xFFD6EBE8),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              if (!context.mounted) return;
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _schoolService.getSchoolApplicationsStream(widget.schoolId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final applications = snapshot.data ?? [];

          if (applications.isEmpty) {
            return const Center(
              child: Text('No applications yet for this school'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: applications.length,
            itemBuilder: (context, index) {
              final app = applications[index];
              final studentInfo = app['studentInfo'] ?? {};
              final status = app['status'] ?? 'pending';
              final createdAt = app['createdAt'];

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 2,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    studentInfo['fullName'] ?? 'Unknown Student',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Grade: ${studentInfo['grade'] ?? 'N/A'}'),
                      Text(
                        'Submitted: ${createdAt != null ? DateFormat('MMM dd, yyyy').format(createdAt.toDate()) : 'Recently'}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: _buildStatusChip(status),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AdminApplicationReviewScreen(
                          application: app,
                          schoolName: widget.schoolName,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'paid': color = Colors.green; break;
      case 'approved': color = Colors.blue; break;
      case 'meeting_scheduled': color = Colors.purple; break;
      case 'rejected': color = Colors.red; break;
      default: color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10),
      ),
    );
  }
}
