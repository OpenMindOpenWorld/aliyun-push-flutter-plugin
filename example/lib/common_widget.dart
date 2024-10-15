import 'package:flutter/material.dart';

Widget cardBuilder(Widget child) {
  return Card(
    elevation: 0,
    color: Colors.grey.shade200,
    child: Padding(
      padding: const EdgeInsets.all(15),
      child: child,
    ),
  );
}

Widget titleBuilder(String title) {
  return Material(
    color: Colors.transparent,
    clipBehavior: Clip.hardEdge,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
    child: ListTile(
      visualDensity: VisualDensity.comfortable,
      title: Text(title),
      textColor: Colors.white,
      tileColor: Colors.black45,
    ),
  );
}
