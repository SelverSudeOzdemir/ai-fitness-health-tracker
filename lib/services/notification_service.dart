import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // Paket nesnesini singleton mantığıyla tanımlıyoruz
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Uygulama başlarken main.dart içinde çağrılan başlatma fonksiyonu
  static Future<void> initialize() async {
    // Zaman dilimi verilerini yüklüyoruz (Zamanlanmış bildirimler için şart)
    tz.initializeTimeZones();

    // Android için bildirim ikonu ayarı.
    // 'mipmap/ic_launcher' varsayılan uygulama ikonunu kullanır.
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS için izin ve ilk kurulum ayarları
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    // Servisi başlatıyoruz
    await _notificationsPlugin.initialize(
      settings: initializationSettings, // <--- Başına 'settings:' ekledik
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        print("Bildirime tıklandı: ${details.payload}");
      },
    );

    tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));

  }

  /// Anlık Bildirim Gönderme
  static Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await _notificationsPlugin.show(
      id: id, // <-- 'id:' eklendi
      title: title, // <-- 'title:' eklendi
      body: body, // <-- 'body:' eklendi
      notificationDetails:
          await _notificationDetails(), // <-- 'notificationDetails:' eklendi
      payload: payload,
    );
  }

  /// İleri Bir Saate Zamanlanmış Bildirim Gönderme 
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    // Gönderilecek zamanı yerel zaman dilimine çeviriyoruz
    final tz.TZDateTime tzScheduledTime = tz.TZDateTime.from(
      scheduledTime,
      tz.local,
    );

    // Eğer seçilen zaman geçmişteyse bildirim planlanmaz
    if (tzScheduledTime.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _notificationsPlugin.zonedSchedule(
      id: id, // <-- 'id:' eklendi
      title: title, // <-- 'title:' eklendi
      body: body, // <-- 'body:' eklendi
      scheduledDate: tzScheduledTime, // <-- 'scheduledDate:' eklendi
      notificationDetails:
          await _notificationDetails(), // <-- 'notificationDetails:' eklendi
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  /// Planlanmış Belirli Bir Bildirimi İptal Etme
  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id: id); // <-- 'id:' eklendi
  }

  /// Tüm Bildirimleri Temizleme
  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  /// Android ve iOS için detaylı bildirim yapılandırması
  static Future<NotificationDetails> _notificationDetails() async {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'fitness_tracker_channel', // Kanal ID (Android için benzersiz olmalı)
        'Fitness Hatırlatıcıları', // Kullanıcının ayarlarda göreceği kanal adı
        channelDescription: 'Antrenman ve sağlık hatırlatmaları içerir.',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }
}
