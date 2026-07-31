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

      version: 6,

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

    if (oldVersion < 5) {
      await _createPrivateTables(db);
    }

    if (oldVersion < 6) {
      // photos表添加 name 字段（用户自定义名称）
      await db.execute(
        'ALTER TABLE photos ADD COLUMN name TEXT DEFAULT ""',
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

      name TEXT DEFAULT '',

      delete_time INTEGER,

      create_time INTEGER NOT NULL,

      FOREIGN KEY(category_id)

      REFERENCES categories(id)

    )

    ''');

    await _insertDefaultCategories(db);

    await _insertDefaultVideoCategories(db);

    await _createPrivateTables(db);
  }

  Future<void> _createPrivateTables(Database db) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS private_albums (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      icon TEXT NOT NULL,
      color TEXT NOT NULL,
      media_type INTEGER NOT NULL DEFAULT 0,
      create_time INTEGER NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS private_photos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      asset_id TEXT NOT NULL,
      album_id INTEGER NOT NULL,
      media_type INTEGER NOT NULL DEFAULT 0,
      create_time INTEGER NOT NULL,
      FOREIGN KEY(album_id) REFERENCES private_albums(id)
    )
    ''');

    // PIN 码存储表（只存一条记录）
    await db.execute('''
    CREATE TABLE IF NOT EXISTS private_lock (
      id INTEGER PRIMARY KEY CHECK (id = 1),
      pin_hash TEXT NOT NULL,
      create_time INTEGER NOT NULL
    )
    ''');
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

  // 获取已保留但未分类的照片

  Future<List<Map<String, dynamic>>> getKeptUncategorizedPhotos({int? mediaType}) async {
    final db = await database;

    String where = 'status=? AND category_id IS NULL';

    List<dynamic> whereArgs = [1];

    if (mediaType != null) {
      where += ' AND media_type=?';

      whereArgs.add(mediaType);
    }

    return await db.query(
      'photos',

      where: where,

      whereArgs: whereArgs,

      orderBy: 'create_time DESC',
    );
  }

  // 获取已保留未分类的照片数量

  Future<int> getKeptUncategorizedCount({int? mediaType}) async {
    final db = await database;

    String where = 'status=? AND category_id IS NULL';

    List<dynamic> whereArgs = [1];

    if (mediaType != null) {
      where += ' AND media_type=?';

      whereArgs.add(mediaType);
    }

    final result = await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM photos WHERE $where',

      whereArgs,
    );

    return result.first['cnt'] as int? ?? 0;
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

  // 获取已处理的 asset_id 集合（避免重复加载，包含私密照片）

  Future<Set<String>> getProcessedAssetIds() async {
    final db = await database;

    final result = await db.query(
      'photos',

      columns: ['asset_id'],

      where: 'status IN (?, ?)',

      whereArgs: [1, 2],
    );

    // 同时获取私密相册中的 asset_id
    final privateResult = await db.query('private_photos', columns: ['asset_id']);

    final ids = result.map((r) => r['asset_id'] as String).toSet();

    ids.addAll(privateResult.map((r) => r['asset_id'] as String));

    return ids;
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

  // ==================== 私密相册相关 ====================

  // 获取所有私密相册

  Future<List<Map<String, dynamic>>> getPrivateAlbums({int? mediaType}) async {
    final db = await database;

    if (mediaType != null) {
      return await db.query(
        'private_albums',

        where: 'media_type=?',

        whereArgs: [mediaType],

        orderBy: 'create_time DESC',
      );
    }

    return await db.query('private_albums', orderBy: 'create_time DESC');
  }

  // 创建私密相册

  Future<int> addPrivateAlbum({
    required String name,

    required String icon,

    required String color,

    int mediaType = 0,
  }) async {
    final db = await database;

    return await db.insert('private_albums', {
      'name': name,

      'icon': icon,

      'color': color,

      'media_type': mediaType,

      'create_time': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // 删除私密相册（同时删除关联照片记录）

  Future<int> deletePrivateAlbum(int id) async {
    final db = await database;

    await db.delete('private_photos', where: 'album_id=?', whereArgs: [id]);

    return await db.delete('private_albums', where: 'id=?', whereArgs: [id]);
  }

  // 修改私密相册

  Future<int> updatePrivateAlbum({
    required int id,

    required String name,

    required String icon,

    required String color,
  }) async {
    final db = await database;

    return await db.update(
      'private_albums',

      {'name': name, 'icon': icon, 'color': color},

      where: 'id=?',

      whereArgs: [id],
    );
  }

  // 添加照片到私密相册

  Future<int> addPhotoToPrivateAlbum({
    required String assetId,

    required int albumId,

    int mediaType = 0,
  }) async {
    final db = await database;

    // 检查是否已在私密相册中
    final existing = await db.query(
      'private_photos',

      where: 'asset_id=?',

      whereArgs: [assetId],
    );

    if (existing.isNotEmpty) {
      // 已存在则更新
      await db.update(
        'private_photos',

        {'album_id': albumId},

        where: 'asset_id=?',

        whereArgs: [assetId],
      );

      return existing.first['id'] as int;
    }

    return await db.insert('private_photos', {
      'asset_id': assetId,

      'album_id': albumId,

      'media_type': mediaType,

      'create_time': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // 从私密相册移除照片

  Future<int> removePhotoFromPrivateAlbum(String assetId) async {
    final db = await database;

    return await db.delete('private_photos', where: 'asset_id=?', whereArgs: [assetId]);
  }

  // 获取私密相册中的照片

  Future<List<Map<String, dynamic>>> getPrivatePhotos(int albumId) async {
    final db = await database;

    return await db.query(
      'private_photos',

      where: 'album_id=?',

      whereArgs: [albumId],

      orderBy: 'create_time DESC',
    );
  }

  // 获取私密相册中的照片数量

  Future<int> getPrivatePhotoCount(int albumId) async {
    final db = await database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM private_photos WHERE album_id=?',

      [albumId],
    );

    return result.first['cnt'] as int? ?? 0;
  }

  // 获取所有私密照片的 asset_id 集合

  Future<Set<String>> getPrivateAssetIds() async {
    final db = await database;

    final result = await db.query('private_photos', columns: ['asset_id']);

    return result.map((r) => r['asset_id'] as String).toSet();
  }

  // 检查 asset_id 是否在私密相册中

  Future<bool> isPrivatePhoto(String assetId) async {
    final db = await database;

    final result = await db.query(
      'private_photos',

      where: 'asset_id=?',

      whereArgs: [assetId],
    );

    return result.isNotEmpty;
  }

  // ==================== PIN 锁相关 ====================

  // 保存 PIN 码（存储简单 hash）

  Future<void> savePin(String pin) async {
    final db = await database;

    final hash = _simpleHash(pin);

    final existing = await db.query('private_lock', where: 'id=1');

    if (existing.isNotEmpty) {
      await db.update(
        'private_lock',

        {'pin_hash': hash, 'create_time': DateTime.now().millisecondsSinceEpoch},

        where: 'id=1',
      );
    } else {
      await db.insert('private_lock', {
        'id': 1,

        'pin_hash': hash,

        'create_time': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  // 验证 PIN 码

  Future<bool> verifyPin(String pin) async {
    final db = await database;

    final result = await db.query('private_lock', where: 'id=1');

    if (result.isEmpty) return false;

    final storedHash = result.first['pin_hash'] as String;

    return storedHash == _simpleHash(pin);
  }

  // 是否已设置 PIN

  Future<bool> hasPinSet() async {
    final db = await database;

    final result = await db.query('private_lock', where: 'id=1');

    return result.isNotEmpty;
  }

  // 删除 PIN

  Future<void> deletePin() async {
    final db = await database;

    await db.delete('private_lock', where: 'id=1');
  }

  // 简单 hash（生产环境建议用 bcrypt 等）

  String _simpleHash(String input) {
    int hash = 0;

    for (int i = 0; i < input.length; i++) {
      hash = (hash * 31 + input.codeUnitAt(i)) & 0x7FFFFFFF;
    }

    return hash.toRadixString(16);
  }

  // 根据名称搜索照片（模糊匹配）

  Future<List<Map<String, dynamic>>> searchPhotosByName(String keyword) async {
    final db = await database;

    return await db.query(
      'photos',

      where: 'name LIKE ? AND status = 1',

      whereArgs: ['%$keyword%'],

      orderBy: 'create_time DESC',
    );
  }

  // 更新照片名称

  Future<void> updatePhotoName(int photoId, String name) async {
    final db = await database;

    await db.update(
      'photos',

      {'name': name},

      where: 'id=?',

      whereArgs: [photoId],
    );
  }

  // 将照片从分类移到私密相册（清除分类关联，标记为已处理）

  Future<void> moveToPrivate(int photoId) async {
    final db = await database;

    await db.update(
      'photos',

      {'category_id': null, 'status': 1},

      where: 'id=?',

      whereArgs: [photoId],
    );
  }

  // 获取有名称的照片（用于搜索展示）

  Future<List<Map<String, dynamic>>> getNamedPhotos() async {
    final db = await database;

    return await db.query(
      'photos',

      where: "name != '' AND name IS NOT NULL AND status = 1",

      orderBy: 'create_time DESC',
    );
  }
}
