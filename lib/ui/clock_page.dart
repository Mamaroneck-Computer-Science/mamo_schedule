import 'dart:async';

import 'package:flutter/material.dart';
import 'package:clock/clock.dart';

class ClockPage extends StatefulWidget {
  @override
  _ClockPageState createState() => _ClockPageState();
}

class _ClockPageState extends State<ClockPage> {
  late Timer _timer;
  late String now;

  @override
  void initState() {
    super.initState();
    now = _getTimeStr();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
        now = _getTimeStr();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _getTimeStr() {
    DateTime d = clock.now();
    String out = "";
    out += (d.hour % 12).toString();
    out += ":";
    out += d.minute.toString();
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        now,
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }
}
