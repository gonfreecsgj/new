import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/manager_model.dart';
import '../models/voucher_model.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cogona_net.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Managers table
    await db.execute('''
      CREATE TABLE managers (
        id TEXT PRIMARY KEY,
        googleId TEXT UNIQUE NOT NULL,
        email TEXT NOT NULL,
        name TEXT NOT NULL,
        photoUrl TEXT,
        deviceId TEXT UNIQUE NOT NULL,
        status TEXT NOT NULL DEFAULT 'trial',
        trialStartedAt TEXT,
        expiresAt TEXT,
        createdAt TEXT NOT NULL,
        router TEXT,
        stats TEXT,
        settings TEXT
      )
    ''');

    // Vouchers table
    await db.execute('''
      CREATE TABLE vouchers (
        id TEXT PRIMARY KEY,
        code TEXT UNIQUE NOT NULL,
        password TEXT,
        profile TEXT NOT NULL,
        dataLimit REAL NOT NULL,
        timeLimit INTEGER NOT NULL,
        validityDays INTEGER NOT NULL,
        shelfId TEXT NOT NULL DEFAULT 'default',
        resellerId TEXT,
        status TEXT NOT NULL DEFAULT 'active',
        createdAt TEXT NOT NULL,
        usedAt TEXT,
        expiresAt TEXT,
        usedByMac TEXT,
        usedByIp TEXT,
        printedAt TEXT,
        notes TEXT
      )
    ''');

    // Profiles table
    await db.execute('''
      CREATE TABLE profiles (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        dataLimit REAL NOT NULL,
        timeLimit INTEGER NOT NULL,
        validityDays INTEGER NOT NULL,
        price REAL NOT NULL,
        description TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    // Shelves table
    await db.execute('''
      CREATE TABLE shelves (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        assignedTo TEXT,
        voucherCount INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');

    // Resellers table
    await db.execute('''
      CREATE TABLE resellers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        code TEXT UNIQUE NOT NULL,
        phone TEXT,
        balance REAL DEFAULT 0,
        commissionRate REAL DEFAULT 0.1,
        createdAt TEXT NOT NULL
      )
    ''');

    // Recharges table
    await db.execute('''
      CREATE TABLE recharges (
        id TEXT PRIMARY KEY,
        voucherId TEXT NOT NULL,
        resellerId TEXT NOT NULL,
        amount REAL NOT NULL,
        commission REAL NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    // Insert default profiles
    await _insertDefaultProfiles(db);
    await _insertDefaultShelves(db);
  }

  Future<void> _insertDefaultProfiles(Database db) async {
    final defaultProfiles = [
      {
        'id': 'profile_1h',
        'name': 'ساعة واحدة',
        'dataLimit': 0.5,
        'timeLimit': 1,
        'validityDays': 1,
        'price': 0.5,
        'description': 'ساعة واحدة - 500 ميجا',
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'profile_3h',
        'name': '3 ساعات',
        'dataLimit': 1.0,
        'timeLimit': 3,
        'validityDays': 1,
        'price': 1.0,
        'description': '3 ساعات - 1 جيجا',
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'profile_1d',
        'name': 'يوم كامل',
        'dataLimit': 2.0,
        'timeLimit': 24,
        'validityDays': 1,
        'price': 2.0,
        'description': '24 ساعة - 2 جيجا',
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'profile_1w',
        'name': 'أسبوع',
        'dataLimit': 5.0,
        'timeLimit': 168,
        'validityDays': 7,
        'price': 5.0,
        'description': 'أسبوع كامل - 5 جيجا',
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'profile_1m',
        'name': 'شهر',
        'dataLimit': 20.0,
        'timeLimit': 720,
        'validityDays': 30,
        'price': 15.0,
        'description': 'شهر كامل - 20 جيجا',
        'createdAt': DateTime.now().toIso8601String(),
      },
    ];

    for (final profile in defaultProfiles) {
      await db.insert('profiles', profile);
    }
  }

  Future<void> _insertDefaultShelves(Database db) async {
    final defaultShelves = [
      {
        'id': 'shelf_default',
        'name': 'الافتراضي',
        'description': 'الرف الافتراضي للكروت',
        'voucherCount': 0,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'shelf_morning',
        'name': 'الصباح',
        'description': 'كروت الصباح',
        'voucherCount': 0,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'shelf_evening',
        'name': 'المساء',
        'description': 'كروت المساء',
        'voucherCount': 0,
        'createdAt': DateTime.now().toIso8601String(),
      },
    ];

    for (final shelf in defaultShelves) {
      await db.insert('shelves', shelf);
    }
  }

  // ==================== MANAGER OPERATIONS ====================

  Future<void> saveManager(ManagerModel manager) async {
    final db = await database;
    await db.insert(
      'managers',
      manager.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateManager(ManagerModel manager) async {
    final db = await database;
    await db.update(
      'managers',
      manager.toJson(),
      where: 'id = ?',
      whereArgs: [manager.id],
    );
  }

  Future<ManagerModel?> getManagerById(String id) async {
    final db = await database;
    final maps = await db.query(
      'managers',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return ManagerModel.fromJson(maps.first);
    }
    return null;
  }

  Future<ManagerModel?> getManagerByGoogleId(String googleId) async {
    final db = await database;
    final maps = await db.query(
      'managers',
      where: 'googleId = ?',
      whereArgs: [googleId],
    );

    if (maps.isNotEmpty) {
      return ManagerModel.fromJson(maps.first);
    }
    return null;
  }

  Future<ManagerModel?> getManagerByDeviceId(String deviceId) async {
    final db = await database;
    final maps = await db.query(
      'managers',
      where: 'deviceId = ?',
      whereArgs: [deviceId],
    );

    if (maps.isNotEmpty) {
      return ManagerModel.fromJson(maps.first);
    }
    return null;
  }

  // ==================== VOUCHER OPERATIONS ====================

  Future<void> saveVoucher(VoucherModel voucher) async {
    final db = await database;
    await db.insert(
      'vouchers',
      voucher.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> saveVouchersBatch(List<VoucherModel> vouchers) async {
    final db = await database;
    final batch = db.batch();
    
    for (final voucher in vouchers) {
      batch.insert(
        'vouchers',
        voucher.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit(noResult: true);
  }

  Future<List<VoucherModel>> getVouchers({
    String? shelfId,
    String? status,
    String? profile,
    int limit = 100,
    int offset = 0,
  }) async {
    final db = await database;
    
    String whereClause = '';
    List<dynamic> whereArgs = [];
    
    if (shelfId != null) {
      whereClause = 'shelfId = ?';
      whereArgs.add(shelfId);
    }
    
    if (status != null) {
      whereClause = whereClause.isEmpty ? 'status = ?' : '$whereClause AND status = ?';
      whereArgs.add(status);
    }
    
    if (profile != null) {
      whereClause = whereClause.isEmpty ? 'profile = ?' : '$whereClause AND profile = ?';
      whereArgs.add(profile);
    }

    final maps = await db.query(
      'vouchers',
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      limit: limit,
      offset: offset,
      orderBy: 'createdAt DESC',
    );

    return maps.map((map) => VoucherModel.fromJson(map)).toList();
  }

  Future<VoucherModel?> getVoucherByCode(String code) async {
    final db = await database;
    final maps = await db.query(
      'vouchers',
      where: 'code = ?',
      whereArgs: [code],
    );

    if (maps.isNotEmpty) {
      return VoucherModel.fromJson(maps.first);
    }
    return null;
  }

  Future<void> updateVoucherStatus(String id, String status) async {
    final db = await database;
    await db.update(
      'vouchers',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markVoucherAsUsed(String id, {String? mac, String? ip}) async {
    final db = await database;
    await db.update(
      'vouchers',
      {
        'status': 'used',
        'usedAt': DateTime.now().toIso8601String(),
        'usedByMac': mac,
        'usedByIp': ip,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteVoucher(String id) async {
    final db = await database;
    await db.delete(
      'vouchers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getVoucherCount({String? shelfId, String? status}) async {
    final db = await database;
    
    String whereClause = '';
    List<dynamic> whereArgs = [];
    
    if (shelfId != null) {
      whereClause = 'shelfId = ?';
      whereArgs.add(shelfId);
    }
    
    if (status != null) {
      whereClause = whereClause.isEmpty ? 'status = ?' : '$whereClause AND status = ?';
      whereArgs.add(status);
    }

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM vouchers ${whereClause.isNotEmpty ? 'WHERE $whereClause' : ''}',
      whereArgs.isEmpty ? null : whereArgs,
    );

    return result.first['count'] as int? ?? 0;
  }

  // ==================== PROFILE OPERATIONS ====================

  Future<List<VoucherProfile>> getProfiles() async {
    final db = await database;
    final maps = await db.query('profiles', orderBy: 'price ASC');
    return maps.map((map) => VoucherProfile.fromJson(map)).toList();
  }

  Future<void> saveProfile(VoucherProfile profile) async {
    final db = await database;
    await db.insert(
      'profiles',
      profile.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteProfile(String id) async {
    final db = await database;
    await db.delete(
      'profiles',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== SHELF OPERATIONS ====================

  Future<List<ShelfModel>> getShelves() async {
    final db = await database;
    final maps = await db.query('shelves', orderBy: 'createdAt ASC');
    return maps.map((map) => ShelfModel.fromJson(map)).toList();
  }

  Future<void> saveShelf(ShelfModel shelf) async {
    final db = await database;
    await db.insert(
      'shelves',
      shelf.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteShelf(String id) async {
    final db = await database;
    await db.delete(
      'shelves',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== STATS OPERATIONS ====================

  Future<Map<String, dynamic>> getStats() async {
    final db = await database;
    
    final totalVouchers = await getVoucherCount();
    final activeVouchers = await getVoucherCount(status: 'active');
    final usedVouchers = await getVoucherCount(status: 'used');
    final expiredVouchers = await getVoucherCount(status: 'expired');
    
    return {
      'totalVouchers': totalVouchers,
      'activeVouchers': activeVouchers,
      'usedVouchers': usedVouchers,
      'expiredVouchers': expiredVouchers,
    };
  }

  // Close database
  Future close() async {
    final db = await database;
    db.close();
  }
}
