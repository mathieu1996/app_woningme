import 'package:cloud_firestore/cloud_firestore.dart';

class AppFeatures {
  final bool alerts;

  const AppFeatures({this.alerts = false});

  factory AppFeatures.fromMap(Map<String, dynamic> data) {
    return AppFeatures(
      alerts: data['alerts'] as bool? ?? false,
    );
  }
}

class AppFeaturesService {
  static const _collection = 'app_features';
  static const _document = 'config';

  static Future<AppFeatures> get() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(_collection)
          .doc(_document)
          .get();
      if (doc.exists && doc.data() != null) {
        return AppFeatures.fromMap(doc.data()!);
      }
    } catch (e) {
      // ignore: avoid_print
      print('[AppFeaturesService] fetch failed: $e');
    }
    return const AppFeatures();
  }
}
