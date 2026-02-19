import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/manager_model.dart';

class AppProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  String _currentLanguage = 'ar';
  bool _isOffline = true;
  ManagerModel? _currentManager;
  
  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentLanguage => _currentLanguage;
  bool get isOffline => _isOffline;
  ManagerModel? get currentManager => _currentManager;
  bool get isLoggedIn => _currentManager != null;
  bool get isActive => _currentManager?.isActive ?? false;
  int get daysLeft => _currentManager?.daysLeft ?? 0;

  // Setters
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? value) {
    _error = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void setLanguage(String lang) {
    _currentLanguage = lang;
    _saveToPrefs();
    notifyListeners();
  }

  void setOffline(bool value) {
    _isOffline = value;
    notifyListeners();
  }

  void setManager(ManagerModel? manager) {
    _currentManager = manager;
    notifyListeners();
  }

  void updateManagerStatus(String status) {
    if (_currentManager != null) {
      _currentManager = _currentManager!.copyWith(status: status);
      notifyListeners();
    }
  }

  void updateRouterConfig(RouterConfig config) {
    if (_currentManager != null) {
      _currentManager = _currentManager!.copyWith(router: config);
      notifyListeners();
    }
  }

  // Persistence
  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', _currentLanguage);
  }

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('language') ?? 'ar';
    notifyListeners();
  }

  // Check subscription status
  Future<bool> checkSubscription() async {
    if (_currentManager == null) return false;
    
    if (_currentManager!.isExpired) {
      updateManagerStatus('expired');
      return false;
    }
    
    return true;
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('manager_data');
    await prefs.remove('auth_token');
    _currentManager = null;
    notifyListeners();
  }
}
