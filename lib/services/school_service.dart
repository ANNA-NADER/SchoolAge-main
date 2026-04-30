import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import 'dart:convert';

class SchoolService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get all schools stream
  Stream<List<Map<String, dynamic>>> getSchoolsStream() {
    return _db.collection('schools').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    });
  }

  // Get schools by governorate
  Future<List<Map<String, dynamic>>> getSchoolsByGovernorate(String governorate) async {
    QuerySnapshot snapshot = await _db
        .collection('schools')
        .where('governorate', isEqualTo: governorate)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        ...data,
      };
    }).toList();
  }

  // Upload file
  Future<String> uploadFile(Uint8List fileBytes, String fileName, String folder) async {
    try {
      _storage.setMaxUploadRetryTime(const Duration(seconds: 4));
      final ref = _storage.ref().child('$folder/$fileName');
      final uploadTask = await ref.putData(fileBytes);
      return await uploadTask.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      if (e.code == 'retry-limit-exceeded') {
        // Fallback: If Web CORS blocks the upload, convert the image to a Base64 string 
        // and store it directly in Firestore instead of Firebase Storage.
        final base64String = base64Encode(fileBytes);
        return 'data:image/png;base64,$base64String';
      }
      throw Exception('Failed to upload file: ${e.message}');
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  // Submit application
  Future<void> submitApplication({
    required String userId,
    required String schoolId,
    required Map<String, dynamic> studentInfo,
  }) async {
    await _db.collection('applications').add({
      'userId': userId,
      'schoolId': schoolId,
      'studentInfo': studentInfo,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Send notification
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String message,
    String type = 'info',
  }) async {
    await _db.collection('notifications').add({
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    await _db.collection('notifications').doc(notificationId).delete();
  }

  // Get notifications stream
  Stream<List<Map<String, dynamic>>> getNotificationsStream(String userId) {
    return _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final docs = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      
      // Sort by creation time newest first
      docs.sort((a, b) {
        final aTime = (a['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
        final bTime = (b['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
        return bTime.compareTo(aTime);
      });
      // Filter to keep only unique titles (latest one)
      final Map<String, Map<String, dynamic>> uniqueNotifications = {};
      for (var doc in docs) {
        final title = doc['title'] ?? 'Update';
        if (!uniqueNotifications.containsKey(title)) {
          uniqueNotifications[title] = doc;
        }
      }

      return uniqueNotifications.values.toList();
    });
  }

  // Get all user's applications with school info stream
  Stream<List<Map<String, dynamic>>> getUserApplicationsStream(String userId) {
    return _db
        .collection('applications')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> results = [];
      
      for (var doc in snapshot.docs) {
        final appData = doc.data();
        final schoolId = appData['schoolId'];

        // Fetch school info
        final schoolDoc = await _db.collection('schools').doc(schoolId).get();
        final schoolData = schoolDoc.data() ?? {};

        results.add({
          'id': doc.id,
          'application': appData,
          'school': schoolData,
        });
      }
      
      // Sort in memory by creation time (newest first)
      results.sort((a, b) {
        final aTime = (a['application']['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
        final bTime = (b['application']['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
        return bTime.compareTo(aTime);
      });
      
      return results;
    });
  }

  // Get all applications for a specific school (for Admin)
  Stream<List<Map<String, dynamic>>> getSchoolApplicationsStream(String schoolId) {
    return _db
        .collection('applications')
        .where('schoolId', isEqualTo: schoolId)
        .snapshots()
        .map((snapshot) {
      final docs = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      
      // Sort newest first
      docs.sort((a, b) {
        final aTime = (a['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
        final bTime = (b['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
        return bTime.compareTo(aTime);
      });
      
      return docs;
    });
  }

  // Update application status and info (for Admin)
  Future<void> updateApplicationStatus(String applicationId, String status, {Map<String, dynamic>? extraData}) async {
    final Map<String, Object?> updates = {
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (extraData != null) {
      updates.addAll(extraData);
    }
    await _db.collection('applications').doc(applicationId).update(Map<String, Object?>.from(updates));
  }
}
