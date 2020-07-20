import 'package:flutter/material.dart';
import 'member.dart';

Widget memberToButton(void Function() onPress, Member mem) {
  return SizedBox(
    height: 75,
    child: Ink(
      child: ListTile(
        onTap: onPress,
        leading: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              mem.name,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        trailing: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 5,
            ),
            Text(
              mem.id,
              style: TextStyle(fontSize: 16),
            ),
            Text(
              mem.dueDate.toString(),
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
      color: Colors.yellow[800],
    ),
  );
}

List<Widget> spaceOut(List<Widget> widgets) {
  for (int i = 1; i < widgets.length; i += 2) {
    widgets.insert(i, SizedBox(height: 10));
  }
  return widgets;
}
