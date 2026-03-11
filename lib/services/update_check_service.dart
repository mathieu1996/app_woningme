import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';

enum UpdateMode { none, prompt, enforce }

class UpdateConfig {
  final UpdateMode mode;
  final String? storeUrl;

  const UpdateConfig({required this.mode, this.storeUrl});
}

class UpdateCheckService {
  static Future<UpdateConfig> check() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('app_config')
          .doc('version_check')
          .get();

      if (!doc.exists) return const UpdateConfig(mode: UpdateMode.none);

      final data = doc.data()!;
      final modeStr = data['update_mode'] as String? ?? 'none';
      final minVersion = data['minimum_app_version'] as String? ?? '0.0.0';
      final storeUrl = Platform.isIOS
          ? data['store_url_ios'] as String?
          : data['store_url_android'] as String?;

      final mode = _parseMode(modeStr);
      if (mode == UpdateMode.none) return const UpdateConfig(mode: UpdateMode.none);

      final info = await PackageInfo.fromPlatform();
      final current = info.version;

      if (_isBelow(current, minVersion)) {
        return UpdateConfig(mode: mode, storeUrl: storeUrl);
      }

      return const UpdateConfig(mode: UpdateMode.none);
    } catch (_) {
      return const UpdateConfig(mode: UpdateMode.none);
    }
  }

  static UpdateMode _parseMode(String raw) {
    switch (raw) {
      case 'enforce':
        return UpdateMode.enforce;
      case 'prompt':
        return UpdateMode.prompt;
      default:
        return UpdateMode.none;
    }
  }

  /// Returns true if [current] is strictly below [minimum].
  static bool _isBelow(String current, String minimum) {
    final c = _parts(current);
    final m = _parts(minimum);
    for (var i = 0; i < 3; i++) {
      if (c[i] < m[i]) return true;
      if (c[i] > m[i]) return false;
    }
    return false; // equal → not below
  }

  static List<int> _parts(String version) {
    final segs = version.split('.');
    return List.generate(3, (i) => i < segs.length ? (int.tryParse(segs[i]) ?? 0) : 0);
  }
}
