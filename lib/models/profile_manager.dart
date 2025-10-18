import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_data.dart';

class ProfileManager {
  static const _key = 'user_profile';
  static ProfileData? _cachedProfile;

  static Future<void> setProfile(ProfileData profile) async {
    final prefs = await SharedPreferences.getInstance();
    _cachedProfile = profile;
    final encoded = jsonEncode(profile.toJson());
    await prefs.setString(_key, encoded);
  }

  static ProfileData? getProfile() => _cachedProfile;

  static Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      _cachedProfile = ProfileData.fromJson(jsonDecode(raw));
    }
  }

  static Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    _cachedProfile = null;
  }
}
