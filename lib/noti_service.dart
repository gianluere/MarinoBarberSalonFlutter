import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotiService{
  final notificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  //init
  Future<void> initNotification() async{
    if(_isInitialized) return;

    //impostazioni per android
    const initSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');


    //impostazioni per ios
    const initSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true
    );

    //init settings
    const initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIOS
    );

    await notificationsPlugin.initialize(initSettings);

  }

  //Setup Dettagli notifiche
  NotificationDetails notificationDetails(){
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_channel_id',
        'Daily Notifications',
        channelDescription: 'Daily Notifications Channel',
        importance: Importance.max,
        priority: Priority.high
      ),
      iOS: DarwinNotificationDetails()
    );
  }

  //Mostra notifica
  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
  }) async{
    return notificationsPlugin.show(id, title, body, const NotificationDetails());
  }


}