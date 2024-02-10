import 'package:flutter/material.dart';

Widget textWidget(String placeholder, TextEditingController controllerInput) {
  return TextField(
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        //labelText: placeholder
      ),
      controller: controllerInput);
}
