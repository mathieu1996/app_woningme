import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BackendUser {
  final int id;
  final String firebaseUid;
  final String email;
  final String? displayName;
  final String createdAt;
  final String lastSeenAt;
  final String plan;

  BackendUser({
    required this.id,
    required this.firebaseUid,
    required this.email,
    this.displayName,
    required this.createdAt,
    required this.lastSeenAt,
    this.plan = 'free',
  });

  factory BackendUser.fromJson(Map<String, dynamic> json) => BackendUser(
        id: json['id'] as int,
        firebaseUid: json['firebase_uid'] as String,
        email: json['email'] as String,
        displayName: json['display_name'] as String?,
        createdAt: json['created_at'] as String,
        lastSeenAt: json['last_seen_at'] as String,
        plan: json['plan'] as String? ?? 'free',
      );
}

class PropertySource {
  final String source;
  final String url;

  const PropertySource({required this.source, required this.url});

  factory PropertySource.fromJson(Map<String, dynamic> json) => PropertySource(
        source: json['source'] as String,
        url: json['url'] as String,
      );
}

class Property {
  final int id;
  final String? source;
  final String? straat;
  final String? postcode;
  final String? stad;
  final String? woningType;
  final int? oppervlakte;
  final int? kamers;
  final String? huurprijsTxt;
  final String? url;
  final String? scrapedAt;
  final String? firstSeenAt;
  final List<PropertySource> sources;

  Property({
    required this.id,
    this.source,
    this.straat,
    this.postcode,
    this.stad,
    this.woningType,
    this.oppervlakte,
    this.kamers,
    this.huurprijsTxt,
    this.url,
    this.scrapedAt,
    this.firstSeenAt,
    this.sources = const [],
  });

  factory Property.fromJson(Map<String, dynamic> json) => Property(
        id: json['id'] as int,
        source: json['source'] as String?,
        straat: json['straat'] as String?,
        postcode: json['postcode'] as String?,
        stad: json['stad'] as String?,
        woningType: json['woning_type'] as String?,
        oppervlakte: json['oppervlakte'] as int?,
        kamers: json['kamers'] as int?,
        huurprijsTxt: json['huurprijs_txt'] as String?,
        url: json['url'] as String?,
        scrapedAt: json['scraped_at'] as String?,
        firstSeenAt: json['first_seen_at'] as String?,
        sources: (json['sources'] as List<dynamic>? ?? [])
            .map((e) => PropertySource.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class SavedSearch {
  final int id;
  final String label;
  final String? city;
  final double? radiusKm;
  final int? minPrijs;
  final int? maxPrijs;
  final int? minKamers;
  final int? minOpp;
  final bool alert;
  final String createdAt;

  SavedSearch({
    required this.id,
    required this.label,
    this.city,
    this.radiusKm,
    this.minPrijs,
    this.maxPrijs,
    this.minKamers,
    this.minOpp,
    this.alert = false,
    required this.createdAt,
  });

  factory SavedSearch.fromJson(Map<String, dynamic> json) => SavedSearch(
        id: json['id'] as int,
        label: json['label'] as String,
        city: json['city'] as String?,
        radiusKm: (json['radius_km'] as num?)?.toDouble(),
        minPrijs: json['min_prijs'] as int?,
        maxPrijs: json['max_prijs'] as int?,
        minKamers: json['min_kamers'] as int?,
        minOpp: json['min_opp'] as int?,
        alert: json['alert'] as bool? ?? false,
        createdAt: json['created_at'] as String,
      );
}


class ApiService {
  static const _baseUrl = 'https://woning.me';

  static Future<String?> _getIdToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return user.getIdToken(false);
  }

  static Future<BackendUser?> syncUser() async {
    try {
      final token = await _getIdToken();
      if (token == null) return null;
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/sync'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        return BackendUser.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      }
    } catch (_) {
      // Non-fatal: backend unreachable
    }
    return null;
  }

  static Future<List<Property>> getProperties({
    String? center,
    double? radiusKm,
    int? minPrijs,
    int? maxPrijs,
    int? minKamers,
    int? minOpp,
    bool nieuw = false,
    String sort = 'scraped_at',
    String order = 'desc',
  }) async {
    final params = <String, String>{};
    if (center != null && center.isNotEmpty) {
      params['center'] = center;
    }
    params['sort'] = sort;
    params['order'] = order;
    if (radiusKm != null) params['radius_km'] = radiusKm.toString();
    if (minPrijs != null) params['min_prijs'] = minPrijs.toString();
    if (maxPrijs != null) params['max_prijs'] = maxPrijs.toString();
    if (minKamers != null) params['min_kamers'] = minKamers.toString();
    if (minOpp != null) params['min_opp'] = minOpp.toString();
    if (nieuw) params['nieuw'] = 'true';

    final uri = Uri.parse('$_baseUrl/api/properties').replace(queryParameters: params.isEmpty ? null : params);
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>;
        return list.map((e) => Property.fromJson(e as Map<String, dynamic>)).toList();
      }
      if (response.statusCode == 404) {
        final detail = (jsonDecode(response.body) as Map<String, dynamic>)['detail'] as String?;
        throw Exception(detail ?? 'Plaatsnaam niet gevonden');
      }
      throw Exception('Kon woningen niet laden (${response.statusCode})');
    } on SocketException {
      try {
        await InternetAddress.lookup('google.com');
        throw Exception('__no_connection__');
      } on SocketException {
        throw Exception('__no_internet__');
      }
    }
  }

