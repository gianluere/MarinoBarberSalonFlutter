import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
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

    await requestNotificationPermissions();

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
        'scheduled_notifications', // ID del canale (deve essere univoco e lo stesso usato per tutte le notifiche)
        'Scheduled Notifications', // Nome del canale
        channelDescription: 'Channel for scheduled notifications',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true, // Assicura che il suono sia abilitato
        enableVibration: true, // Attiva la vibrazione
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
    required String data,
  }) async {


    if(Platform.isAndroid){
      PermissionStatus alarmStatus = await Permission.scheduleExactAlarm.status;
      PermissionStatus notificationStatus = await Permission.notification.status;
      if (!alarmStatus.isGranted || !notificationStatus.isGranted) {
        await requestNotificationPermissions();
        if (!alarmStatus.isGranted || !notificationStatus.isGranted) return;
      }
    }

    //dataora locale attuale
    final now = tz.TZDateTime.now(tz.local);


    print('tz noti: $now');
    print('TZ LOCAL: ${tz.local.toString()}, ${now.day}');

    // Parsing della data (dd-MM-yyyy)
    DateTime dataFormattata = DateFormat('dd-MM-yyyy').parse(data);


    var scheduledDate = tz.TZDateTime(
      tz.local,
      dataFormattata.year,
      dataFormattata.month,
      dataFormattata.day,
      8,
      0
    );


    await notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        notificationDetails(),

        //impostazione per ios: usa time specified
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,

        //impostazione android: permette notifiche in low-power mode
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

        //matchDateTimeComponents: DateTimeComponents.time
    );

    print("Schedulata per $scheduledDate");


  }

  Future<void> cancellAllNotifications() async{
    await notificationsPlugin.cancelAll();
  }

  Future<void> checkPendingNotifications() async {
    final pending = await notificationsPlugin.pendingNotificationRequests();
    print("Notifiche pianificate: ${pending.length}");
    for (var noti in pending) {
      print("ID: ${noti.id}, Titolo: ${noti.title}, Corpo: ${noti.body}");
    }
  }

  Future<void> requestNotificationPermissions() async {

    if (!Platform.isAndroid) return;

    //Controlla se i permessi di notifiche sono concessi
    PermissionStatus notificationStatus = await Permission.notification.status;
    if (!notificationStatus.isGranted) {
      notificationStatus = await Permission.notification.request();
    }

    //Controlla se il permesso SCHEDULE_EXACT_ALARM è necessario (solo Android 14+)
    PermissionStatus alarmStatus = await Permission.scheduleExactAlarm.status;
    if (!alarmStatus.isGranted) {
      alarmStatus = await Permission.scheduleExactAlarm.request();
    }

    if (notificationStatus.isGranted && alarmStatus.isGranted) {
      print("Tutti i permessi concessi!");
    } else {
      print("Permessi negati. L'utente deve abilitarli manualmente.");
    }
  }



}