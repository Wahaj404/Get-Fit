import 'database.dart';
import 'member.dart';

class Variables {
  static String _sortBy;
  static String _message;
  static String _email;

  static String get sortBy => _sortBy;
  static set sortBy(String value) {
    _sortBy = value;
    DB.inst.updateVariable('Sort_By', value);
  }

  static String get message => _message;
  static set message(String value) {
    _message = value;
    DB.inst.updateVariable('Message', value);
  }

  static String get email => _email;
  static set email(String value) {
    _email = value;
    DB.inst.updateVariable('Email', value);
  }

  static void init() async {
    print('Variables.init()');
    _message = await DB.inst.selectVariable('Message');
    _email = await DB.inst.selectVariable('Email');
    _sortBy = await DB.inst.selectVariable('Sort_By');
  }

  static String parse(String template, Member mem) {
    return template
        .replaceFirst('\$f', mem.fees.toString())
        .replaceFirst('\$n', mem.name)
        .replaceFirst('\$d', mem.dueDate.toString());
  }
}
