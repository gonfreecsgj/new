class ManagerModel {
  final String id;
  final String googleId;
  final String email;
  final String name;
  final String? photoUrl;
  final String deviceId;
  final String status; // trial, active, expired, suspended
  final DateTime? trialStartedAt;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final RouterConfig? router;
  final ManagerStats stats;
  final ManagerSettings settings;

  ManagerModel({
    required this.id,
    required this.googleId,
    required this.email,
    required this.name,
    this.photoUrl,
    required this.deviceId,
    this.status = 'trial',
    this.trialStartedAt,
    this.expiresAt,
    DateTime? createdAt,
    this.router,
    ManagerStats? stats,
    ManagerSettings? settings,
  })  : createdAt = createdAt ?? DateTime.now(),
        stats = stats ?? ManagerStats(),
        settings = settings ?? ManagerSettings();

  bool get isActive => status == 'active' || (status == 'trial' && !isTrialExpired);
  
  bool get isTrialExpired {
    if (trialStartedAt == null) return false;
    final trialEnd = trialStartedAt!.add(const Duration(days: 30));
    return DateTime.now().isAfter(trialEnd);
  }
  
  bool get isExpired {
    if (expiresAt == null) return isTrialExpired;
    return DateTime.now().isAfter(expiresAt!);
  }
  
  int get daysLeft {
    if (expiresAt == null) {
      if (trialStartedAt == null) return 30;
      final trialEnd = trialStartedAt!.add(const Duration(days: 30));
      return trialEnd.difference(DateTime.now()).inDays;
    }
    return expiresAt!.difference(DateTime.now()).inDays;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'googleId': googleId,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'deviceId': deviceId,
      'status': status,
      'trialStartedAt': trialStartedAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'router': router?.toJson(),
      'stats': stats.toJson(),
      'settings': settings.toJson(),
    };
  }

  factory ManagerModel.fromJson(Map<String, dynamic> json) {
    return ManagerModel(
      id: json['id'],
      googleId: json['googleId'],
      email: json['email'],
      name: json['name'],
      photoUrl: json['photoUrl'],
      deviceId: json['deviceId'],
      status: json['status'] ?? 'trial',
      trialStartedAt: json['trialStartedAt'] != null
          ? DateTime.parse(json['trialStartedAt'])
          : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      router: json['router'] != null
          ? RouterConfig.fromJson(json['router'])
          : null,
      stats: json['stats'] != null
          ? ManagerStats.fromJson(json['stats'])
          : null,
      settings: json['settings'] != null
          ? ManagerSettings.fromJson(json['settings'])
          : null,
    );
  }

  ManagerModel copyWith({
    String? id,
    String? googleId,
    String? email,
    String? name,
    String? photoUrl,
    String? deviceId,
    String? status,
    DateTime? trialStartedAt,
    DateTime? expiresAt,
    DateTime? createdAt,
    RouterConfig? router,
    ManagerStats? stats,
    ManagerSettings? settings,
  }) {
    return ManagerModel(
      id: id ?? this.id,
      googleId: googleId ?? this.googleId,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      deviceId: deviceId ?? this.deviceId,
      status: status ?? this.status,
      trialStartedAt: trialStartedAt ?? this.trialStartedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      router: router ?? this.router,
      stats: stats ?? this.stats,
      settings: settings ?? this.settings,
    );
  }
}

class RouterConfig {
  final String ip;
  final int port;
  final String username;
  final String password;
  final bool isConnected;
  final DateTime? lastConnected;

  RouterConfig({
    this.ip = '192.168.88.1',
    this.port = 8728,
    this.username = 'admin',
    this.password = '',
    this.isConnected = false,
    this.lastConnected,
  });

  Map<String, dynamic> toJson() {
    return {
      'ip': ip,
      'port': port,
      'username': username,
      'password': password,
      'isConnected': isConnected,
      'lastConnected': lastConnected?.toIso8601String(),
    };
  }

  factory RouterConfig.fromJson(Map<String, dynamic> json) {
    return RouterConfig(
      ip: json['ip'] ?? '192.168.88.1',
      port: json['port'] ?? 8728,
      username: json['username'] ?? 'admin',
      password: json['password'] ?? '',
      isConnected: json['isConnected'] ?? false,
      lastConnected: json['lastConnected'] != null
          ? DateTime.parse(json['lastConnected'])
          : null,
    );
  }
}

class ManagerStats {
  final int totalVouchers;
  final int totalPrinted;
  final int totalResellers;
  final int totalRecharges;
  final double totalRevenue;

  ManagerStats({
    this.totalVouchers = 0,
    this.totalPrinted = 0,
    this.totalResellers = 0,
    this.totalRecharges = 0,
    this.totalRevenue = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalVouchers': totalVouchers,
      'totalPrinted': totalPrinted,
      'totalResellers': totalResellers,
      'totalRecharges': totalRecharges,
      'totalRevenue': totalRevenue,
    };
  }

  factory ManagerStats.fromJson(Map<String, dynamic> json) {
    return ManagerStats(
      totalVouchers: json['totalVouchers'] ?? 0,
      totalPrinted: json['totalPrinted'] ?? 0,
      totalResellers: json['totalResellers'] ?? 0,
      totalRecharges: json['totalRecharges'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0.0).toDouble(),
    );
  }
}

class ManagerSettings {
  final String language;
  final String currency;
  final int maxVouchersPerDay;
  final bool notificationsEnabled;
  final bool autoBackup;

  ManagerSettings({
    this.language = 'ar',
    this.currency = 'USD',
    this.maxVouchersPerDay = 1000,
    this.notificationsEnabled = true,
    this.autoBackup = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'currency': currency,
      'maxVouchersPerDay': maxVouchersPerDay,
      'notificationsEnabled': notificationsEnabled,
      'autoBackup': autoBackup,
    };
  }

  factory ManagerSettings.fromJson(Map<String, dynamic> json) {
    return ManagerSettings(
      language: json['language'] ?? 'ar',
      currency: json['currency'] ?? 'USD',
      maxVouchersPerDay: json['maxVouchersPerDay'] ?? 1000,
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      autoBackup: json['autoBackup'] ?? true,
    );
  }
}
