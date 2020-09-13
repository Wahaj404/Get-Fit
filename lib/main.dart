import 'package:flutter/material.dart';
import 'member_list.dart';

void main(List<String> args) async {
  runApp(GetFit());
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
