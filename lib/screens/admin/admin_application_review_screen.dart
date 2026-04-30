import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/school_service.dart';

class AdminApplicationReviewScreen extends StatefulWidget {
  final Map<String, dynamic> application;
  final String schoolName;

  const AdminApplicationReviewScreen({
    super.key,
    required this.application,
    required this.schoolName,
  });

  @override
  State<AdminApplicationReviewScreen> createState() => _AdminApplicationReviewScreenState();
}

class _AdminApplicationReviewScreenState extends State<AdminApplicationReviewScreen> {
  final _schoolService = SchoolService();
  bool _isProcessing = false;

  Future<void> _updateStatus(String status, {Map<String, dynamic>? extraData}) async {
    setState(() => _isProcessing = true);
    try {
      await _schoolService.updateApplicationStatus(widget.application['id'], status, extraData: extraData);
      
      // If acceptance/meeting, send real notification
      if (status == 'meeting_scheduled') {
        final childName = widget.application['studentInfo']?['fullName'] ?? 'your child';
        await _schoolService.sendNotification(
          userId: widget.application['userId'],
          title: 'Meeting Scheduled',
          message: 'A meeting has been scheduled for $childName at ${widget.schoolName} on ${extraData?['meetingTime'] ?? 'a scheduled date'}.',
          type: 'acceptance',
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status updated to $status')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final student = widget.application['studentInfo'] ?? {};
    final status = widget.application['status'] ?? 'pending';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Review Application'),
        backgroundColor: const Color(0xFFD6EBE8),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Student Information'),
            _buildInfoRow('Full Name', student['fullName']),
            _buildInfoRow('Grade', student['grade']),
            _buildInfoRow('Date of Birth', student['dob']),
            _buildInfoRow('Emergency Phone', student['emergencyPhone']),
            
            const SizedBox(height: 32),
            _buildSectionTitle('Uploaded Documents'),
            _buildDocThumbnail('Birth Certificate', student['birthCertificateUrl']),
            _buildDocThumbnail('Vaccination Record', student['vaccinationRecordUrl']),
            
            const SizedBox(height: 32),
            _buildSectionTitle('Payment Proof'),
            // Note: In a real app, the InstaPay screenshot would be saved in the application doc
            _buildDocThumbnail('InstaPay Screenshot', widget.application['paymentScreenshotUrl']),

            const SizedBox(height: 48),
            if (_isProcessing)
              const Center(child: CircularProgressIndicator())
            else
              _buildActionButtons(status),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2B3346)),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          Text(value ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildDocThumbnail(String label, String? url) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.description_outlined, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          if (url != null)
            TextButton(
              onPressed: () => _viewDocument(url, label),
              child: const Text('View'),
            )
          else
            const Text('Not Uploaded', style: TextStyle(color: Colors.red, fontSize: 12)),
        ],
      ),
    );
  }

  void _viewDocument(String url, String title) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(title: Text(title), leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))),
            Flexible(
              child: Image.network(
                url,
                errorBuilder: (context, error, stackTrace) => const Center(child: Text('Image not found in cloud')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(String currentStatus) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (currentStatus == 'pending')
          ElevatedButton(
            onPressed: () => _updateStatus('paid'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
            child: const Text('Verify Payment & Mark Paid'),
          ),
        const SizedBox(height: 12),
        if (currentStatus == 'paid' || currentStatus == 'pending')
          ElevatedButton(
            onPressed: _showMeetingPicker,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
            child: const Text('Schedule Meeting & Accept'),
          ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => _updateStatus('rejected'),
          style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red), padding: const EdgeInsets.symmetric(vertical: 16)),
          child: const Text('Reject Application'),
        ),
      ],
    );
  }

  void _showMeetingPicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null && mounted) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 10, minute: 0),
      );

      if (time != null && mounted) {
        final meetingStr = "${DateFormat('EEEE, MMM dd').format(picked)} at ${time.format(context)}";
        _updateStatus('meeting_scheduled', extraData: {'meetingTime': meetingStr});
      }
    }
  }
}
