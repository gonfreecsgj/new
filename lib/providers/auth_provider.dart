import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../models/manager_model.dart';
import '../services/database_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  ManagerModel? _currentManager;
  String? _deviceId;
  
  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  ManagerModel? get currentManager => _currentManager;
  bool get isAuthenticated => _currentManager != null;
  String? get deviceId => _deviceId;

  // Initialize and get device ID
  Future<void> initialize() async {
    await _getDeviceId();
    await _loadSavedManager();
  }

  Future<void> _getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    try {
      final androidInfo = await deviceInfo.androidInfo;
      _deviceId = androidInfo.id;
    } catch (e) {
      _deviceId = DateTime.now().millisecondsSinceEpoch.toString();
    }
  }

  // Load saved manager from local storage
  Future<void> _loadSavedManager() async {
    final prefs = await SharedPreferences.getInstance();
    final managerData = prefs.getString('manager_data');
    
    if (managerData != null) {
      try {
        _currentManager = ManagerModel.fromJson(jsonDecode(managerData));
        notifyListeners();
      } catch (e) {
        await prefs.remove('manager_data');
      }
    }
  }

  // Register new manager (simulated Google Sign In for now)
  Future<bool> register({
    required String email,
    required String name,
    String? photoUrl,
    required String googleId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _getDeviceId();
      
      // Check if device already registered with different account
      final existingManager = await DatabaseService.instance.getManagerByDeviceId(_deviceId!);
      
      if (existingManager != null && existingManager.googleId != googleId) {
        _error = 'هذا الجهاز مسجل بحساب آخر: ${existingManager.email}';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Create new manager
      final manager = ManagerModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        googleId: googleId,
        email: email,
        name: name,
        photoUrl: photoUrl,
        deviceId: _deviceId!,
        status: 'trial',
        trialStartedAt: DateTime.now(),
      );

      // Save to local database
      await DatabaseService.instance.saveManager(manager);
      
      // Save to preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('manager_data', jsonEncode(manager.toJson()));
      
      _currentManager = manager;
      _isLoading = false;
      notifyListeners();
      
      return true;
    } catch (e) {
      _error = 'حدث خطأ أثناء التسجيل: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Login with existing account
  Future<bool> login(String googleId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _getDeviceId();
      
      // Get manager from database
      final manager = await DatabaseService.instance.getManagerByGoogleId(googleId);
      
      if (manager == null) {
        _error = 'الحساب غير موجود';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Verify device ID
      if (manager.deviceId != _deviceId) {
        _error = 'هذا الحساب مسجل على جهاز آخر';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Save to preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('manager_data', jsonEncode(manager.toJson()));
      
      _currentManager = manager;
      _isLoading = false;
      notifyListeners();
      
      return true;
    } catch (e) {
      _error = 'حدث خطأ أثناء تسجيل الدخول: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Activate subscription with token
  Future<bool> activateSubscription(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Validate token format (simple validation)
      if (!token.startsWith('COGONA-')) {
        _error = 'رمز التفعيل غير صالح';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Parse token to get months
      final parts = token.split('-');
      if (parts.length < 3) {
        _error = 'رمز التفعيل غير صالح';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final months = int.tryParse(parts[2]) ?? 1;
      
      // Calculate new expiry date
      final now = DateTime.now();
      final currentExpiry = _currentManager?.expiresAt ?? now;
      final baseDate = currentExpiry.isAfter(now) ? currentExpiry : now;
      final newExpiry = baseDate.add(Duration(days: 30 * months));

      // Update manager
      final updatedManager = _currentManager!.copyWith(
        status: 'active',
        expiresAt: newExpiry,
      );

      await DatabaseService.instance.updateManager(updatedManager);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('manager_data', jsonEncode(updatedManager.toJson()));
      
      _currentManager = updatedManager;
      _isLoading = false;
      notifyListeners();
      
      return true;
    } catch (e) {
      _error = 'حدث خطأ أثناء التفعيل: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update router configuration
  Future<void> updateRouterConfig(RouterConfig config) async {
    if (_currentManager == null) return;

    final updatedManager = _currentManager!.copyWith(router: config);
    
    await DatabaseService.instance.updateManager(updatedManager);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('manager_data', jsonEncode(updatedManager.toJson()));
    
    _currentManager = updatedManager;
    notifyListeners();
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
