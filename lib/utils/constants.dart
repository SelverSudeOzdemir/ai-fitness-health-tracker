class ApiConstants {
  // EMÜLATÖRde: 10.0.2.2:3000
  // FİZİKSEL CİHAZda: Bilgisayarın IP'si (örn: 192.168.1.100:3000)
  // PRODUCTION: https://api.example.com

  static const String baseUrl = 'http://10.0.2.2:3000';

  static const String itemsEndpoint = '$baseUrl/api/items';
  static const String usersEndpoint = '$baseUrl/api/users';
  static const String authEndpoint = '$baseUrl/api/auth';

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

class AppConstants {
  static const String appName = 'AI Fitness Health Tracker';
  static const String appVersion = '1.0.0';
}

class StringConstants {
  static const String loading = 'Yükleniyor...';
  static const String error = 'Hata oluştu';
  static const String retry = 'Tekrar Dene';
  static const String noData = 'Veri bulunamadı';
  static const String welcome = 'Hoş Geldiniz';
  static const String itemDeleted = 'Ürün silindi';
  static const String itemAdded = 'Ürün eklendi';
  static const String itemUpdated = 'Ürün güncellendi';
}
