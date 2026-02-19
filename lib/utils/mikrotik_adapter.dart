import 'package:mikrotik_api/mikrotik_api.dart';

/// محول مخصص لجعل التعامل مع المكتبة الجديدة يشبه المنطق البرمجي لمشروعك
class MikrotikAdapter {
  late RouterBoard _connection;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  // دالة تسجيل الدخول (Login)
  Future<bool> connect(String host, String user, String password, {int port = 8728}) async {
    try {
      _connection = await RouterBoard.connect(host, user, password, port: port);
      _isConnected = true;
      return true;
    } catch (e) {
      _isConnected = false;
      print("خطأ في الاتصال بالميكروتيك: $e");
      return false;
    }
  }

  // دالة لجلب البيانات (مثل قائمة المستخدمين أو الفوكرات)
  Future<List<Map<String, dynamic>>> execute(String command) async {
    if (!_isConnected) return [];
    try {
      final response = await _connection.talk(command);
      return response;
    } catch (e) {
      print("خطأ أثناء تنفيذ الأمر $command: $e");
      return [];
    }
  }

  void disconnect() {
    _connection.close();
    _isConnected = false;
  }
}

