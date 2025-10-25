import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock authentication - replace with actual API call
      if (email == 'farmer@example.com' && password == 'password') {
        _user = User(
          id: '1',
          name: 'John Farmer',
          email: email,
          phone: '+1234567890',
          address: 'Farm Address, Village, State',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        await _saveUserToStorage();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Invalid email or password';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Login failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signup(String name, String email, String password, String phone, String address) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock registration - replace with actual API call
      _user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        phone: phone,
        address: address,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _saveUserToStorage();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Signup failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _user = null;
    await _clearUserFromStorage();
    notifyListeners();
  }

  Future<void> loadUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      if (userJson != null) {
        // Parse user from JSON - implement based on your storage method
        // For now, we'll use a simple approach
        _user = User(
          id: prefs.getString('user_id') ?? '',
          name: prefs.getString('user_name') ?? '',
          email: prefs.getString('user_email') ?? '',
          phone: prefs.getString('user_phone') ?? '',
          address: prefs.getString('user_address') ?? '',
          createdAt: DateTime.parse(prefs.getString('user_created_at') ?? DateTime.now().toIso8601String()),
          updatedAt: DateTime.parse(prefs.getString('user_updated_at') ?? DateTime.now().toIso8601String()),
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error loading user from storage: $e');
    }
  }

  Future<void> _saveUserToStorage() async {
    if (_user == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', _user!.id);
    await prefs.setString('user_name', _user!.name);
    await prefs.setString('user_email', _user!.email);
    await prefs.setString('user_phone', _user!.phone);
    await prefs.setString('user_address', _user!.address);
    await prefs.setString('user_created_at', _user!.createdAt.toIso8601String());
    await prefs.setString('user_updated_at', _user!.updatedAt.toIso8601String());
  }

  Future<void> _clearUserFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_phone');
    await prefs.remove('user_address');
    await prefs.remove('user_created_at');
    await prefs.remove('user_updated_at');
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
