import 'dart:math';

class VoucherModel {
  final String id;
  final String code;
  final String? password;
  final String profile;
  final double dataLimit; // in GB
  final int timeLimit; // in hours
  final int validityDays;
  final String shelfId;
  final String? resellerId;
  final String status; // active, used, expired, disabled
  final DateTime createdAt;
  final DateTime? usedAt;
  final DateTime? expiresAt;
  final String? usedByMac;
  final String? usedByIp;
  final String? printedAt;
  final String? notes;

  VoucherModel({
    required this.id,
    required this.code,
    this.password,
    required this.profile,
    required this.dataLimit,
    required this.timeLimit,
    required this.validityDays,
    this.shelfId = 'default',
    this.resellerId,
    this.status = 'active',
    DateTime? createdAt,
    this.usedAt,
    this.expiresAt,
    this.usedByMac,
    this.usedByIp,
    this.printedAt,
    this.notes,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isActive => status == 'active';
  bool get isUsed => status == 'used';
  bool get isExpired => status == 'expired' || (expiresAt != null && DateTime.now().isAfter(expiresAt!));
  
  String get displayCode {
    if (code.length <= 8) return code;
    return '${code.substring(0, 4)}-${code.substring(4, 8)}-${code.substring(8)}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'password': password,
      'profile': profile,
      'dataLimit': dataLimit,
      'timeLimit': timeLimit,
      'validityDays': validityDays,
      'shelfId': shelfId,
      'resellerId': resellerId,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'usedAt': usedAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'usedByMac': usedByMac,
      'usedByIp': usedByIp,
      'printedAt': printedAt,
      'notes': notes,
    };
  }

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    return VoucherModel(
      id: json['id'],
      code: json['code'],
      password: json['password'],
      profile: json['profile'],
      dataLimit: (json['dataLimit'] ?? 0.0).toDouble(),
      timeLimit: json['timeLimit'] ?? 0,
      validityDays: json['validityDays'] ?? 1,
      shelfId: json['shelfId'] ?? 'default',
      resellerId: json['resellerId'],
      status: json['status'] ?? 'active',
      createdAt: DateTime.parse(json['createdAt']),
      usedAt: json['usedAt'] != null ? DateTime.parse(json['usedAt']) : null,
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      usedByMac: json['usedByMac'],
      usedByIp: json['usedByIp'],
      printedAt: json['printedAt'],
      notes: json['notes'],
    );
  }

  VoucherModel copyWith({
    String? id,
    String? code,
    String? password,
    String? profile,
    double? dataLimit,
    int? timeLimit,
    int? validityDays,
    String? shelfId,
    String? resellerId,
    String? status,
    DateTime? createdAt,
    DateTime? usedAt,
    DateTime? expiresAt,
    String? usedByMac,
    String? usedByIp,
    String? printedAt,
    String? notes,
  }) {
    return VoucherModel(
      id: id ?? this.id,
      code: code ?? this.code,
      password: password ?? this.password,
      profile: profile ?? this.profile,
      dataLimit: dataLimit ?? this.dataLimit,
      timeLimit: timeLimit ?? this.timeLimit,
      validityDays: validityDays ?? this.validityDays,
      shelfId: shelfId ?? this.shelfId,
      resellerId: resellerId ?? this.resellerId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      usedAt: usedAt ?? this.usedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      usedByMac: usedByMac ?? this.usedByMac,
      usedByIp: usedByIp ?? this.usedByIp,
      printedAt: printedAt ?? this.printedAt,
      notes: notes ?? this.notes,
    );
  }
}

class VoucherProfile {
  final String id;
  final String name;
  final double dataLimit;
  final int timeLimit;
  final int validityDays;
  final double price;
  final String? description;
  final DateTime createdAt;

  VoucherProfile({
    required this.id,
    required this.name,
    required this.dataLimit,
    required this.timeLimit,
    required this.validityDays,
    required this.price,
    this.description,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dataLimit': dataLimit,
      'timeLimit': timeLimit,
      'validityDays': validityDays,
      'price': price,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory VoucherProfile.fromJson(Map<String, dynamic> json) {
    return VoucherProfile(
      id: json['id'],
      name: json['name'],
      dataLimit: (json['dataLimit'] ?? 0.0).toDouble(),
      timeLimit: json['timeLimit'] ?? 0,
      validityDays: json['validityDays'] ?? 1,
      price: (json['price'] ?? 0.0).toDouble(),
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class ShelfModel {
  final String id;
  final String name;
  final String? description;
  final String? assignedTo; // resellerId
  final int voucherCount;
  final DateTime createdAt;

  ShelfModel({
    required this.id,
    required this.name,
    this.description,
    this.assignedTo,
    this.voucherCount = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'assignedTo': assignedTo,
      'voucherCount': voucherCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ShelfModel.fromJson(Map<String, dynamic> json) {
    return ShelfModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      assignedTo: json['assignedTo'],
      voucherCount: json['voucherCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class VoucherGenerator {
  static final Random _random = Random.secure();
  static const String _chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  static const String _numbers = '0123456789';

  static String generateCode({
    int length = 10,
    bool useLetters = true,
    bool useNumbers = true,
    String? prefix,
    String? suffix,
  }) {
    String chars = '';
    if (useLetters) chars += _chars;
    if (useNumbers) chars += _numbers;
    if (chars.isEmpty) chars = _numbers;

    String code = '';
    for (int i = 0; i < length; i++) {
      code += chars[_random.nextInt(chars.length)];
    }

    if (prefix != null) code = prefix + code;
    if (suffix != null) code = code + suffix;

    return code;
  }

  static String generatePassword({int length = 6}) {
    return generateCode(length: length, useLetters: false, useNumbers: true);
  }

  static List<VoucherModel> generateBatch({
    required int count,
    required String profile,
    required double dataLimit,
    required int timeLimit,
    required int validityDays,
    String shelfId = 'default',
    int codeLength = 10,
    bool generatePassword = false,
    String? prefix,
    String? suffix,
  }) {
    return List.generate(count, (index) {
      return VoucherModel(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '_$index',
        code: generateCode(
          length: codeLength,
          prefix: prefix,
          suffix: suffix,
        ),
        password: generatePassword ? generatePassword() : null,
        profile: profile,
        dataLimit: dataLimit,
        timeLimit: timeLimit,
        validityDays: validityDays,
        shelfId: shelfId,
      );
    });
  }
}
