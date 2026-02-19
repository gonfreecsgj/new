<<<<<<< HEAD
// lib/providers/mikrotik_provider.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:router_os_client/router_os_client.dart';
=======
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
>>>>>>> d49849d0e75a5e4d3e1691574062fe4c1ee8d31f
import '../models/voucher_model.dart';

class MikroTikProvider extends ChangeNotifier {
  bool _isConnected = false;
  bool _isConnecting = false;
  String? _error;
  String _routerIp = '192.168.88.1';
  int _routerPort = 8728;
  String _username = 'admin';
  String _password = '';
<<<<<<< HEAD

  RouterOSClient? _client;

=======
  
  Socket? _socket;
  int _tag = 0;
  final Map<int, Completer<String>> _pendingCommands = {};
  
>>>>>>> d49849d0e75a5e4d3e1691574062fe4c1ee8d31f
  // Getters
  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  String? get error => _error;
  String get routerIp => _routerIp;
  int get routerPort => _routerPort;
  String get username => _username;

  // Set router configuration
  void setConfig({required String ip, required int port, required String username, required String password}) {
    _routerIp = ip;
    _routerPort = port;
    _username = username;
    _password = password;
  }

  // Connect to MikroTik
  Future<bool> connect() async {
    if (_isConnected) return true;
<<<<<<< HEAD

=======
    
>>>>>>> d49849d0e75a5e4d3e1691574062fe4c1ee8d31f
    _isConnecting = true;
    _error = null;
    notifyListeners();

    try {
<<<<<<< HEAD
      _client = RouterOSClient(
        address: _routerIp,
        user: _username,
        password: _password,
        port: _routerPort,
        useSsl: false, // يمكن جعلها خيارًا إذا احتجت
        verbose: false,
      );

      final success = await _client!.login();
      if (success) {
=======
      _socket = await Socket.connect(_routerIp, _routerPort, timeout: const Duration(seconds: 10));
      
      // Listen for responses
      _socket!.listen(
        (data) => _handleResponse(data),
        onError: (error) {
          _error = 'Connection error: $error';
          _disconnect();
        },
        onDone: () {
          _disconnect();
        },
      );

      // Login
      final loginSuccess = await _login();
      
      if (loginSuccess) {
>>>>>>> d49849d0e75a5e4d3e1691574062fe4c1ee8d31f
        _isConnected = true;
        _isConnecting = false;
        notifyListeners();
        return true;
      } else {
        _error = 'فشل تسجيل الدخول إلى MikroTik';
<<<<<<< HEAD
        _isConnecting = false;
        notifyListeners();
=======
        _disconnect();
>>>>>>> d49849d0e75a5e4d3e1691574062fe4c1ee8d31f
        return false;
      }
    } catch (e) {
      _error = 'فشل الاتصال: $e';
      _isConnecting = false;
      notifyListeners();
      return false;
    }
  }

<<<<<<< HEAD
  // Disconnect from MikroTik
  void disconnect() {
    _client?.close();
    _client = null;
    _isConnected = false;
    _isConnecting = false;
    _error = null;
    notifyListeners();
  }

  // Helper to format time limit (if needed)
  String _formatUptime(int? minutes) {
    if (minutes == null) return '';
    if (minutes < 60) return '${minutes}m';
    if (minutes < 1440) return '${minutes ~/ 60}h';
    return '${minutes ~/ 1440}d';
  }

  // Create a single user (voucher)
=======
  // Login to MikroTik
  Future<bool> _login() async {
    try {
      // Send login command
      final loginCmd = '/login';
      _sendCommand(loginCmd);
      
      // Wait for challenge
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Send credentials (simplified - in production use proper MD5 challenge-response)
      final response = '/login=name=$_username&password=$_password';
      _sendCommand(response);
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      return true; // Simplified - should check actual response
    } catch (e) {
      return false;
    }
  }

  // Send command to MikroTik
  void _sendCommand(String command) {
    if (_socket == null) return;
    
    final length = command.length;
    final encodedLength = _encodeLength(length);
    
    final bytes = Uint8List.fromList([
      ...encodedLength,
      ...utf8.encode(command),
    ]);
    
    _socket!.add(bytes);
  }

  // Encode length for MikroTik API
  List<int> _encodeLength(int length) {
    if (length < 0x80) {
      return [length];
    } else if (length < 0x4000) {
      return [
        (length >> 8) | 0x80,
        length & 0xFF,
      ];
    } else if (length < 0x20000) {
      return [
        (length >> 16) | 0xC0,
        (length >> 8) & 0xFF,
        length & 0xFF,
      ];
    } else if (length < 0x10000000) {
      return [
        (length >> 24) | 0xE0,
        (length >> 16) & 0xFF,
        (length >> 8) & 0xFF,
        length & 0xFF,
      ];
    } else {
      return [
        0xF0,
        (length >> 24) & 0xFF,
        (length >> 16) & 0xFF,
        (length >> 8) & 0xFF,
        length & 0xFF,
      ];
    }
  }

  // Handle response from MikroTik
  void _handleResponse(Uint8List data) {
    // Parse response - simplified implementation
    final response = utf8.decode(data);
    
    if (response.contains('!done')) {
      // Command completed successfully
    } else if (response.contains('!trap')) {
      // Error occurred
      _error = 'MikroTik Error: $response';
    }
  }

  // Disconnect from MikroTik
  void _disconnect() {
    _socket?.close();
    _socket = null;
    _isConnected = false;
    _isConnecting = false;
    notifyListeners();
  }

  // Create user in MikroTik
>>>>>>> d49849d0e75a5e4d3e1691574062fe4c1ee8d31f
  Future<bool> createUser(VoucherModel voucher) async {
    if (!_isConnected) {
      final connected = await connect();
      if (!connected) return false;
    }

    try {
<<<<<<< HEAD
      final params = <String, String>{
        'name': voucher.code,
        'password': voucher.password ?? '',
        'profile': voucher.profileName ?? voucher.profile, // تأكد من وجود اسم الملف الشخصي
      };

      // Add limit-uptime if timeLimit is provided
      if (voucher.timeLimit != null && voucher.timeLimit! > 0) {
        params['limit-uptime'] = _formatUptime(voucher.timeLimit);
      }

      // Add comment for shelf or other info
      if (voucher.shelfId != null) {
        params['comment'] = 'Shelf: ${voucher.shelfId}';
      }

      await _client!.talk('/ip/hotspot/user/add', params);
      return true;
=======
      // Create user command
      final cmd = '/ip/hotspot/user/add';
      final params = 'name=${voucher.code}';
      final password = voucher.password != null ? '&password=${voucher.password}' : '';
      final profile = '&profile=${voucher.profile}';
      
      _sendCommand('$cmd=$params$password$profile');
      
      await Future.delayed(const Duration(milliseconds: 300));
      
      return true; // Simplified
>>>>>>> d49849d0e75a5e4d3e1691574062fe4c1ee8d31f
    } catch (e) {
      _error = 'فشل إنشاء المستخدم: $e';
      notifyListeners();
      return false;
    }
  }

  // Create multiple users (batch)
  Future<int> createUsersBatch(List<VoucherModel> vouchers) async {
    if (!_isConnected) {
      final connected = await connect();
      if (!connected) return 0;
    }

    int successCount = 0;
<<<<<<< HEAD
    for (final voucher in vouchers) {
      final success = await createUser(voucher);
      if (success) successCount++;
      await Future.delayed(const Duration(milliseconds: 50)); // تجنب الإغراق
    }
    return successCount;
  }

  // Get active users (currently connected)
=======
    
    for (final voucher in vouchers) {
      final success = await createUser(voucher);
      if (success) successCount++;
      
      // Small delay to not overwhelm the router
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    return successCount;
  }

  // Get active users
>>>>>>> d49849d0e75a5e4d3e1691574062fe4c1ee8d31f
  Future<List<Map<String, dynamic>>> getActiveUsers() async {
    if (!_isConnected) {
      final connected = await connect();
      if (!connected) return [];
    }

    try {
<<<<<<< HEAD
      final response = await _client!.talk('/ip/hotspot/active/print');
      if (response is List) {
        return response.cast<Map<String, dynamic>>();
      } else if (response is Map) {
        // إذا أعادت المكتبة خريطة واحدة فقط، نضعها في قائمة
        return [response.cast<String, dynamic>()];
      }
=======
      _sendCommand('/ip/hotspot/active/print');
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Return simplified data - should parse actual response
>>>>>>> d49849d0e75a5e4d3e1691574062fe4c1ee8d31f
      return [];
    } catch (e) {
      _error = 'فشل جلب المستخدمين النشطين: $e';
      notifyListeners();
      return [];
    }
  }

<<<<<<< HEAD
  // Remove a user (by .id or name)
  Future<bool> removeUser(String identifier) async {
=======
  // Remove user
  Future<bool> removeUser(String username) async {
>>>>>>> d49849d0e75a5e4d3e1691574062fe4c1ee8d31f
    if (!_isConnected) {
      final connected = await connect();
      if (!connected) return false;
    }

    try {
<<<<<<< HEAD
      // نحتاج إلى معرفة ما إذا كان identifier هو .id أو name. هنا نفترض أنه الاسم
      // الأفضل هو البحث عن المستخدم أولاً باستخدام الاسم ثم حذفه باستخدام .id
      // لكن للتبسيط، نستخدم '/ip/hotspot/user/remove' مع قيمة .id
      await _client!.talk('/ip/hotspot/user/remove', {'.id': identifier});
=======
      _sendCommand('/ip/hotspot/user/remove=.id=$username');
      await Future.delayed(const Duration(milliseconds: 300));
>>>>>>> d49849d0e75a5e4d3e1691574062fe4c1ee8d31f
      return true;
    } catch (e) {
      _error = 'فشل حذف المستخدم: $e';
      notifyListeners();
      return false;
    }
  }

<<<<<<< HEAD
  // Get user profiles list
  Future<List<String>> getProfiles() async {
    if (!_isConnected) {
      final connected = await connect();
      if (!connected) return ['default']; // قيمة افتراضية
    }

    try {
      final response = await _client!.talk('/ip/hotspot/user/profile/print');
      List<Map<String, dynamic>> profilesData = [];
      if (response is List) {
        profilesData = response.cast<Map<String, dynamic>>();
      } else if (response is Map) {
        profilesData = [response.cast<String, dynamic>()];
      }

      final profiles = profilesData.map<String>((p) => p['name'] as String? ?? 'unknown').toList();
      if (profiles.isEmpty) profiles.add('default');
      return profiles;
    } catch (e) {
      _error = 'فشل جلب البروفايلات: $e';
      notifyListeners();
      return ['default']; // قيمة افتراضية عند الخطأ
    }
  }

  // Test connection with given credentials
=======
  // Get user profiles
  Future<List<String>> getProfiles() async {
    if (!_isConnected) {
      final connected = await connect();
      if (!connected) return ['default'];
    }

    try {
      _sendCommand('/ip/hotspot/user/profile/print');
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Return default profiles - should parse actual response
      return ['default', '1hour', '3hours', '1day', '1week'];
    } catch (e) {
      return ['default'];
    }
  }

  // Test connection
>>>>>>> d49849d0e75a5e4d3e1691574062fe4c1ee8d31f
  Future<bool> testConnection(String ip, int port, String username, String password) async {
    setConfig(ip: ip, port: port, username: username, password: password);
    return await connect();
  }

<<<<<<< HEAD
  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
=======
  // Disconnect
  void disconnect() {
    _disconnect();
  }

  @override
  void dispose() {
    _disconnect();
    super.dispose();
  }
}

// Helper class for async operations
class Completer<T> {
  final Future<T> future;
  final void Function(T value) complete;
  final void Function(Object error, [StackTrace? stackTrace]) completeError;
  bool get isCompleted;
  
  Completer._(this.future, this.complete, this.completeError, this.isCompleted);
  
  factory Completer() {
    final completer = _Completer<T>();
    return Completer._(completer.future, completer.complete, completer.completeError, completer.isCompleted);
  }
}

class _Completer<T> {
  final _future = Future<T>.value(null as T);
  void complete(T value) {}
  void completeError(Object error, [StackTrace? stackTrace]) {}
  bool get isCompleted => false;
  Future<T> get future => _future;
}
>>>>>>> d49849d0e75a5e4d3e1691574062fe4c1ee8d31f