  static Future<List<SavedSearch>> getSavedSearches() async {
    final token = await _getIdToken();
    if (token == null) return [];
    final response = await http.get(
      Uri.parse('$_baseUrl/api/saved-searches'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List<dynamic>;
      return list.map((e) => SavedSearch.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  static Future<SavedSearch> createSavedSearch({
    required String label,
    String? city,
    double? radiusKm,
    int? minPrijs,
    int? maxPrijs,
    int? minKamers,
    int? minOpp,
  }) async {
    final token = await _getIdToken();
    if (token == null) throw Exception('Niet ingelogd');
    final response = await http.post(
      Uri.parse('$_baseUrl/api/saved-searches'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'label': label,
        'city': city,
        'radius_km': radiusKm,
        'min_prijs': minPrijs,
        'max_prijs': maxPrijs,
        'min_kamers': minKamers,
        'min_opp': minOpp,
      }),
    );
    if (response.statusCode == 201) {
      return SavedSearch.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Kon zoekfilter niet opslaan (${response.statusCode})');
  }

  static Future<void> deleteSavedSearch(int id) async {
    final token = await _getIdToken();
    if (token == null) return;
    await http.delete(
      Uri.parse('$_baseUrl/api/saved-searches/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  static Future<BackendUser?> getMe() async {
    try {
      final token = await _getIdToken();
      if (token == null) return null;
      final response = await http.get(
        Uri.parse('$_baseUrl/api/auth/me'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        return BackendUser.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      }
    } catch (_) {
      // Non-fatal: backend unreachable
    }
    return null;
  }

  static Future<String> getMagicLink({
    String page = 'account',
    String lang = 'nl',
  }) async {
    final token = await _getIdToken();
    if (token == null) throw Exception('Niet ingelogd');
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/magic-link?page=$page'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final rawUrl = data['url'] as String;
      final uri = Uri.parse(rawUrl);
      return uri.replace(queryParameters: {
        ...uri.queryParameters,
        'lang': lang,
      }).toString();
    }
    throw Exception('Kon link niet genereren (${response.statusCode})');
  }

  static Future<List<String>> getSteden() async {
    final response = await http.get(Uri.parse('$_baseUrl/api/filters'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return (data['steden'] as List<dynamic>).cast<String>();
    }
    return [];
  }

  static Future<void> deleteAccount() async {
    final token = await _getIdToken();
    if (token == null) return;
    await http.delete(
      Uri.parse('$_baseUrl/api/auth/me'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  static Future<void> registerDeviceToken(String deviceToken, {String? language}) async {
    try {
      final idToken = await _getIdToken();
      if (idToken == null) return;
      final platform = _platform();
      final lang = language ?? await _savedLanguage();
      await http.post(
        Uri.parse('$_baseUrl/api/device-tokens'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'token': deviceToken, 'platform': platform, 'language': lang}),
      );
    } catch (_) {
      // Non-fatal
    }
  }

  static Future<String> _savedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('language') ?? 'nl';
  }

  static String? _platform() {
    try {
      if (Platform.isAndroid) return 'android';
      if (Platform.isIOS) return 'ios';
    } catch (_) {}
    return null;
  }

  static Future<SavedSearch> updateSavedSearchAlert(int id, bool alert) async {
    final token = await _getIdToken();
    if (token == null) throw Exception('Niet ingelogd');
    final response = await http.patch(
      Uri.parse('$_baseUrl/api/saved-searches/$id/alert'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'alert': alert}),
    );
    if (response.statusCode == 200) {
      return SavedSearch.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Kon alert niet bijwerken (${response.statusCode})');
  }
}
