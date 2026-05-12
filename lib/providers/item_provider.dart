import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/api_service.dart';
import '../services/data_service.dart';

class ItemProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final DataService _dataService = DataService();

  List<Item> _items = [];
  List<Item> _filteredItems = [];
  bool _isLoading = false;
  String _error = '';
  bool _isOnline = true;

  // Getters
  List<Item> get items => _filteredItems.isEmpty ? _items : _filteredItems;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isOnline => _isOnline;

  // ==================== ÜRÜNLERI YÜKLE ====================

  Future<void> loadItems({bool forceOnline = false}) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // Online ise API'den çek
      if (forceOnline || _isOnline) {
        try {
          _items = await _apiService.getItems();
          _isOnline = true;

          // Yerel olarak kaydet
          await _dataService.saveItems(_items);
        } catch (e) {
          // API hatası, yerel veriyi kullan
          _isOnline = false;
          _items = await _dataService.getLocalItems();

          if (_items.isEmpty) {
            _error = 'İnternet bağlantısı yok ve yerel veri bulunamadı';
          }
        }
      } else {
        // Offline - yerel veriyi kullan
        _items = await _dataService.getLocalItems();
        if (_items.isEmpty) {
          _error = 'Veri bulunamadı';
        }
      }
    } catch (e) {
      _error = 'Hata: $e';
      _items = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==================== ÜRÜN DETAY ====================

  Future<Item?> getItemById(int id) async {
    try {
      return await _apiService.getItemById(id);
    } catch (e) {
      _error = 'Hata: $e';
      notifyListeners();
      return null;
    }
  }

  // ==================== ÜRÜN EKLE ====================

  Future<bool> addItem(Item item) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newItem = await _apiService.createItem(item);
      _items.add(newItem);

      // Yerel olarak kaydet
      await _dataService.saveItem(newItem);

      _error = '';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Ürün eklenirken hata: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ==================== ÜRÜN GÜNCELLE ====================

  Future<bool> updateItem(int id, Item item) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updatedItem = await _apiService.updateItem(id, item);

      final index = _items.indexWhere((i) => i.id == id);
      if (index != -1) {
        _items[index] = updatedItem;
      }

      // Yerel olarak güncelle
      await _dataService.saveItem(updatedItem);

      _error = '';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Güncelleme hatası: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ==================== ÜRÜN SİL ====================

  Future<bool> deleteItem(int id) async {
    try {
      await _apiService.deleteItem(id);
      _items.removeWhere((item) => item.id == id);

      // Yerel olarak sil
      await _dataService.deleteItem(id);

      _error = '';
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Silme hatası: $e';
      notifyListeners();
      return false;
    }
  }

  // ==================== ÜRÜN ARA ====================

  Future<void> searchItems(String query) async {
    if (query.isEmpty) {
      _filteredItems = [];
      notifyListeners();
      return;
    }

    try {
      _filteredItems = await _apiService.searchItems(query);
      _error = '';
    } catch (e) {
      _error = 'Arama hatası: $e';
    }
    notifyListeners();
  }

  void clearSearch() {
    _filteredItems = [];
    notifyListeners();
  }

  // ==================== YENİLE ====================

  Future<void> refresh() async {
    await loadItems(forceOnline: true);
  }
}
