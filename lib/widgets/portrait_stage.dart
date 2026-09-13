import 'package:flutter/material.dart';
import 'floating_logo.dart';

/// Portrait image centered/bottom-anchored with the 5 floating tech logos.
class PortraitStage extends StatelessWidget {
  const PortraitStage({super.key});

  static const _logos = [
    // { path, label, xr, yr, speedY, speedX, phase }
    (
      path: 'assets/logos/flutter.png',
      label: 'Flutter',
      xr: -0.76, yr: -0.56, speedY: 1.4, speedX: 0.9, phase: 0.0
    ),
    (
      path: 'assets/logos/git.png',
      label: 'Git',
      xr: -0.92, yr: 0.16, speedY: 1.1, speedX: 1.3, phase: 1.8
    ),
    (
      path: 'assets/logos/javascript.png',
      label: 'JavaScript',
      xr: 0.76, yr: -0.56, speedY: 1.5, speedX: 1.0, phase: 3.2
    ),
    (
      path: 'assets/logos/mysql.png',
      label: 'MySQL',
      xr: 0.94, yr: 0.04, speedY: 1.2, speedX: 1.2, phase: 4.6
    ),
    (
      path: 'assets/logos/vscode.png',
      label: 'VS Code',
      xr: 0.78, yr: 0.60, speedY: 1.3, speedX: 0.8, phase: 5.9
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width <= 768;

    // Radii for logo orbit positions (from JS getFloatingRadii)
    final double rx, ry;
    if (size.width <= 480) {
      rx = 155; ry = 205;
    } else if (size.width <= 768) {
      rx = 200; ry = 250;
    } else if (size.width <= 1200) {
      rx = 375; ry = 260;
    } else {
      rx = 505; ry = 335;
    }

    // Portrait image height (mirrors CSS clamp values)
    final double imgHeight = isMobile
        ? (size.height * 0.82).clamp(0.0, 640.0)
        : size.height * 1.18;

    // Anchor point for logos = 38% from top of the stage (= bottom-anchored)
    // Stage fills whole screen height, portrait bottom-aligned
    final anchorY = size.height * 0.38 - imgHeight + size.height;

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // Portrait
        Positioned(
          bottom: 0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(isMobile ? 20 : 38),
            child: Image.asset(
              'assets/image.png',
              height: imgHeight,
              width: null,
              fit: BoxFit.cover,
            ),
          ),
        ),

        // Floating logos — placed relative to center of screen
        for (final logo in _logos)
          Positioned(
            left: size.width / 2 + logo.xr * rx - (isMobile ? 34 : 48),
            top: anchorY + logo.yr * ry - (isMobile ? 34 : 48),
            child: FloatingLogo(
              assetPath: logo.path,
              label: logo.label,
              baseX: 0,
              baseY: 0,
              speedY: logo.speedY,
              speedX: logo.speedX,
              phase: logo.phase,
            ),
          ),
      ],
    );
  }
}
