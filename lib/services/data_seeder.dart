import 'package:flutter/foundation.dart';

class DataSeeder {
  /// This function has been disabled to prevent it from overwriting 
  /// manually fixed cloud data with stale local JSON assets.
  static Future<void> seedDataIfNeeded() async {
    // Disabled to prevent data reverts.
    if (kDebugMode) {
      print('DataSeeder is currently disabled to protect database integrity.');
    }
    return;
  }
}
