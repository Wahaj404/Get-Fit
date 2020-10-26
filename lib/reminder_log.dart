import 'package:flutter/material.dart';
import 'database.dart';
import 'buttons.dart';

class ReminderLog extends StatefulWidget {
  @override
  _ReminderLogState createState() => _ReminderLogState();
}

class _ReminderLogState extends State<ReminderLog> {
  String nameLike = '';
  @override
  Widget build(BuildContext context) {
    var logs =
        DB.inst.getLogs(nameLike).then((value) => value.reversed.toList());
    return Scaffold(
      appBar: AppBar(
        title: Text('Reminder Log'),
      ),
      body: Center(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: logs,
          builder: (BuildContext context,
              AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
            return ListView(
              children: snapshot.hasData
                  ? <Widget>[
                        TextField(
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            border: InputBorder.none,
                            hintText: 'Search',
                          ),
                          onChanged: (value) {
                            setState(() {
                              nameLike = value;
                            });
                          },
                        ),
                      ] +
                      spaceOut(
                        snapshot.data
                            .map(
                              (log) => Ink(
                                child: ListTile(
                                  leading: Text(
                                      (log['Membership_Number'] as String) +
                                          '\n' +
                                          (log['Name'] as String)),
                                  title: Text(log['Body'] as String),
                                  onLongPress: () {
                                    DB.inst.deleteLog(log);
                                    setState(() {});
                                  },
                                ),
                                color: Colors.yellow[800],
                              ) as Widget,
                            )
                            .toList(),
                      )
                  : [],
            );
          },
        ),
      ),
    );
  }
}
