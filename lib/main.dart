import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

 

// void main() async{
//   WidgetsFlutterBinding.ensureInitialized();
//   await _configureLocalTimeZone();
//   runApp(const MyApp());
// }

// //Для коректн. установки локального времени, чтобы установить schedule interval
// Future<void> _configureLocalTimeZone() async {
//   tz.initializeTimeZones();
//   final String? timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
//   tz.setLocalLocation(tz.getLocation(timeZoneName!));
// }

void main() {
  
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return  const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NotificationApp(),
    );
  }
}
class NotificationApp extends StatefulWidget {
  const NotificationApp({ Key? key }) : super(key: key);
 
  @override
  _NotificationAppState createState() => _NotificationAppState();
}
 
class _NotificationAppState extends State<NotificationApp> {
 
  //объект уведомления
  late FlutterLocalNotificationsPlugin localNotifications;
 
 
  //инициализация
  @override
  void initState() {
    super.initState();
    //объект для Android настроек
    const androidInitialize =  AndroidInitializationSettings('ic_launcher');
    //объект для IOS настроек
    const IOSInitialize = IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,);
    // общая инициализация
    const initializationSettings = InitializationSettings(
        android: androidInitialize, iOS: IOSInitialize);
 
    // создаем локальное уведомление
    localNotifications = FlutterLocalNotificationsPlugin();
    localNotifications.initialize(initializationSettings); 
  }
 

//One-time уведомление:

  Future _showNotification() async {
    const androidDetails = AndroidNotificationDetails(
      "ID",
      "Название уведомления",
      importance: Importance.high,
      channelDescription: "Контент уведомления",
      playSound: true,
      timeoutAfter: 5000,
      styleInformation: DefaultStyleInformation(true, true),
    );
 
    const iosDetails =  IOSNotificationDetails();
    const generalNotificationDetails =
        NotificationDetails(android: androidDetails, iOS: iosDetails);
    await localNotifications.show(
        0, 'Простое напоминание', 'Попробуй сегодня что-то новое!', generalNotificationDetails,);
   
  }


//Periodical уведомление (everyMinute, daily, weekly..)

  Future<void> _showNotificationDaily() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'daily channel ID',
        'daily channel name',
        channelDescription: 'daily description'
      );
    const IOSNotificationDetails iosDetails =
      IOSNotificationDetails();
    const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iosDetails);
    await localNotifications.periodicallyShow(
        1,
        'Ежедневное напоминание',
        'Выделить полчаса на занятия программированием',
        RepeatInterval.daily,
        platformChannelSpecifics,
        androidAllowWhileIdle: true);
  }

//Scheduled уведомление 
  Future<void> _showNotificationDailyTimed() async {
    tz.initializeTimeZones();
    await localNotifications.zonedSchedule(
        2,
        'Уведомление с отложенным стартом',
        'Это сообщение было отправлено 10 сек назад',
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10)),
        const NotificationDetails(
            android: AndroidNotificationDetails(
                'channel id', 'channel name',
                channelDescription: 'channel description',
                importance: Importance.max,
                priority: Priority.high,
                )),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

//Отмена всех уведомлений
  Future<void> _cancelAllNotifications() async {
    await localNotifications.cancelAll();  // localNotifications.cancel(0) --> cancel by id
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notification"), centerTitle: true,),
      body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                      onPressed:_showNotification,
                      child: const Text('One-time Notification'),
                    ),
              const SizedBox(height: 20),
              ElevatedButton(
                      onPressed:_showNotificationDaily,
                      child: const Text('Daily Notification'),
                    ),
              const SizedBox(height: 20),
              ElevatedButton(
                      onPressed:_showNotificationDailyTimed,
                      child: const Text('Notification in 10 sec'),
                    ),
              const SizedBox(height: 20),
              ElevatedButton(
                      onPressed:_cancelAllNotifications,
                      child: const Text('Cancel all Notifications'),
                    ),
              const SizedBox(height: 20),     
            ],)
        ),
      );
  }
}