import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;
  final bool calendarConnected;

  User({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
    this.calendarConnected = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'photoUrl': photoUrl,
    'calendarConnected': calendarConnected,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] ?? '',
    email: json['email'] ?? '',
    name: json['name'],
    photoUrl: json['photoUrl'],
    calendarConnected: json['calendarConnected'] ?? false,
  );
}

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const String _userKey = 'current_user';
  static const String _tokenKey = 'auth_token';

  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    final token = prefs.getString(_tokenKey);

    if (userJson != null && token != null) {
      try {
        _currentUser = User.fromJson(jsonDecode(userJson));
        notifyListeners();
      } catch (e) {
        debugPrint('Error loading user from prefs: $e');
        await _clearStorage();
      }
    }
  }

  Future<bool> registerWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Simulate registration delay
      await Future.delayed(const Duration(milliseconds: 800));

      _currentUser = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        name: name,
      );

      await _saveToStorage();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Registration Error: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Simulate login delay
      await Future.delayed(const Duration(milliseconds: 800));

      _currentUser = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        name: email.split('@').first,
      );

      await _saveToStorage();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Login Error: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Simulate Google sign-in delay
      await Future.delayed(const Duration(milliseconds: 800));

      _currentUser = User(
        id: 'google_user_${DateTime.now().millisecondsSinceEpoch}',
        email: 'user@gmail.com',
        name: 'Google User',
      );

      await _saveToStorage();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Google Sign In Error: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signOut() async {
    _currentUser = null;
    await _clearStorage();
    notifyListeners();
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    if (_currentUser != null) {
      await prefs.setString(_userKey, jsonEncode(_currentUser!.toJson()));
      await prefs.setString(_tokenKey, 'mock_token');
    }
  }

  Future<void> _clearStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_tokenKey);
  }
}
