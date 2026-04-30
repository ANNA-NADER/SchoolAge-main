import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'home_screen.dart';
import 'notifications_screen.dart';
import 'search_criteria_screen.dart';
import 'thematic_map_screen.dart';
import 'payment_methods_screen.dart';
import '../services/auth_service.dart';
import '../services/school_service.dart';
import '../services/form_draft_service.dart';
import 'package:image_picker/image_picker.dart';

class ParentInfoScreen extends StatefulWidget {
  const ParentInfoScreen({super.key});

  @override
  State<ParentInfoScreen> createState() => _ParentInfoScreenState();
}

class _ParentInfoScreenState extends State<ParentInfoScreen> {
  final _schoolService = SchoolService();
  final _authService = AuthService();
  final int _currentIndex = 3;

  Uint8List? _nationalIdBytes;
  String? _nationalIdFileName;
  bool _isSubmitting = false;

  final _draftService = FormDraftService();

  @override
  void initState() {
    super.initState();
    _draftService.setFormActive(true);
    _loadDraft();
  }

  @override
  void dispose() {
    _draftService.setFormActive(false);
    super.dispose();
  }

  void _loadDraft() {
    _nationalIdBytes = _draftService.nationalIdBytes;
    _nationalIdFileName = _draftService.nationalIdFileName;
  }

  Future<void> _pickNationalId() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
      
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _nationalIdBytes = bytes;
          _nationalIdFileName = image.name;
          _draftService.updateParentInfo(bytes, image.name);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _submitInfo() async {
    if (_nationalIdBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload National ID')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = _authService.currentUser;
      if (user == null) throw Exception('No user logged in');

      // Upload file
      String sanitizeFileName(String name) {
        return name.split(RegExp(r'[\\/]')).last.replaceAll(RegExp(r'[^a-zA-Z0-9.\-]'), '_');
      }
      final safeName = sanitizeFileName(_nationalIdFileName ?? 'national_id.png');
      
      await _schoolService.uploadFile(
        _nationalIdBytes!,
        '${DateTime.now().millisecondsSinceEpoch}_$safeName',
        'parent_docs/${user.uid}'
      );

      // Success
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Success'),
            content: const Text('Your information has been submitted successfully!'),
            actions: [
              TextButton(
                onPressed: () {
                  _draftService.clearDraft();
                  Navigator.pop(context); // Close dialog
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const PaymentMethodsScreen()),
                  );
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _handleNavigation(int index) async {
    if (!mounted) return;
    if (index == 0) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else if (index == 1) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationsScreen()));
    } else if (index == 2) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ThematicMapScreen()));
    } else if (index == 3) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => SearchCriteriaScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Parent Information'),
        backgroundColor: const Color(0xFFD6EBE8),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'National ID Upload',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please upload a clear photo of your National ID card (Front & Back).',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: _pickNationalId,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300, width: 2, style: BorderStyle.solid),
                ),
                child: _nationalIdBytes != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.memory(_nationalIdBytes!, fit: BoxFit.cover),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_upload_outlined, size: 48, color: Colors.grey),
                          SizedBox(height: 12),
                          Text('Tap to upload National ID', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
              ),
            ),
            if (_nationalIdFileName != null) ...[
              const SizedBox(height: 8),
              Text('Selected: $_nationalIdFileName', style: const TextStyle(fontSize: 12, color: Colors.green)),
            ],
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitInfo,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF333333),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: _isSubmitting
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Continue to Payment', style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _handleNavigation,
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFD6EBE8),
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.house), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.bell), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.public), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.plus_app_fill), label: 'Add'),
        ],
      ),
    );
  }
}
