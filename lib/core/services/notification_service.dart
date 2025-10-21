import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../presentation/screens/main/nutrition_detail_recommendation_screen.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  // Ini akan dipanggil ketika app di-terminated/background
  // Kita tidak bisa langsung navigate di sini
  // Payload akan dihandle saat app dibuka
  print('Background notification tapped: ${response.payload}');
}

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  NotificationService._init();

  late final GlobalKey<NavigatorState> navigatorKey;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init(GlobalKey<NavigatorState> navKey) async {
    navigatorKey = navKey;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Di v18, onDidReceiveLocalNotification sudah tidak digunakan lagi
    // Gunakan onDidReceiveNotificationResponse untuk semua platform
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      // HARUS top-level function, bukan instance method
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // Request permission untuk Android 13+
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidImplementation?.requestNotificationsPermission();

    // Request permission untuk iOS (opsional, karena sudah di initialization settings)
    final iosImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    await iosImplementation?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    if (response.payload != null && response.payload!.isNotEmpty) {
      final payloadData = response.payload!;
      if (payloadData.startsWith('recommendation_')) {
        final memberName = payloadData.split('_').last;
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => NutritionDetailRecommendationScreen(
              initialMemberName: memberName,
            ),
          ),
        );
      }
    }
  }

  Future<void> showNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'tumbuh_sehat_channel_id',
          'Tumbuh Sehat Notifications',
          channelDescription: 'Channel for Tumbuh Sehat app notifications',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
          // Opsional: tambahan styling untuk Android
          styleInformation: BigTextStyleInformation(''),
          playSound: true,
          enableVibration: true,
        );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    await _notificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // Method tambahan: Cancel notifikasi
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  // Method tambahan: Cancel semua notifikasi
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  // Method tambahan: Schedule notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String payload,
  }) async {
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'tumbuh_sehat_channel_id',
          'Tumbuh Sehat Notifications',
          channelDescription: 'Channel for Tumbuh Sehat app notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }
}
