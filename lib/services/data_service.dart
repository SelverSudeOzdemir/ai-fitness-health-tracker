import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/item.dart';

class DataService {
  static final DataService _instance = DataService._internal();
  late Database _database;

  factory DataService() {
    return _instance;
  }

  DataService._internal();

  Future<Database> get database async {
    _database = await _initDatabase();
    return _database;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_database.db');

    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE items(
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL,
        image_url TEXT,
        category TEXT,
        stock_quantity INTEGER,
        user_id INTEGER,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY,
        username TEXT NOT NULL,
        email TEXT NOT NULL,
        first_name TEXT,
        last_name TEXT,
        created_at TEXT
      )
    ''');
  }

  // ==================== ITEMS ====================

  /// Yerel olarak ürünleri kaydet
  Future<void> saveItems(List<Item> items) async {
    final db = await database;
    await db.delete('items'); // Önce hepsini sil

    for (var item in items) {
      await db.insert('items', _itemToMap(item));
    }
  }

  /// Yerel olarak ürünleri getir
  Future<List<Item>> getLocalItems() async {
    final db = await database;
    final maps = await db.query('items');

    return List.generate(maps.length, (i) {
      return Item(
        id: maps[i]['id'] as int,
        title: maps[i]['title'] as String,
        description: maps[i]['description'] as String?,
        price: maps[i]['price'] as double,
        imageUrl: maps[i]['image_url'] as String?,
        category: maps[i]['category'] as String?,
        stockQuantity: maps[i]['stock_quantity'] as int?,
        userId: maps[i]['user_id'] as int?,
        createdAt: maps[i]['created_at'] as String?,
      );
    });
  }

  /// Tekil ürünü kaydet
  Future<void> saveItem(Item item) async {
    final db = await database;
    await db.insert(
      'items',
      _itemToMap(item),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Ürünü sil
  Future<void> deleteItem(int id) async {
    final db = await database;
    await db.delete('items', where: 'id = ?', whereArgs: [id]);
  }

  /// Tüm ürünleri sil
  Future<void> clearAllItems() async {
    final db = await database;
    await db.delete('items');
  }

  Map<String, dynamic> _itemToMap(Item item) {
    return {
      'id': item.id,
      'title': item.title,
      'description': item.description,
      'price': item.price,
      'image_url': item.imageUrl,
      'category': item.category,
      'stock_quantity': item.stockQuantity,
      'user_id': item.userId,
      'created_at': item.createdAt,
    };
  }

  // ==================== USERS ====================

  /// Kullanıcı bilgilerini kaydet
  Future<void> saveUser(User user) async {
    final db = await database;
    await db.insert('users', {
      'id': user.id,
      'username': user.username,
      'email': user.email,
      'first_name': user.firstName,
      'last_name': user.lastName,
      'created_at': user.createdAt,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Kullanıcı bilgilerini getir
  Future<User?> getUser(int id) async {
    final db = await database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);

    if (maps.isEmpty) return null;

    final map = maps.first;
    return User(
      id: map['id'] as int,
      username: map['username'] as String,
      email: map['email'] as String,
      firstName: map['first_name'] as String?,
      lastName: map['last_name'] as String?,
      createdAt: map['created_at'] as String?,
    );
  }

  // ==================== PREFS ====================

  /// Token kaydet
  Future<void> saveToken(String token) async {
    // SharedPreferences kullanabilir veya SQLite
    // Şimdilik SQLite kullanıyoruz
  }

  /// Token getir
  Future<String?> getToken() async {
    // Token getir
    return null;
  }
}
