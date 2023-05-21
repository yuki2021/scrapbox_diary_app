import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

SpeedDial buildSpeedDial() {
  return SpeedDial(
    animatedIcon: AnimatedIcons.menu_close,
    children: [
      SpeedDialChild(
        child: const Icon(Icons.add),
        label: '入力',
        onTap: () {
          print('First button tapped');
        },
      ),
      SpeedDialChild(
        child: const Icon(Icons.brush),
        label: 'Second',
        onTap: () {
          print('Second button tapped');
        },
      ),
      SpeedDialChild(
        child: const Icon(Icons.keyboard_voice),
        label: 'Third',
        onTap: () {
          print('Third button tapped');
        },
      ),
    ],
  );
}
