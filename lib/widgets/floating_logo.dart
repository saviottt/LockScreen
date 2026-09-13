import 'dart:math';
import 'package:flutter/material.dart';

/// A single floating tech logo that bobs with multi-harmonic animation
/// mimicking the website's JS sine/cosine floating effect.
class FloatingLogo extends StatefulWidget {
  final String assetPath;
  final String label;
  final double baseX;    // px from center of stage
  final double baseY;    // px from top-38% of stage
  final double speedY;
  final double speedX;
  final double phase;

  const FloatingLogo({
    super.key,
    required this.assetPath,
    required this.label,
    required this.baseX,
    required this.baseY,
    required this.speedY,
    required this.speedX,
    required this.phase,
  });

  @override
  State<FloatingLogo> createState() => _FloatingLogoState();
}

class _FloatingLogoState extends State<FloatingLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    // 8-second loop matches JS time scale (performance.now * 0.0012 ~8s cycle)
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width <= 768;
    final logoSize = isMobile ? 68.0 : 96.0;
    final floatAmp = isMobile ? 8.0 : 14.0;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) {
        final t = _ctrl.value * 2 * pi * 1.0; // full cycle
        final offsetY = sin(t * widget.speedY + widget.phase) * floatAmp +
            cos(t * 0.7 + widget.phase * 1.5) * (floatAmp * 0.35);
        final offsetX =
            cos(t * widget.speedX + widget.phase * 1.2) * (floatAmp * 0.45);
        final rot = sin(t * 1.1 + widget.phase) * 3.5 * pi / 180;

        return Transform.translate(
          offset: Offset(widget.baseX + offsetX, widget.baseY + offsetY),
          child: Transform.rotate(
            angle: rot,
            child: child,
          ),
        );
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedScale(
          scale: _hovered ? 1.15 : 1.0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                widget.assetPath,
                width: logoSize,
                height: logoSize,
                fit: BoxFit.contain,
              ),
              if (_hovered)
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3), width: 1),
                  ),
                  child: Text(
                    widget.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
