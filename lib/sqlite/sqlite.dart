import 'package:sqflite/sqflite.dart';

class Sqlite {
  static Database? _db;
  static final Sqlite instance = Sqlite._constructor();

  Sqlite._constructor();

  Future<Database> get database async {
    if (_db != null) {
      return _db!;
    }

    _db = await getDataBase();
    return _db!;
  }

  init() async {
    final db = await database;

    await db.execute('''
    CREATE TABLE IF NOT EXISTS emoji (
      name TEXT PRIMARY KEY,
      type TEXT NOT NULL,
      data BLOB NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS user (
      uuid                        TEXT NOT NULL PRIMARY KEY,
      username                    TEXT NOT NULL,
      full_name                   TEXT NOT NULL,
      biography                   TEXT,
      profile_picture             TEXT,
      following_count             INTEGER NOT NULL,
      follower_count              INTEGER NOT NULL,
      like_count                  INTEGER NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS user_settings (
      username                    TEXT NOT NULL PRIMARY KEY,
      full_name                   TEXT NOT NULL,
      email_address               TEXT NOT NULL,
      phone_number                TEXT,
      date_of_birth               TEXT,
      gender                      TEXT,
      biography                   TEXT,
      two_a_factor_auth           INTEGER NOT NULL,
      friend_request_notification INTEGER NOT NULL,
      following_notification      INTEGER NOT NULL,
      appreciation_notification   INTEGER NOT NULL,
      comment_notification        INTEGER NOT NULL,
      tag_notification            INTEGER NOT NULL
    )
    ''');



    await db.execute('''
    CREATE TABLE IF NOT EXISTS post (
      uuid          TEXT PRIMARY KEY,
      caption       TEXT,
      images        TEXT NOT NULL,
      videos        TEXT NOT NULL,
      created_at    TEXT NOT NULL,
      owner         TEXT NOT NULL,
      is_liked      INTEGER NOT NULL,
      like_count    INTEGER NOT NULL,
      comment_count INTEGER NOT NULL
    )
    ''');
  }

  Future<Database> getDataBase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = '$databaseDirPath/fanari.db';
    final database = await openDatabase(
      databasePath,
      version: 1,
    );

    return database;
  }

  Future<bool> insert({
    required String table,
    required Map<String, dynamic> data,
  }) async {
    final db = await database;

    final count = await db.insert(
      table,
      data,
    );

    return count != 0;
  }

  Future<bool> insertMany({
    required String table,
    required List<Map<String, dynamic>> dataList,
  }) async {
    final db = await database;

    for (final data in dataList) {
      final count = await db.insert(
        table,
        data,
      );

      if (count == 0) {
        return false;
      }
    }

    return true;
  }

  Future<List<Map<String, dynamic>>> query({
    required String table,
    String? where,
    int? limit,
    int? offset,
    String? orderBy,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      limit: limit,
      offset: offset,
      orderBy: orderBy,
    );
  }

  Future<int> delete({
    required String table,
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;

    return await db.delete(
      table,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<bool> update({
    required String table,
    required Map<String, dynamic> data,
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    final count = await db.update(
      table,
      data,
      where: where,
      whereArgs: whereArgs,
    );

    return count != 0;
  }
}
