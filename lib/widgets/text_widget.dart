import 'package:flutter/material.dart';

Widget textWidget(String placeholder) {
  return TextField(
      decoration: InputDecoration(
          border: const OutlineInputBorder(), labelText: placeholder));
}
