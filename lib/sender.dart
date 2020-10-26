import 'variables.dart';
import 'dart:async';
import 'member.dart';
import 'package:flutter/services.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'database.dart';
import 'date.dart';

class Sender {
  static const methodChannel = const MethodChannel('SendReminders');

  static void sendOverride(Member mem) {
    sendSMS(mem);
    sendEmail(mem);
  }

  static void sendChecked(Member mem) {
    if (mem.shouldSend() && _isValidTime()) {
      sendSMS(mem);
      sendEmail(mem);
    }
  }

  static bool _isValidTime() {
    var hour = DateTime.now().hour;
    return hour > 8 && hour < 21;
  }

  static Future<Null> sendSMS(Member mem) async {
    print("Send SMS called.");
    try {
      final result = await methodChannel.invokeMethod('SMS',
          {"phone": mem.phone, "msg": Variables.parse(Variables.message, mem)});
      print(result);
      DB.inst.insertLog(
        mem,
        'SMS sent at ${DateTime.now().toString().substring(0, 19)}',
      );
      mem.lastSMS = Date.now();
      DB.inst.update(mem);
    } on PlatformException catch (e) {
      print(e.toString());
      DB.inst.insertLog(
        mem,
        'SMS not sent at ${DateTime.now().toString().substring(0, 19)}',
      );
    }
  }

  static Future<Null> sendThanks(Member mem) async {
    print("sendThanks called.");
    try {
      final result = await methodChannel.invokeMethod('SMS',
          {"phone": mem.phone, "msg": Variables.parse(Variables.thanks, mem)});
      print(result);
      DB.inst.insertLog(
        mem,
        'Thank you SMS sent at ${DateTime.now().toString().substring(0, 19)}',
      );
    } on PlatformException catch (e) {
      print(e.toString());
      DB.inst.insertLog(
        mem,
        'Thank you SMS not sent at ${DateTime.now().toString().substring(0, 19)}',
      );
    }
  }

  static Future<Null> sendEmail(Member mem) async {
    if (mem.email == '') {
      return;
    }
    final username = 'get.fit.health.club.official@gmail.com';
    final smtpServer = gmail(username, 'p@33word');
    final message = Message()
      ..from = Address(username, 'Get Fit')
      ..recipients.add(mem.email)
      ..subject = 'Get Fit Fees Reminder'
      ..text = Variables.parse(Variables.email, mem);
    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
      DB.inst.insertLog(
          mem, 'Email sent at ${DateTime.now().toString().substring(0, 19)}');
      mem.lastEmail = Date.now();
      DB.inst.update(mem);
      return;
    } on MailerException catch (e) {
      print('Message not sent.');
      DB.inst.insertLog(mem,
          'Failed to send email at ${DateTime.now().toString().substring(0, 19)}');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    } finally {
      DB.inst.insertLog(
        mem,
        'Email not sent at ${DateTime.now().toString().substring(0, 19)}',
      );
    }
  }

  static void sendAll() async {
    print('sendAll');
    for (var mem in await DB.inst.selectAll()) {
      sendChecked(mem);
    }
  }
}
