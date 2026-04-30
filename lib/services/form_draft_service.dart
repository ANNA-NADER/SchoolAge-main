import 'package:flutter/foundation.dart';

class FormDraftService extends ChangeNotifier {
  static final FormDraftService _instance = FormDraftService._internal();
  factory FormDraftService() => _instance;
  FormDraftService._internal();

  // Student Info Draft
  String? fullName;
  String? emergencyName;
  String? emergencyPhone;
  String? dob;
  String? previousSchool;
  String? selectedGrade;
  Uint8List? birthCertificateBytes;
  String? birthCertificateName;
  Uint8List? vaccinationRecordBytes;
  String? vaccinationRecordName;

  // Parent Info Draft
  Uint8List? nationalIdBytes;
  String? nationalIdFileName;

  // Metadata
  bool _isFormActive = false; // To hide bubble when on form screen
  String? _currentStep = 'none'; // 'application', 'parent_info', 'none'
  String? _schoolId;
  String? _schoolName;

  bool get hasDraft => _currentStep != 'none';
  bool get isFormActive => _isFormActive;
  String? get currentStep => _currentStep;
  String? get schoolId => _schoolId;
  String? get schoolName => _schoolName;

  void setFormActive(bool active) {
    _isFormActive = active;
    notifyListeners();
  }

  void startApplication(String id, String name) {
    _schoolId = id;
    _schoolName = name;
    _currentStep = 'application';
    notifyListeners();
  }

  void updateApplication({
    String? name,
    String? eName,
    String? ePhone,
    String? dateOfBirth,
    String? pSchool,
    String? grade,
    Uint8List? bCert,
    String? bCertName,
    Uint8List? vRec,
    String? vRecName,
  }) {
    if (name != null) fullName = name;
    if (eName != null) emergencyName = eName;
    if (ePhone != null) emergencyPhone = ePhone;
    if (dateOfBirth != null) dob = dateOfBirth;
    if (pSchool != null) previousSchool = pSchool;
    if (grade != null) selectedGrade = grade;
    if (bCert != null) birthCertificateBytes = bCert;
    if (bCertName != null) birthCertificateName = bCertName;
    if (vRec != null) vaccinationRecordBytes = vRec;
    if (vRecName != null) vaccinationRecordName = vRecName;
    notifyListeners();
  }

  void moveToParentInfo() {
    _currentStep = 'parent_info';
    notifyListeners();
  }

  void updateParentInfo(Uint8List? bytes, String? name) {
    nationalIdBytes = bytes;
    nationalIdFileName = name;
    notifyListeners();
  }

  void clearDraft() {
    fullName = null;
    emergencyName = null;
    emergencyPhone = null;
    dob = null;
    previousSchool = null;
    selectedGrade = null;
    birthCertificateBytes = null;
    birthCertificateName = null;
    vaccinationRecordBytes = null;
    vaccinationRecordName = null;
    nationalIdBytes = null;
    nationalIdFileName = null;
    _schoolId = null;
    _schoolName = null;
    _currentStep = 'none';
    _isFormActive = false;
    notifyListeners();
  }
}
