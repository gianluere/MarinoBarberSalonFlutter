import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';


class NotiService{
  final notificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  //init
  Future<void> initNotification() async{
    if(_isInitialized) return;

    //init timezone
    tz.initializeTimeZones();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    print("Curr tz: $currentTimeZone");
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

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
    _isInitialized = true;

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

  //Mostra notifica istantanea
  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
  }) async{
    return notificationsPlugin.show(id, title, body, notificationDetails());
  }

  //Notifica programmata
  Future<void> scheduleNotification({
    int id = 1,
    required String title,
    required String body,
    required int hour,
    required int minute
  }) async {

    //dataora locale attuale
    final now = tz.TZDateTime.now(tz.local);


    print('tz noti: $now');
    print('TZ LOCAL: ${tz.local.toString()}, ${now.day}');

    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute
    );

    await notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        await notificationDetails(),

        //impostazione per ios: usa time specified
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,

        //impostazione android: permette notifiche in low-power mode
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    print("Schedulata per $scheduledDate");


  }

  Future<void> cancellAllNotifications() async{
    await notificationsPlugin.cancelAll();
  }


}