import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:nutrify/di/service_locator.dart';
import 'package:nutrify/services/profile_api_service.dart';
import 'package:nutrify/services/food_log_api_service.dart';
import 'package:nutrify/utils/meal_type_mapper.dart';
import 'package:nutrify/presentation/my_app.dart';
import 'package:nutrify/screens/add_meal_screen.dart';
import 'dart:io';

// Step 2 & 4: Top-level background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
     if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
     }
     print("Handling a background message: ${message.messageId}");
  } catch (e) {
    print("Background Handler Error: $e");
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  final FoodLogApiService _foodLogApi = FoodLogApiService();
  
  // Helper to check if Firebase is ready
  bool get _isFirebaseReady => Firebase.apps.isNotEmpty;

  Future<void> init() async {
    // 0. Initialize Timezones
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    
    // 1. Initialize Local Notifications (Always works)
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        if (payload != null && payload.startsWith('meal:')) {
          final mealType = payload.replaceFirst('meal:', '');
          MyApp.navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (_) => AddMealScreen(mealType: mealType),
            ),
          );
        }
      },
    );

    // 2. Setup Notification Categories/Channels (Android)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 3. Initialize Firebase Messaging Features (Only if Firebase was initialized in main.dart)
    if (_isFirebaseReady) {
      try {
        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

        // Listen for foreground messages
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          RemoteNotification? notification = message.notification;
          AndroidNotification? android = message.notification?.android;

          if (notification != null && android != null) {
            _notificationsPlugin.show(
              id: notification.hashCode,
              title: notification.title,
              body: notification.body,
              notificationDetails: NotificationDetails(
                android: AndroidNotificationDetails(
                  channel.id,
                  channel.name,
                  channelDescription: channel.description,
                  icon: android.smallIcon,
                ),
              ),
            );
          }
        });
      } catch (e) {
        print("Firebase Messaging setup failed: $e");
      }
    } else {
      print("Push Notifications (FCM) disabled: Firebase not initialized.");
    }
  }

  // Step 1: Register Device & Get Token
  Future<void> registerPushNotifications() async {
    if (!_isFirebaseReady) return;

    // A. Request Permissions
    final status = await requestPermissions();
    if (!status) return;

    try {
      // B. Get FCM Token
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        print("FCM Token: $token");
        // C. Send to Server (Supabase via ProfileApiService)
        await getIt<ProfileApiService>().updateFcmToken(token);
      }
    } catch (e) {
      print("Error getting FCM token: $e");
    }
  }

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid || Platform.isIOS) {
      // 1. Request Notification Permission
      var status = await Permission.notification.status;
      if (status.isDenied) {
        status = await Permission.notification.request();
      }
      
      // 2. Request Exact Alarm Permission (Android 12+)
      if (Platform.isAndroid) {
        var alarmStatus = await Permission.scheduleExactAlarm.status;
        if (alarmStatus.isDenied) {
          await Permission.scheduleExactAlarm.request();
        }
      }

      if (status.isPermanentlyDenied) {
        return false;
      }
      
      // Also request via FCM specifically for iOS if Firebase is ready
      if (Platform.isIOS && _isFirebaseReady) {
        try {
          await FirebaseMessaging.instance.requestPermission(
            alert: true,
            badge: true,
            sound: true,
          );
        } catch (e) {}
      }

      return status.isGranted;
    }
    return false;
  }

  // --- Local Reminders Logic (Existing) ---

  Future<void> scheduleMealReminders() async {
    try {
      await cancelAllNotifications();

      // 1. Fetch Today's Planned/Logged Meals
      List<FoodLogEntry> todayLogs = [];
      try {
        todayLogs = await _foodLogApi.getLogs(DateTime.now());
      } catch (e) {
        print("Could not fetch today's logs for notifications: $e");
      }

      // 2. Group logs by meal time
      String getMenuFor(String mealApiType) {
        final items = todayLogs.where((l) => l.mealTime == mealApiType).toList();
        if (items.isEmpty) return "";
        return items.map((e) => e.foodName).join(', ');
      }

      final breakfastMenu = getMenuFor('Breakfast');
      final lunchMenu = getMenuFor('Lunch');
      final snackMenu = getMenuFor('Snack');
      final dinnerMenu = getMenuFor('Dinner');

      // 3. Schedule with dynamic content and specific time ranges
      await _scheduleLocalNotification(
        id: 1,
        title: 'Makan Pagi Yuk! (07.00 - 08.00)',
        body: breakfastMenu.isNotEmpty
            ? 'Menu sarapanmu: $breakfastMenu. Jangan lupa makan ya!'
            : 'Waktunya sarapan sehat untuk memulai harimu dengan energi!',
        hour: 7,
        minute: 0,
        payload: 'meal:Breakfast',
      );

      await _scheduleLocalNotification(
        id: 2,
        title: 'Sudah Jam Makan Siang! (12.00 - 13.00)',
        body: lunchMenu.isNotEmpty
            ? 'Menu makan siangmu: $lunchMenu. Yuk isi ulang tenagamu!'
            : 'Jangan lupa istirahat dan isi ulang tenagamu dengan makan siang gizi seimbang.',
        hour: 12,
        minute: 0,
        payload: 'meal:Lunch',
      );

      await _scheduleLocalNotification(
        id: 3,
        title: 'Camilan Sore! (15.00 - 16.00)',
        body: snackMenu.isNotEmpty
            ? 'Camilan soremu: $snackMenu. Tetap jaga energi di sore hari!'
            : 'Sudah sore, yuk cemil sesuatu yang sehat untuk menjaga energi!',
        hour: 15,
        minute: 0,
        payload: 'meal:Snack',
      );

      await _scheduleLocalNotification(
        id: 4,
        title: 'Waktunya Makan Malam! (18.00 - 19.00)',
        body: dinnerMenu.isNotEmpty
            ? 'Menu makan malammu: $dinnerMenu. Nikmati hidangan penutup harimu!'
            : 'Penuhi kebutuhan nutrisi harianmu sebelum beristirahat malam ini.',
        hour: 18,
        minute: 0,
        payload: 'meal:Dinner',
      );
    } catch (e) {
      print("Error scheduling meal reminders: $e");
    }
  }

  Future<void> _scheduleLocalNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    // Check for exact alarm permission
    bool canScheduleExact = true;
    if (Platform.isAndroid) {
      canScheduleExact = await Permission.scheduleExactAlarm.isGranted;
    }

    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: _nextInstanceOfTime(hour, minute),
      payload: payload,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'meal_reminders',
          'Meal Reminders',
          channelDescription: 'Notifications for daily meal times',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: canScheduleExact 
          ? AndroidScheduleMode.exactAllowWhileIdle 
          : AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}
