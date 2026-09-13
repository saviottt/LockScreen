import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Live clock showing 12-hr civilian time.
/// Hours in red, minutes in black, date below.
class LiveClock extends StatefulWidget {
  const LiveClock({super.key});

  @override
  State<LiveClock> createState() => _LiveClockState();
}

class _LiveClockState extends State<LiveClock> {
  late Timer _timer;
  late DateTime _now;

  static const _days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _hours {
    final h = _now.hour % 12 == 0 ? 12 : _now.hour % 12;
    return h.toString().padLeft(2, '0');
  }

  String get _minutes => _now.minute.toString().padLeft(2, '0');
  String get _dayName => _days[_now.weekday % 7];
  String get _dateNum => _now.day.toString();
  String get _monthName => _months[_now.month - 1];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final digitSize = (size.height * 0.17).clamp(60.0, 180.0);
    final dateSize = (size.height * 0.02).clamp(7.5, 21.0);
    final dateMt = (size.height * 0.024).clamp(10.0, 30.0);

    final digitStyle = GoogleFonts.outfit(
      fontSize: digitSize,
      fontWeight: FontWeight.w900,
      letterSpacing: 0,
      height: 0.82,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Hours — red
        Text(
          _hours,
          style: digitStyle.copyWith(color: const Color(0xFFE91E1E)),
        ),
        // Minutes — black
        Text(
          _minutes,
          style: digitStyle.copyWith(color: Colors.black),
        ),
      ],
    );
  }
}
