import 'package:flutter/material.dart';
import 'buttons.dart';
import 'database.dart';
import 'new_member.dart';
import 'variables.dart';
import 'member.dart';
import 'date.dart';
import 'sender.dart';
import 'reminder_log.dart';

class MemberList extends StatefulWidget {
  MemberList({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MemberListState createState() => _MemberListState();
}

class _MemberListState extends State<MemberList> {
  @override
  initState() {
    super.initState();
    DB.inst.routine();
    Variables.init();
    Sender.sendAll();
  }

  static final popUpText = [
    'Sorted By',
    'Reminder Log',
    'Message Template',
    'Email Template'
  ];
  static final popUpOptions = popUpText
      .map(
        (String choice) => PopupMenuItem<String>(
          value: choice,
          child: Text(choice),
        ),
      )
      .toList();
  String nameLike = '';
  @override
  Widget build(BuildContext context) {
    Future<List<Member>> memberList =
        DB.inst.selectAll(nameLike: nameLike, orderBy: Variables.sortBy);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == popUpText[0]) {
                showDialog<void>(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) {
                    return SimpleDialog(
                      title: Text(value),
                      children: <Widget>[
                        FlatButton(
                          child: Text('ID'),
                          onPressed: () {
                            Variables.sortBy = 'Membership_Number';
                            setState(() {});
                            Navigator.of(context).pop(true);
                          },
                        ),
                        FlatButton(
                          child: Text('Name'),
                          onPressed: () {
                            Variables.sortBy = 'Name';
                            setState(() {});
                            Navigator.of(context).pop(true);
                          },
                        ),
                        FlatButton(
                          child: Text('Due Date'),
                          onPressed: () {
                            Variables.sortBy = 'Due_Date';
                            setState(() {});
                            Navigator.of(context).pop(true);
                          },
                        ),
                      ],
                    );
                  },
                );
              } else if (value == popUpText[1]) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReminderLog(),
                  ),
                );
              } else {
                bool message = value == popUpText[2];
                var controller = TextEditingController(
                    text: message ? Variables.message : Variables.email);
                showDialog<void>(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(value),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            TextField(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.teal),
                                ),
                              ),
                              controller: controller,
                              maxLines: 5,
                            )
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                        ),
                        SizedBox(width: 150.0),
                        FlatButton(
                          child: Text('Set'),
                          onPressed: () {
                            if (message) {
                              Variables.message = controller.text;
                            } else {
                              Variables.email = controller.text;
                            }
                            Navigator.of(context).pop(false);
                          },
                        ),
                      ],
                    );
                  },
                );
              }
            },
            itemBuilder: (context) => popUpOptions,
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder<List<Member>>(
          future: memberList,
          builder:
              (BuildContext context, AsyncSnapshot<List<Member>> snapshot) {
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
                              (mem) => memberToButton(
                                () async {
                                  bool update = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UpdateMemberPage(
                                        mem,
                                        title: 'Update ${mem.name}',
                                      ),
                                    ),
                                  );
                                  update ??= false;
                                  if (update) {
                                    setState(() {});
                                  }
                                },
                                mem,
                              ),
                            )
                            .toList(),
                      )
                  : [],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool update = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewMemberPage(
                title: 'New Member',
              ),
            ),
          );
          update ??= true;
          if (update) {
            setState(() {});
          }
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Colors.grey[900],
      ),
    );
  }
}

class UpdateMemberPage extends StatefulWidget {
  UpdateMemberPage(this.mem, {Key key, this.title}) : super(key: key);

  final Member mem;
  final String title;

  @override
  _UpdateMemberPageState createState() => _UpdateMemberPageState(mem);
}

class _UpdateMemberPageState extends State<UpdateMemberPage> {
  _UpdateMemberPageState(this.mem);
  Member mem;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView(
          children: <Widget>[UpdateMemberForm(mem)],
        ),
      ),
    );
  }
}

class UpdateMemberForm extends StatefulWidget {
  UpdateMemberForm(this.mem);
  final Member mem;
  @override
  _UpdateMemberFormState createState() => _UpdateMemberFormState(mem);
}

class _UpdateMemberFormState extends State<UpdateMemberForm> {
  final _formKey = GlobalKey<FormState>();
  var controllers = <TextEditingController>[];
  Member mem;
  bool checkStatus;
  _UpdateMemberFormState(this.mem) : checkStatus = mem.paid;

  @override
  Widget build(BuildContext context) {
    var forms = <Widget>[];
    for (var disp in Member.displayNames) {
      controllers.add(TextEditingController(text: mem.getString(disp)));
      forms.add(
        TextFormField(
          decoration: InputDecoration(
            labelText: disp,
          ),
          controller: controllers.last,
          validator: Member.validators[disp],
          keyboardType: Member.inputTypes[disp],
          readOnly: controllers.length == 1,
        ),
      );
    }
    return Form(
      key: _formKey,
      child: Column(
        children: forms +
            [
              CheckboxListTile(
                title: Text('Fees paid'),
                value: checkStatus,
                onChanged: (_checked) => setState(
                  () {
                    checkStatus = _checked;
                  },
                ),
              ),
              ButtonBar(
                children: <Widget>[
                  RaisedButton(
                    onPressed: () {
                      for (var con in controllers) {
                        con.text = con.text.trim();
                      }
                      if (_formKey.currentState.validate()) {
                        mem.name = controllers[1].text;
                        mem.phone = controllers[2].text;
                        mem.email = controllers[3].text;
                        mem.joinDate = Date.fromString(controllers[4].text);
                        mem.dueDate = Date.fromString(controllers[5].text);
                        mem.fees = int.parse(controllers[6].text);
                        if (mem.paid != checkStatus) {
                          mem.dueDate.nextMonth();
                        }
                        mem.paid = checkStatus;
                        DB.inst.update(mem);
                        Navigator.of(context).pop(true);
                      }
                    },
                    child: Text('Update'),
                  ),
                  RaisedButton(
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        barrierDismissible: true,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Confirm Deletion'),
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: <Widget>[
                                  Text(
                                    'Are you sure you want to delete ${mem.name}?',
                                  ),
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              FlatButton(
                                child: Text('Cancel'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              SizedBox(width: 150.0),
                              FlatButton(
                                child: Text('Delete'),
                                onPressed: () {
                                  DB.inst.delete(mem);
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop(true);
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text('Delete'),
                    color: Colors.red,
                  ),
                  RaisedButton(
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        barrierDismissible: true,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Confirm Message Sending'),
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: <Widget>[
                                  Text(
                                    'Are you sure you want to send a reminder to ${mem.name}?',
                                  ),
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              FlatButton(
                                child: Text('Cancel'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              SizedBox(width: 150.0),
                              FlatButton(
                                child: Text('Send'),
                                onPressed: () {
                                  Sender.sendOverride(mem);
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text('Send Reminder'),
                  ),
                ],
              ),
            ],
      ),
    );
  }
}
