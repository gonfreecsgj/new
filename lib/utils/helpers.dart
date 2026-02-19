import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Helpers {
  // Format date to Arabic
  static String formatDate(DateTime date) {
    final formatter = DateFormat('yyyy/MM/dd', 'ar');
    return formatter.format(date);
  }

  // Format time to Arabic
  static String formatTime(DateTime date) {
    final formatter = DateFormat('HH:mm', 'ar');
    return formatter.format(date);
  }

  // Format number with commas
  static String formatNumber(int number) {
    final formatter = NumberFormat('#,###', 'ar');
    return formatter.format(number);
  }

  // Format currency
  static String formatCurrency(double amount, {String currency = '\$'}) {
    final formatter = NumberFormat('#,##0.00', 'ar');
    return '$currency ${formatter.format(amount)}';
  }

  // Format bytes to human readable
  static String formatBytes(int bytes, {int decimals = 2}) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = (bytes.bitLength ~/ 10);
    if (i >= suffixes.length) i = suffixes.length - 1;
    return '${(bytes / (1 << (i * 10))).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  // Format duration
  static String formatDuration(int hours) {
    if (hours < 24) {
      return '$hours ساعة';
    } else if (hours < 168) {
      return '${hours ~/ 24} يوم';
    } else {
      return '${hours ~/ 168} أسبوع';
    }
  }

  // Show snackbar
  static void showSnackbar(
    BuildContext context, {
    required String message,
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Show loading dialog
  static void showLoading(BuildContext context, {String message = 'جاري التحميل...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A24),
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Text(message),
          ],
        ),
      ),
    );
  }

  // Hide loading dialog
  static void hideLoading(BuildContext context) {
    Navigator.of(context).pop();
  }

  // Show confirmation dialog
  static Future<bool> showConfirmation(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'تأكيد',
    String cancelText = 'إلغاء',
    bool isDangerous = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A24),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDangerous ? Colors.red : null,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // Validate email
  static bool isValidEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  // Validate IP address
  static bool isValidIP(String ip) {
    final regex = RegExp(r'^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$');
    return regex.hasMatch(ip);
  }

  // Generate random color
  static Color generateColor(int seed) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.teal,
      Colors.cyan,
      Colors.indigo,
    ];
    return colors[seed % colors.length];
  }
}

// Extension for responsive sizing
extension Responsive on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  bool get isSmallScreen => screenWidth < 360;
  bool get isTablet => screenWidth > 600;
}
