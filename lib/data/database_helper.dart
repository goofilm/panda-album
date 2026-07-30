import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDB('photo_organizer.db');

    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();

    final path = join(dbPath, fileName);

    return await openDatabase(
      path,

      version: 2,

      onCreate: _createDB,

      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _insertDefaultCategories(db);
    }
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''

    CREATE TABLE categories (

      id INTEGER PRIMARY KEY AUTOINCREMENT,

      name TEXT NOT NULL,

      icon TEXT NOT NULL,

      color TEXT NOT NULL,

      is_default INTEGER NOT NULL DEFAULT 0,

      create_time INTEGER NOT NULL

    )

    ''');

    await db.execute('''

    CREATE TABLE photos (

      id INTEGER PRIMARY KEY AUTOINCREMENT,

      asset_id TEXT NOT NULL,

      category_id INTEGER,

      status INTEGER NOT NULL DEFAULT 0,

      delete_time INTEGER,

      create_time INTEGER NOT NULL,

      FOREIGN KEY(category_id)

      REFERENCES categories(id)

    )

    ''');

    await _insertDefaultCategories(db);
  }

  Future<void> _insertDefaultCategories(Database db) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final defaults = [
      {'name': '工作', 'icon': '💼', 'color': '4A90D9'},

      {'name': '生活', 'icon': '🏠', 'color': 'FF6B6B'},

      {'name': '旅行', 'icon': '✈️', 'color': '2ECC71'},

      {'name': '美食', 'icon': '🍣', 'color': 'F39C12'},

      {'name': '截图', 'icon': '📱', 'color': '9B59B6'},

      {'name': '人像', 'icon': '👤', 'color': 'E67E22'},
    ];

    for (final item in defaults) {
      final result = await db.query(
        'categories',

        where: 'name=?',

        whereArgs: [item['name']],
      );

      if (result.isEmpty) {
        await db.insert('categories', {
          'name': item['name'],

          'icon': item['icon'],

          'color': item['color'],

          'is_default': 1,

          'create_time': now,
        });
      }
    }
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await database;

    return await db.query('categories', orderBy: 'id ASC');
  }

  Future<int> addCategory({
    required String name,

    required String icon,

    required String color,
  }) async {
    final db = await database;

    return await db.insert('categories', {
      'name': name,

      'icon': icon,

      'color': color,

      'is_default': 0,

      'create_time': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<int> updateCategory({
    required int id,

    required String name,

    required String icon,

    required String color,
  }) async {
    final db = await database;

    return await db.update(
      'categories',

      {'name': name, 'icon': icon, 'color': color},

      where: 'id=?',

      whereArgs: [id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;

    final result = await db.query('categories', where: 'id=?', whereArgs: [id]);

    if (result.isEmpty) {
      return 0;
    }

    if (result.first['is_default'] == 1) {
      return 0;
    }

    return await db.delete('categories', where: 'id=?', whereArgs: [id]);
  }

  Future<int> addPhoto({
    required String assetId,

    int? categoryId,

    required int status,
  }) async {
    final db = await database;

    return await db.insert('photos', {
      'asset_id': assetId,

      'category_id': categoryId,

      'status': status,

      'create_time': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<int> updatePhotoCategory({
    required int id,

    required int categoryId,
  }) async {
    final db = await database;

    return await db.update(
      'photos',

      {'category_id': categoryId, 'status': 1},

      where: 'id=?',

      whereArgs: [id],
    );
  }

  Future<int> moveToRecycleBin(int id) async {
    final db = await database;

    return await db.update(
      'photos',

      {'status': 2, 'delete_time': DateTime.now().millisecondsSinceEpoch},

      where: 'id=?',

      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getRecyclePhotos() async {
    final db = await database;

    return await db.query(
      'photos',

      where: 'status=?',

      whereArgs: [2],

      orderBy: 'delete_time DESC',
    );
  }
}
