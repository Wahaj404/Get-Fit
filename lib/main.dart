import 'package:flutter/material.dart';
import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'database.dart';
import 'member_list.dart';

class Background {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  static Future<Null> showNotificationWithDefaultSound() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Reminder',
      'Emails and messages have not been sent today.',
      platformChannelSpecifics,
      payload: 'Default_Sound',
    );
  }

  static void init() {
    print('init()');
    var initializationSettingsAndroid = AndroidInitializationSettings('logo');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static void execute() async {
    if (flutterLocalNotificationsPlugin == null) {
      init();
    }
    print("${DateTime.now()} Executing background tasks.");
    if (DateTime.now().hour == 0 && DateTime.now().minute < 10) {
      DB.inst.clearLog();
    }
    if (!(await DB.inst.allSent())) {
      showNotificationWithDefaultSound();
    }
  }
}

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();
  runApp(GetFit());
  await AndroidAlarmManager.periodic(
      const Duration(minutes: 1), 0, Background.execute);
}

class GetFit extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Get Fit',
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: MemberList(title: 'Get Fit'),
    );
  }
}
