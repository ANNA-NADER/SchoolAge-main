import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'home_screen.dart';
import 'notifications_screen.dart';
import 'search_criteria_screen.dart';
import 'parent_info_screen.dart';
import 'thematic_map_screen.dart';

import '../services/school_service.dart';
import '../services/auth_service.dart';
import '../services/form_draft_service.dart';

class ApplicationScreen extends StatefulWidget {
  final String schoolId;
  final String schoolName;

  const ApplicationScreen({
    super.key,
    this.schoolId = '',
    this.schoolName = '',
  });

  @override
  State<ApplicationScreen> createState() => _ApplicationScreenState();
}

class _ApplicationScreenState extends State<ApplicationScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emergencyNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _emergencyPhoneController = TextEditingController(text: '01');
  final TextEditingController _previousSchoolController = TextEditingController();
  
  String? _selectedGrade;
  final List<String> _grades = [
    'Kindergarten',
    '1st Primary',
    '2nd Primary',
    '3rd Primary',
    '4th Primary',
    '5th Primary',
    '6th Primary',
    '1st Preparatory',
    '2nd Preparatory',
    '3rd Preparatory',
    '1st Secondary',
    '2nd Secondary',
    '3rd Secondary',
  ];
  bool _isSubmitting = false;
  String? _phoneError;
  String? _fullNameError;
  String? _gradeError;
  String? _emergencyNameError;
  String? _dobError;

  Uint8List? _birthCertificateBytes;
  String? _birthCertificateName;

  Uint8List? _vaccinationRecordBytes;
  String? _vaccinationRecordName;

  final _draftService = FormDraftService();

  @override
  void initState() {
    super.initState();
    _draftService.setFormActive(true);
    _loadDraft();
    _setupListeners();
  }

  void _loadDraft() {
    if (_draftService.schoolId == widget.schoolId) {
      _fullNameController.text = _draftService.fullName ?? '';
      _emergencyNameController.text = _draftService.emergencyName ?? '';
      _emergencyPhoneController.text = _draftService.emergencyPhone ?? '01';
      _dobController.text = _draftService.dob ?? '';
      _previousSchoolController.text = _draftService.previousSchool ?? '';
      _selectedGrade = _draftService.selectedGrade;
      _birthCertificateBytes = _draftService.birthCertificateBytes;
      _birthCertificateName = _draftService.birthCertificateName;
      _vaccinationRecordBytes = _draftService.vaccinationRecordBytes;
      _vaccinationRecordName = _draftService.vaccinationRecordName;
    } else {
      // New school application, start fresh draft
      _draftService.startApplication(widget.schoolId, widget.schoolName);
    }
  }

  void _setupListeners() {
    _fullNameController.addListener(() => _draftService.updateApplication(name: _fullNameController.text));
    _emergencyNameController.addListener(() => _draftService.updateApplication(eName: _emergencyNameController.text));
    _emergencyPhoneController.addListener(() => _draftService.updateApplication(ePhone: _emergencyPhoneController.text));
    _dobController.addListener(() => _draftService.updateApplication(dateOfBirth: _dobController.text));
    _previousSchoolController.addListener(() => _draftService.updateApplication(pSchool: _previousSchoolController.text));
  }

  Uint8List? _medicalInfoBytes;
  String? _medicalInfoName;

  Future<void> _pickImage(String type) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 15, // Highly compress to ensure it fits in Firestore as Base64 if needed
      maxWidth: 800,
    );
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        if (type == 'birth') {
          _birthCertificateBytes = bytes;
          _birthCertificateName = image.name;
          _draftService.updateApplication(bCert: bytes, bCertName: image.name);
        } else if (type == 'vaccination') {
          _vaccinationRecordBytes = bytes;
          _vaccinationRecordName = image.name;
          _draftService.updateApplication(vRec: bytes, vRecName: image.name);
        } else if (type == 'medical') {
          _medicalInfoBytes = bytes;
          _medicalInfoName = image.name;
        }
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 4)),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  void dispose() {
    _draftService.setFormActive(false);
    _fullNameController.dispose();
    _emergencyNameController.dispose();
    _dobController.dispose();
    _emergencyPhoneController.dispose();
    _previousSchoolController.dispose();
    super.dispose();
  }

  Widget _buildLabeledDropdown(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged, {
    String? errorText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              border: Border.all(color: errorText != null ? Colors.red : Colors.black87, width: 1.0),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                hint: const Text('Select Grade', style: TextStyle(fontSize: 14)),
                style: const TextStyle(fontSize: 14, color: Colors.black),
                items: items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                errorText,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLabeledTextField(
    String label, 
    TextEditingController controller, {
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool readOnly = false,
    VoidCallback? onTap,
    String? errorText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              border: Border.all(color: errorText != null ? Colors.red : Colors.black87, width: 1.0),
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              readOnly: readOnly,
              onTap: onTap,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                isDense: true,
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                errorText,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUploadSection(String label, String type, String? selectedFileName) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              InkWell(
                onTap: () => _pickImage(type),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    border: Border.all(color: Colors.black87, width: 1.0),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    selectedFileName != null ? 'change photo' : 'upload photo',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (selectedFileName != null) ...[
                const SizedBox(width: 8),
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    selectedFileName,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
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
              const Text(
                'Application',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Child Personal Information',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              // Illustration
              Center(
                child: Image.asset(
                  'assets/images/illustration.png',
                  height: 140,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback if the image doesn't exist
                    return Container(
                      height: 140,
                      width: 140,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.image, size: 50, color: Colors.grey),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              _buildLabeledTextField('Full Name', _fullNameController, errorText: _fullNameError),
              _buildLabeledDropdown(
                'Grade Applying for', 
                _selectedGrade,
                _grades,
                (value) {
                  setState(() {
                    _selectedGrade = value;
                  });
                },
                errorText: _gradeError,
              ),
              _buildLabeledTextField('Emergency Contact Name', _emergencyNameController, errorText: _emergencyNameError),
              _buildLabeledTextField(
                'Date of Birth', 
                _dobController,
                errorText: _dobError,
                readOnly: true,
                onTap: () => _selectDate(context),
              ),
              _buildLabeledTextField(
                'Emergency Phone Number', 
                _emergencyPhoneController,
                errorText: _phoneError,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    if (!newValue.text.startsWith('01')) {
                      return oldValue;
                    }
                    return newValue;
                  }),
                ],
              ),
              _buildLabeledTextField(
                'Previous School (if any)', 
                _previousSchoolController,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))],
              ),
              const SizedBox(height: 8),
              _buildUploadSection('Copy of Birth Certificate', 'birth', _birthCertificateName),
              _buildUploadSection('Vaccination Record', 'vaccination', _vaccinationRecordName),
              _buildUploadSection('Medical Information (basic)', 'medical', _medicalInfoName),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : () async {
                    setState(() {
                      _fullNameError = null;
                      _gradeError = null;
                      _draftService.updateApplication(grade: _selectedGrade);
                      _emergencyNameError = null;
                      _phoneError = null;
                      _dobError = null;
                    });

                    bool hasError = false;

                    if (_fullNameController.text.trim().split(' ').length < 2) {
                      setState(() => _fullNameError = 'Please enter at least two names');
                      hasError = true;
                    }

                    if (_selectedGrade == null) {
                      setState(() => _gradeError = 'Grade is required');
                      hasError = true;
                    }

                    if (_emergencyNameController.text.trim().split(' ').length < 2) {
                      setState(() => _emergencyNameError = 'Please enter at least two names');
                      hasError = true;
                    }

                    if (_emergencyPhoneController.text.length != 11) {
                      setState(() => _phoneError = 'Emergency number must be 11 numbers exactly');
                      hasError = true;
                    }

                    if (_dobController.text.isEmpty) {
                      setState(() => _dobError = 'Date of birth is required');
                      hasError = true;
                    }

                    if (hasError) return;
                    
                    setState(() {
                      _isSubmitting = true;
                    });

                    try {
                      String? birthCertUrl;
                      String? vaccinationUrl;
                      String? medicalUrl;
                      
                      final schoolService = SchoolService();
                      final authService = AuthService();
                      final user = authService.currentUser;
                      
                      if (user == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please log in to submit application')),
                        );
                        setState(() {
                          _isSubmitting = false;
                        });
                        return;
                      }
                      
                      String sanitizeFileName(String name) {
                        return name.split(RegExp(r'[\\/]')).last.replaceAll(RegExp(r'[^a-zA-Z0-9.\-]'), '_');
                      }
                      
                      Future<String?> uploadImage(Uint8List? bytes, String? name, String folder) async {
                        if (bytes == null) return null;
                        final safeName = sanitizeFileName(name ?? 'image.png');
                        return await schoolService.uploadFile(
                          bytes, 
                          '${DateTime.now().millisecondsSinceEpoch}_$safeName', 
                          'applications/$folder'
                        );
                      }

                      // Upload files in parallel to save time
                      final uploadResults = await Future.wait([
                        uploadImage(_birthCertificateBytes, _birthCertificateName, 'birth_certificates'),
                        uploadImage(_vaccinationRecordBytes, _vaccinationRecordName, 'vaccinations'),
                        uploadImage(_medicalInfoBytes, _medicalInfoName, 'medical_info'),
                      ]);
                      
                      birthCertUrl = uploadResults[0];
                      vaccinationUrl = uploadResults[1];
                      medicalUrl = uploadResults[2];

                      final studentInfo = {
                        'fullName': _fullNameController.text.trim(),
                        'grade': _selectedGrade,
                        'emergencyContactName': _emergencyNameController.text.trim(),
                        'dob': _dobController.text.trim(),
                        'emergencyPhone': _emergencyPhoneController.text.trim(),
                        'previousSchool': _previousSchoolController.text.trim(),
                        'birthCertificateUrl': birthCertUrl,
                        'vaccinationRecordUrl': vaccinationUrl,
                        'medicalInfoUrl': medicalUrl,
                      };
                      
                      await schoolService.submitApplication(
                        userId: user.uid,
                        schoolId: widget.schoolId,
                        studentInfo: studentInfo,
                      );

                      _draftService.moveToParentInfo();
                      
                      if (context.mounted) {
                        // Navigate to Success Screen
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ParentInfoScreen()),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to submit application: $e')),
                        );
                      }
                    } finally {
                      if (context.mounted) {
                        setState(() {
                          _isSubmitting = false;
                        });
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF333333),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting 
                      ? const SizedBox(
                          height: 20, 
                          width: 20, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        )
                      : const Text(
                          'submit',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _handleNavigation,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFD6EBE8), // light teal
        selectedItemColor: Colors.black87,
        unselectedItemColor: Colors.black54,
        showSelectedLabels: false,
        showUnselectedLabels: false,
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
}


