import 'package:flutter/material.dart';
import 'services/wallpaper_service.dart';
import 'widgets/dev_band.dart';
import 'widgets/live_clock.dart';
import 'widgets/portrait_stage.dart';

class HomeScreen extends StatefulWidget {
  final bool isWallpaper;
  const HomeScreen({super.key, this.isWallpaper = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey _repaintKey = GlobalKey();
  bool _isSettingWallpaper = false;

  Future<void> _showWallpaperOptions() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Set Lock Screen Wallpaper',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose how you want to apply the wallpaper to your device:',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE91E1E).withAlpha(40),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_circle_fill_rounded, color: Color(0xFFE91E1E)),
              ),
              title: const Text(
                'Live Animated Wallpaper',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Continuous moving animations on lock & home screen',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _applyLiveWallpaper();
              },
            ),
            const Divider(color: Colors.white12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.photo_camera_rounded, color: Colors.white),
              ),
              title: const Text(
                'Static Snapshot Wallpaper',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Still image snapshot of current app screen',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _applyStaticWallpaper();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _applyLiveWallpaper() async {
    setState(() => _isSettingWallpaper = true);
    final success = await WallpaperService.openLiveWallpaperPicker();
    if (!mounted) return;
    setState(() => _isSettingWallpaper = false);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to launch Live Wallpaper picker.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _applyStaticWallpaper() async {
    setState(() => _isSettingWallpaper = true);
    final success = await WallpaperService.setLockScreenFromBoundary(_repaintKey);
    if (!mounted) return;
    setState(() => _isSettingWallpaper = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Lock screen static wallpaper set!'
              : 'Failed to set static wallpaper.',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: success ? Colors.black87 : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // Repaint boundary wraps the background elements & portrait stage with a solid white background
            Positioned.fill(
              child: RepaintBoundary(
                key: _repaintKey,
                child: Container(
                  color: Colors.white,
                  child: Stack(
                    clipBehavior: Clip.hardEdge,
                    children: [
                    // ── Layer 1: Background DEV crossing bands ──────────────────
                    const DevBand(
                      topFraction: 0.40,
                      leftFraction: 1.20,
                      angleDegrees: -13,
                      scrollLeft: true,
                      duration: Duration(seconds: 38),
                    ),
                    const DevBand(
                      topFraction: 0.60,
                      leftFraction: 1.20,
                      angleDegrees: 13,
                      scrollLeft: false,
                      duration: Duration(seconds: 34),
                    ),

                    // ── Layer 2: Portrait image + floating logos ─────────────────
                    const Positioned.fill(
                      child: PortraitStage(),
                    ),

                    // ── Layer 3: Live clock — top-center ─────────────────────────
                    Positioned(
                      top: size.height * 0.08,
                      left: 0,
                      right: 0,
                      child: const Center(
                        child: LiveClock(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

            // ── Layer 4: Wallpaper trigger button — bottom-right ───────────
            if (!widget.isWallpaper)
              Positioned(
                bottom: 24,
                right: 24,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isSettingWallpaper ? null : _showWallpaperOptions,
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: const Color(0xFFE91E1E), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(80),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isSettingWallpaper)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        else
                          const Icon(
                            Icons.wallpaper_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        const SizedBox(width: 8),
                        Text(
                          _isSettingWallpaper ? 'Setting...' : 'Set Lock Screen',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
