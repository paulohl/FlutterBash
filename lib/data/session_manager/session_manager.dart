import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xueli/constants/app_constants.dart';
import 'package:xueli/models/teacher_model.dart';

import '../providers/shared_prefs_provider.dart';

final sessionManagerProvider = Provider((ref) {
  final preference = ref.watch(sharedPreferencesProvider);
  return SessionManager(preference);
});

class SessionManager {
  final SharedPreferences _preferences;

  SessionManager(this._preferences);

  Future<bool> saveFormatAudioMode(String mode) async {
    return await _preferences.setString("FormatAudioMode", mode);
  }

  String getFormatAudioMode() {
    return _preferences.getString("FormatAudioMode") ??
        AudioMode.englishAndChinese;
  }

  Future<bool> saveFormatTextInterval(int mode) async {
    return await _preferences.setInt("FormatTextInterval", mode);
  }

  int getFormatTextInterval() {
    return _preferences.getInt("FormatTextInterval") ?? 1;
  }

  Future<bool> saveFormatENGCHNInterval(int mode) async {
    return await _preferences.setInt("FormatENGCHNInterval", mode);
  }

  int getFormatENGCHNInterval() {
    return _preferences.getInt("FormatENGCHNInterval") ?? 1;
  }

  Future<bool> saveFormat8AudioMode(String mode) async {
    return await _preferences.setString("Format8AudioMode", mode);
  }

  String getForma8tAudioMode() {
    return _preferences.getString("Format8AudioMode") ??
        AudioMode.englishAndChinese;
  }

  Future<bool> saveFormat8TextInterval(int mode) async {
    return await _preferences.setInt("Format8TextInterval", mode);
  }

  int getFormat8TextInterval() {
    return _preferences.getInt("Format8TextInterval") ?? 1;
  }

  Future<bool> saveFormat8ENGCHNInterval(int mode) async {
    return await _preferences.setInt("Format8ENGCHNInterval", mode);
  }

  int getFormat8ENGCHNInterval() {
    return _preferences.getInt("Format8ENGCHNInterval") ?? 1;
  }

  Future<bool> saveSLAudioMode(String mode) async {
    return await _preferences.setString("SLAudioMode", mode);
  }

  String getSLAudioMode() {
    return _preferences.getString("SLAudioMode") ?? AudioMode.englishAndChinese;
  }

  Future<bool> saveSLTextInterval(int mode) async {
    return await _preferences.setInt("SLTextInterval", mode);
  }

  int getSLTextInterval() {
    return _preferences.getInt("SLTextInterval") ?? 1;
  }

  Future<bool> saveSLENGCHNInterval(int mode) async {
    return await _preferences.setInt("SLENGCHNInterval", mode);
  }

  int getSLENGCHNInterval() {
    return _preferences.getInt("SLENGCHNInterval") ?? 1;
  }

  Future<bool> saveCLAudioMode(String mode) async {
    return await _preferences.setString("CLAudioMode", mode);
  }

  String getCLAudioMode() {
    return _preferences.getString("CLAudioMode") ?? AudioMode.englishAndChinese;
  }

  Future<bool> saveCLTextInterval(int mode) async {
    return await _preferences.setInt("CLTextInterval", mode);
  }

  int getCLTextInterval() {
    return _preferences.getInt("CLTextInterval") ?? 1;
  }

  Future<bool> saveCLENGCHNInterval(int mode) async {
    return await _preferences.setInt("CLENGCHNInterval", mode);
  }

  int getCLENGCHNInterval() {
    return _preferences.getInt("CLENGCHNInterval") ?? 1;
  }

  Future<bool> saveTeacherProfile(TeacherModel teacher) async {
    final String encodedData = TeacherModel.encode(teacher);
    return await _preferences.setString("teacher", encodedData);
  }

  TeacherModel? getTeacherProfile() {
    final encodedData = _preferences.getString("teacher");
    if (encodedData != null) {
      return TeacherModel.decode(encodedData);
    }
    return null;
  }

  Future<bool> deleteSession() {
    // _preferences.remove("token");
    // return _preferences.remove("account");
    return _preferences.clear();
  }
}
