import 'package:flutter/material.dart';
// import 'package:get_fit/database.dart';
import 'date.dart';

class Member {
  static final columns = [
    'Membership_Number',
    'Name',
    'Phone_Number',
    'Email',
    'Join_Date',
    'Due_Date',
    'Fees',
    'Fees_Paid',
    'Last_Email',
    'Last_SMS',
  ];
  static final displayNames = [
    'Membership No',
    'Name',
    'Phone Number',
    'Email',
    'Join Date',
    'Due Date',
    'Fees',
  ];
  static final Map<String, String Function(String)> validators = {
    displayNames[0]: (value) {
      // if (DB.inst.select(value) != null) {
      //   return 'This membership number is already in the database.';
      // }
      if (!(value.length == 12 &&
          (value[0] == 'G') &&
          (value[1] == 'M' || value[1] == 'F') &&
          (value[2] == '-') &&
          (int.tryParse(value.substring(3, 7)) != null) &&
          value[7] == '/' &&
          (int.tryParse(value.substring(8)) != null))) {
        return 'Membership number is in an invalid format.';
      }
      return null;
    },
    displayNames[1]: (value) => value.isEmpty ? 'Name must be filled.' : null,
    displayNames[2]: (value) {
      if (value.length != 11) {
        return 'Phone number must have exactly 11 digits.';
      }
      if (int.tryParse(value) == null) {
        return 'Phone number must contain digits only';
      }
      return null;
    },
    displayNames[3]: (value) => null,
    displayNames[4]: (value) => value.isEmpty ? 'Date must be filled.' : null,
    displayNames[5]: (value) => value.isEmpty ? 'Date must be filled.' : null,
    displayNames[6]: (value) {
      if (value.isEmpty) {
        return 'Fees must be filled.';
      }
      if (int.tryParse(value) == null) {
        return 'Fees must contain digits only';
      }
      return null;
    },
  };
  static final inputTypes = {
    displayNames[0]: TextInputType.text,
    displayNames[1]: TextInputType.text,
    displayNames[2]: TextInputType.phone,
    displayNames[3]: TextInputType.emailAddress,
    displayNames[4]: TextInputType.number,
    displayNames[5]: TextInputType.number,
    displayNames[6]: TextInputType.number,
  };
  static String getDefault(String displayName) {
    Map<String, String> map = {
      'Membership No': 'GM-/' + DateTime.now().year.toString(),
      'Name': '',
      'Phone Number': '03',
      'Email': '',
      'Join Date': Date.now().toString(),
      'Due Date': (Date.now()..nextMonth()).toString(),
      'Fees': '6000'
    };
    return map[displayName];
  }

  String id;
  String name;
  String phone;
  String email;
  Date joinDate;
  Date dueDate;
  int fees;
  bool paid;
  Date lastEmail;
  Date lastSMS;

  Member(this.id, this.name, this.phone, this.email, this.joinDate,
      this.dueDate, this.fees, this.paid)
      : lastEmail = Date(21, 7, 2020),
        lastSMS = Date(21, 7, 2020);
  Member.fromMap(Map<String, dynamic> map)
      : id = map[columns[0]],
        name = map[columns[1]],
        phone = map[columns[2]],
        email = map[columns[3]],
        joinDate = Date.fromString(map[columns[4]]),
        dueDate = Date.fromString(map[columns[5]]),
        fees = map[columns[6]],
        paid = map[columns[7]] == 1,
        lastEmail = Date.fromString(map[columns[8]]),
        lastSMS = Date.fromString(map[columns[9]]);
  Map<String, dynamic> toMap() {
    return {
      columns[0]: id,
      columns[1]: name,
      columns[2]: phone,
      columns[3]: email,
      columns[4]: joinDate.toString(),
      columns[5]: dueDate.toString(),
      columns[6]: fees,
      columns[7]: paid ? 1 : 0,
      columns[8]: lastEmail.toString(),
      columns[9]: lastSMS.toString(),
    };
  }

  String getString(String displayName) {
    Map<String, String> map = {
      'Membership No': id,
      'Name': name,
      'Phone Number': phone,
      'Email': email,
      'Join Date': joinDate.toString(),
      'Due Date': dueDate.toString(),
      'Fees': fees.toString()
    };
    return map[displayName];
  }

  bool shouldSend() {
    if (lastSMS.isSame(Date.now())) {
      return false;
    }
    final diff = Date.difference(dueDate, Date.now());
    return (diff == 2 || diff == 0 || diff == 4) && !paid;
  }
}
