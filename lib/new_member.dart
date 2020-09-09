import 'package:flutter/material.dart';
import 'database.dart';
import 'member.dart';
import 'date.dart';

class NewMemberPage extends StatefulWidget {
  NewMemberPage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _NewMemberPageState createState() => _NewMemberPageState();
}

class _NewMemberPageState extends State<NewMemberPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            NewMemberForm(),
          ],
        ),
      ),
    );
  }
}

class NewMemberForm extends StatefulWidget {
  @override
  _NewMemberFormState createState() => _NewMemberFormState();
}

class _NewMemberFormState extends State<NewMemberForm> {
  final _formKey = GlobalKey<FormState>();
  var controllers = <TextEditingController>[];
  @override
  Widget build(BuildContext context) {
    var forms = <Widget>[];
    for (var disp in Member.displayNames) {
      controllers.add(TextEditingController(text: Member.getDefault(disp)));
      forms.add(
        TextFormField(
          decoration: InputDecoration(
            labelText: disp,
          ),
          controller: controllers.last,
          validator: Member.validators[disp],
          keyboardType: Member.inputTypes[disp],
        ),
      );
    }
    return Form(
      key: _formKey,
      child: Column(
        children: forms +
            [
              RaisedButton(
                child: Text('Register'),
                onPressed: () {
                  for (var con in controllers) {
                    con.text = con.text.trim();
                  }
                  if (_formKey.currentState.validate()) {
                    DB.inst.insert(
                      Member(
                        controllers[0].text,
                        controllers[1].text,
                        controllers[2].text,
                        controllers[3].text,
                        Date.fromString(controllers[4].text),
                        Date.fromString(controllers[5].text),
                        int.parse(controllers[6].text),
                        false,
                      ),
                      (Object ex) {
                        showDialog<void>(
                          context: context,
                          barrierDismissible: true,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Title'),
                              content: SingleChildScrollView(
                                child: Text('Membership number not unique.'),
                              ),
                              actions: <Widget>[
                                RaisedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                  child: Text('Ok'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                    for (int i = 0; i < controllers.length; ++i) {
                      controllers[i].text =
                          Member.getDefault(Member.displayNames[i]);
                    }
                  }
                },
              ),
            ],
      ),
    );
  }
}
