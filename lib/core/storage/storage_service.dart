import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/rewards/domain/player_profile.dart';
import '../constants/game_constants.dart';

class StorageService {
  static final StorageService instance = StorageService._();
  StorageService._();

  late Box<String> _playerBox;
  late SharedPreferences _prefs;

  Future<void> initialize() async {
    await Hive.initFlutter();
    _playerBox = await Hive.openBox<String>(GameConstants.playerBoxKey);
    _prefs = await SharedPreferences.getInstance();
  }

  PlayerProfile loadPlayerProfile() {
    final rawJson = _playerBox.get('profile');
    if (rawJson == null) {
      return const PlayerProfile();
    }
    try {
      final map = jsonDecode(rawJson) as Map<String, dynamic>;
      return PlayerProfile.fromJson(map);
    } catch (_) {
      return const PlayerProfile();
    }
  }

  Future<void> savePlayerProfile(PlayerProfile profile) async {
    final rawJson = jsonEncode(profile.toJson());
    await _playerBox.put('profile', rawJson);
  }

  bool get soundEnabled => _prefs.getBool('sound_enabled') ?? true;
  Future<void> setSoundEnabled(bool enabled) async {
    await _prefs.setBool('sound_enabled', enabled);
  }
}
