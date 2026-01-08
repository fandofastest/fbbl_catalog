import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';
  final AuthService _service;

  AuthUser? _user;
  String? _token;
  bool _loading = false;
  String? _error;

  AuthProvider({AuthService? service}) : _service = service ?? AuthService();

  AuthUser? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _user != null && _token != null;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    final rawUser = prefs.getString(_userKey);
    if (rawUser != null) {
      try {
        final map = jsonDecode(rawUser);
        if (map is Map<String, dynamic>) {
          _user = AuthUser.fromJson(map);
        }
      } catch (_) {
        await prefs.remove(_userKey);
      }
    }
    notifyListeners();
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
  }) async {
    if (_loading) return false;
    _setLoading(true);
    try {
      final result = await _service.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        address: address,
      );
      await _persistSession(result.user, result.token);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    if (_loading) return false;
    _setLoading(true);
    try {
      final result = await _service.login(email: email, password: password);
      await _persistSession(result.user, result.token);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    notifyListeners();
  }

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  Future<void> _persistSession(AuthUser user, String token) async {
    _user = user;
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  void _setLoading(bool value) {
    _loading = value;
    if (value) _error = null;
    notifyListeners();
  }
}
