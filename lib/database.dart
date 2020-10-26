import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'member.dart';
import 'date.dart';

class DB {
  static final name = 'GetFit.db';

  DB._privateCtor();
  static final inst = DB._privateCtor();

  Database _database;
  Future<Database> get database async {
    if (_database == null) {
      _database = await _initDatabase();
    }
    return _database;
  }

  Future<Database> _initDatabase() async {
    final path = join((await getExternalStorageDirectory()).path, name);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int) async {
    await db.execute('''
              CREATE TABLE Members (
                Membership_Number TEXT PRIMARY KEY NOT NULL,
                Name TEXT NOT NULL,
                Phone_Number TEXT NOT NULL,
                Email TEXT NOT NULL,
                Join_Date TEXT NOT NULL,
                Due_Date TEXT NOT NULL,
                Fees INT NOT NULL,
                Fees_Paid BOOLEAN NOT NULL CHECK(Fees_Paid = 0 OR Fees_Paid = 1),
                Last_Email TEXT NOT NULL,
                Last_SMS TEXT NOT NULL
              )
              ''');
    await db.execute('''
              CREATE TABLE Reminder_Log (
                Membership_Number TEXT NOT NULL,
                Name TEXT NOT NULL,
                Body TEXT NOT NULL
              )
              ''');
    await db.execute('''
              CREATE TABLE Variables (
                Name TEXT PRIMARY KEY NOT NULL,
                Value TEXT NOT NULL
              )
              ''');
    await db.execute('''
              INSERT INTO Variables (Name, Value) VALUES ('Sort_By', 'Name')
              ''');
    await db.execute('''
              INSERT INTO Variables (Name, Value) VALUES ('Message', '')
              ''');
    await db.execute('''
              INSERT INTO Variables (Name, Value) VALUES ('Email', '')
              ''');
    await db.execute('''
              INSERT INTO Variables (Name, Value) VALUES ('Thanks', '')
              ''');
    await db.execute('''
              INSERT INTO Variables (Name, Value) VALUES ('DBUpdate', '')
              ''');
  }

  void insertLog(Member mem, String body) async {
    (await database).insert('Reminder_Log',
        {'Membership_Number': mem.id, 'Name': mem.name, 'Body': body});
  }

  Future<List<Map<String, dynamic>>> getLogs(String nameLike) async {
    return (await (await database).query('Reminder_Log',
        where: 'Name LIKE ?', whereArgs: [nameLike + '%']));
  }

  void deleteLog(Map<String, dynamic> log) async {
    (await database).delete('Reminder_Log',
        where: 'Membership_Number = ? AND Name = ? AND Body = ?',
        whereArgs: [log['Membership_Number'], log['Name'], log['Body']]);
  }

  void clearLog() async {
    (await database).delete('Reminder_Log');
  }

  Future<String> selectVariable(String name) async {
    return (await (await database).query('Variables',
            columns: ['Value'], where: 'Name = ?', whereArgs: [name], limit: 1))
        .first['Value'];
  }

  void updateVariable(String name, String value) async {
    (await database).update('Variables', {'Value': value},
        where: 'Name = ?', whereArgs: [name]);
  }

  void routine() async {
    print('Routine');
    if (await DB.inst.selectVariable('DBUpdate') != Date.now().toString()) {
      for (var mem in await selectAll()) {
        if (mem.paid && Date.difference(mem.dueDate, Date.now()) < 3) {
          mem.paid = false;
          update(mem);
        }
      }
      updateVariable('DBUpdate', Date.now().toString());
    }
  }

  void insert(Member mem, Function onError) async {
    (await database).insert('Members', mem.toMap()).catchError(onError);
  }

  Future<List<Member>> selectAll([nameLike = '']) async {
    return (await (await database).query('Members',
            where: 'Name LIKE ? OR Name LIKE ?',
            whereArgs: [nameLike + '%', '% ' + nameLike + '%']))
        .map((e) => Member.fromMap(e))
        .toList();
  }

  Future<Member> select(String id) async {
    var ret = (await (await database)
        .query('Members', where: 'Membership_Number = ?', whereArgs: [id]));
    if (ret.isEmpty) {
      return null;
    }
    return Member.fromMap(ret[0]);
  }

  void update(Member mem) async {
    (await database).update('Members', mem.toMap(),
        where: '${Member.columns[0]} = ?', whereArgs: [mem.id]);
  }

  void delete(Member mem) async {
    (await database).delete('Members',
        where: '${Member.columns[0]} = ?', whereArgs: [mem.id]);
  }

  Future<bool> allSent() async {
    for (var mem in await selectAll()) {
      if (mem.shouldSend()) {
        return false;
      }
    }
    return true;
  }
}
