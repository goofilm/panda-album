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

      version: 4,

      onCreate: _createDB,

      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _insertDefaultCategories(db);
    }

    if (oldVersion < 3) {
      // 添加 media_type 字段

      await db.execute(
        'ALTER TABLE categories ADD COLUMN media_type INTEGER NOT NULL DEFAULT 0',
      );

      // 插入默认视频分类

      await _insertDefaultVideoCategories(db);
    }

    if (oldVersion < 4) {
      // photos表添加 media_type 字段

      await db.execute(
        'ALTER TABLE photos ADD COLUMN media_type INTEGER NOT NULL DEFAULT 0',
      );
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

      media_type INTEGER NOT NULL DEFAULT 0,

      create_time INTEGER NOT NULL

    )

    ''');

    await db.execute('''

    CREATE TABLE photos (

      id INTEGER PRIMARY KEY AUTOINCREMENT,

      asset_id TEXT NOT NULL,

      category_id INTEGER,

      status INTEGER NOT NULL DEFAULT 0,

      media_type INTEGER NOT NULL DEFAULT 0,

      delete_time INTEGER,

      create_time INTEGER NOT NULL,

      FOREIGN KEY(category_id)

      REFERENCES categories(id)

    )

    ''');

    await _insertDefaultCategories(db);

    await _insertDefaultVideoCategories(db);
  }

  Future<void> _insertDefaultVideoCategories(Database db) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final defaults = [
      {'name': 'Vlog', 'icon': '🎬', 'color': 'E74C3C'},

      {'name': '教程', 'icon': '📝', 'color': '3498DB'},

      {'name': '宠物', 'icon': '🐾', 'color': 'F39C12'},

      {'name': '运动', 'icon': '⚽', 'color': '2ECC71'},

      {'name': '音乐', 'icon': '🎵', 'color': '9B59B6'},

      {'name': '录屏', 'icon': '📹', 'color': '1ABC9C'},
    ];

    for (final item in defaults) {
      final result = await db.query(
        'categories',

        where: 'name=? AND media_type=?',

        whereArgs: [item['name'], 1],
      );

      if (result.isEmpty) {
        await db.insert('categories', {
          'name': item['name'],

          'icon': item['icon'],

          'color': item['color'],

          'is_default': 1,

          'media_type': 1,

          'create_time': now,
        });
      }
    }
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

          'media_type': 0,

          'create_time': now,
        });
      }
    }
  }

  Future<List<Map<String, dynamic>>> getCategories({int? mediaType}) async {
    final db = await database;

    if (mediaType != null) {
      return await db.query(
        'categories',

        where: 'media_type=?',

        whereArgs: [mediaType],

        orderBy: 'id ASC',
      );
    }

    return await db.query('categories', orderBy: 'id ASC');
  }

  Future<int> addCategory({
    required String name,

    required String icon,

    required String color,

    int mediaType = 0,
  }) async {
    final db = await database;

    return await db.insert('categories', {
      'name': name,

      'icon': icon,

      'color': color,

      'is_default': 0,

      'media_type': mediaType,

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

    // 将该分类下的照片重置为待整理状态

    await db.update(
      'photos',

      {'category_id': null, 'status': 0},

      where: 'category_id=?',

      whereArgs: [id],
    );

    return await db.delete('categories', where: 'id=?', whereArgs: [id]);
  }

  Future<int> addPhoto({
    required String assetId,

    int? categoryId,

    required int status,

    int mediaType = 0,
  }) async {
    final db = await database;

    // 先检查是否已存在该 asset_id 的记录

    final existing = await db.query(
      'photos',

      where: 'asset_id=?',

      whereArgs: [assetId],
    );

    if (existing.isNotEmpty) {
      // 更新已有记录的状态

      await db.update(
        'photos',

        {
          'category_id': categoryId,

          'status': status,

          'media_type': mediaType,
        },

        where: 'asset_id=?',

        whereArgs: [assetId],
      );

      return existing.first['id'] as int;
    }

    return await db.insert('photos', {
      'asset_id': assetId,

      'category_id': categoryId,

      'status': status,

      'media_type': mediaType,

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

  // 恢复回收站照片

  Future<int> restorePhoto(int id) async {
    final db = await database;

    return await db.update(
      'photos',

      {'status': 0, 'delete_time': null},

      where: 'id=?',

      whereArgs: [id],
    );
  }

  // 永久删除照片（返回 asset_id 供调用方删除设备文件）

  Future<String?> permanentDeletePhoto(int id) async {
    final db = await database;

    final result = await db.query(
      'photos',

      where: 'id=?',

      whereArgs: [id],

      limit: 1,
    );

    final assetId = result.isNotEmpty
        ? result.first['asset_id'] as String
        : null;

    await db.delete('photos', where: 'id=?', whereArgs: [id]);

    return assetId;
  }

  // 批量恢复回收站照片

  Future<int> restoreAllPhotos() async {
    final db = await database;

    return await db.update(
      'photos',

      {'status': 0, 'delete_time': null},

      where: 'status=?',

      whereArgs: [2],
    );
  }

  // 清空回收站（返回 asset_id 列表供调用方删除设备文件）

  Future<List<String>> clearRecycleBin() async {
    final db = await database;

    final result = await db.query(
      'photos',

      columns: ['asset_id'],

      where: 'status=?',

      whereArgs: [2],
    );

    final assetIds = result
        .map((r) => r['asset_id'] as String)
        .toList();

    await db.delete('photos', where: 'status=?', whereArgs: [2]);

    return assetIds;
  }

  // 清理超过指定天数的回收站记录

  Future<int> deleteExpiredPhotos(int days) async {
    final db = await database;

    final cutoff = DateTime.now().subtract(Duration(days: days)).millisecondsSinceEpoch;

    return await db.delete(
      'photos',

      where: 'status=? AND delete_time < ?',

      whereArgs: [2, cutoff],
    );
  }

  // 获取某分类下的照片

  Future<List<Map<String, dynamic>>> getPhotosByCategory(int categoryId) async {
    final db = await database;

    return await db.query(
      'photos',

      where: 'category_id=? AND status=?',

      whereArgs: [categoryId, 1],

      orderBy: 'create_time DESC',
    );
  }

  // 获取某分类的照片数量

  Future<int> getCategoryPhotoCount(int categoryId) async {
    final db = await database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM photos WHERE category_id=? AND status=?',

      [categoryId, 1],
    );

    return result.first['cnt'] as int? ?? 0;
  }

  // 获取已整理照片总数

  Future<int> getOrganizedCount() async {
    final db = await database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM photos WHERE status=?',

      [1],
    );

    return result.first['cnt'] as int? ?? 0;
  }

  // 按媒体类型获取已整理数量

  Future<int> getOrganizedCountByType(int mediaType) async {
    final db = await database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM photos WHERE status=? AND media_type=?',

      [1, mediaType],
    );

    return result.first['cnt'] as int? ?? 0;
  }

  // 获取已处理的 asset_id 集合（避免重复加载）

  Future<Set<String>> getProcessedAssetIds() async {
    final db = await database;

    final result = await db.query(
      'photos',

      columns: ['asset_id'],

      where: 'status IN (?, ?)',

      whereArgs: [1, 2],
    );

    return result.map((r) => r['asset_id'] as String).toSet();
  }

  // 获取回收站照片数量

  Future<int> getRecycleBinCount() async {
    final db = await database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM photos WHERE status=?',

      [2],
    );

    return result.first['cnt'] as int? ?? 0;
  }

  // 批量移出分类

  Future<int> removeFromCategory(List<int> photoIds) async {
    if (photoIds.isEmpty) return 0;

    final db = await database;

    final placeholders = photoIds.map((_) => '?').join(',');

    return await db.update(
      'photos',

      {'category_id': null, 'status': 0},

      where: 'id IN ($placeholders)',

      whereArgs: photoIds,
    );
  }

  // 合并分类：将 fromId 分类下的照片移动到 toId 分类

  Future<int> mergeCategories(int fromId, int toId) async {
    final db = await database;

    final count = await db.update(
      'photos',

      {'category_id': toId},

      where: 'category_id=? AND status=?',

      whereArgs: [fromId, 1],
    );

    // 合并后删除源分类

    await db.delete('categories', where: 'id=?', whereArgs: [fromId]);

    return count;
  }

  // 批量修改照片分类

  Future<int> batchUpdateCategory(
    List<int> photoIds,

    int categoryId,
  ) async {
    if (photoIds.isEmpty) return 0;

    final db = await database;

    final placeholders = photoIds.map((_) => '?').join(',');

    return await db.update(
      'photos',

      {'category_id': categoryId, 'status': 1},

      where: 'id IN ($placeholders)',

      whereArgs: photoIds,
    );
  }
}
