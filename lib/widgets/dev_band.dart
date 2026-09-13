import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A single continuously scrolling DEV marquee band, rotated at [angleDegrees].
/// [scrollLeft] = true means it scrolls left, false = scrolls right.
class DevBand extends StatefulWidget {
  final double topFraction;   // 0.0–1.0 of screen height
  final double leftFraction;  // 0.0–1.0+ of screen width (cross-anchor)
  final double angleDegrees;  // positive = /, negative = \
  final bool scrollLeft;
  final Duration duration;

  const DevBand({
    super.key,
    required this.topFraction,
    required this.leftFraction,
    required this.angleDegrees,
    required this.scrollLeft,
    required this.duration,
  });

  @override
  State<DevBand> createState() => _DevBandState();
}

class _DevBandState extends State<DevBand> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fontSize = (size.width * 0.042).clamp(26.0, 54.0);
    final letterSpacing = (size.width * 0.01).clamp(6.0, 14.0);
    const bandWidth = 5000.0; // wide enough to wrap screen when rotated

    // Text content — generated to be very long for continuous scrolling
    final text = 'DEV  ' * 100;
    final textStyle = GoogleFonts.outfit(
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      letterSpacing: letterSpacing,
      color: Colors.white,
      height: 0.95,
    );

    return Positioned(
      top: size.height * widget.topFraction,
      left: size.width * widget.leftFraction,
      child: IgnorePointer(
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.translationValues(-bandWidth / 2, -fontSize / 2, 0)
            ..rotateZ(widget.angleDegrees * pi / 180),
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) {
              final t = widget.scrollLeft ? _ctrl.value : (1 - _ctrl.value);
              return ClipRect(
                child: SizedBox(
                  width: bandWidth,
                  child: Transform.translate(
                    offset: Offset(-bandWidth / 2 * t, 0),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        border: Border.symmetric(
                          horizontal: BorderSide(
                            color: Color(0xFFE91E1E),
                            width: 2,
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const NeverScrollableScrollPhysics(),
                        child: Text(
                          text,
                          style: textStyle,
                          maxLines: 1,
                          softWrap: false,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
