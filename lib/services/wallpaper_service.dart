import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class WallpaperService {
  static const MethodChannel _channel =
      MethodChannel('com.saviottt.portfolio_app/wallpaper');

  /// Opens the system Live Wallpaper chooser for continuous animated lock screen wallpaper.
  static Future<bool> openLiveWallpaperPicker() async {
    try {
      final bool? success =
          await _channel.invokeMethod<bool>('openLiveWallpaperPicker');
      return success ?? false;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Failed to open live wallpaper picker: ${e.message}');
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error opening live wallpaper picker: $e');
      }
      return false;
    }
  }

  /// Captures the widget referenced by [repaintKey] and sets it as the lock screen wallpaper.
  static Future<bool> setLockScreenFromBoundary(GlobalKey repaintKey) async {
    try {
      final boundary = repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        if (kDebugMode) print('Repaint boundary not found');
        return false;
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return false;

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      final bool? success = await _channel.invokeMethod<bool>('setLockScreenWallpaper', {
        'imageBytes': pngBytes,
      });

      return success ?? false;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Failed to set wallpaper: ${e.message}');
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error capturing screen: $e');
      }
      return false;
    }
  }
}
