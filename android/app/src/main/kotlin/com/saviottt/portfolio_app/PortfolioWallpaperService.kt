package com.saviottt.portfolio_app

import android.service.wallpaper.WallpaperService
import android.util.Log
import android.view.SurfaceHolder
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.embedding.engine.loader.FlutterLoader
import io.flutter.embedding.engine.renderer.FlutterRenderer
import io.flutter.plugins.GeneratedPluginRegistrant

class PortfolioWallpaperService : WallpaperService() {

    companion object {
        private const val TAG = "PortfolioWallpaper"
    }

    override fun onCreateEngine(): Engine {
        return LiveWallpaperEngine()
    }

    inner class LiveWallpaperEngine : Engine() {
        private var flutterEngine: FlutterEngine? = null
        private var flutterLoader: FlutterLoader? = null
        private var isRendering = false

        override fun onCreate(surfaceHolder: SurfaceHolder?) {
            super.onCreate(surfaceHolder)
            Log.e(TAG, ">>> onCreate, isPreview=$isPreview")
            try {
                val loader = FlutterInjector.instance().flutterLoader()
                if (!loader.initialized()) {
                    loader.startInitialization(applicationContext)
                    loader.ensureInitializationComplete(applicationContext, null)
                }
                flutterLoader = loader

                flutterEngine = FlutterEngine(applicationContext).also { engine ->
                    try {
                        GeneratedPluginRegistrant.registerWith(engine)
                    } catch (e: Exception) {
                        Log.e(TAG, "Plugin registration: ${e.message}")
                    }

                    engine.navigationChannel.setInitialRoute("/wallpaper")
                    engine.dartExecutor.executeDartEntrypoint(
                        DartExecutor.DartEntrypoint.createDefault()
                    )
                    engine.lifecycleChannel.appIsResumed()
                    Log.e(TAG, ">>> FlutterEngine created and started")
                }
            } catch (e: Exception) {
                Log.e(TAG, "!!! Failed to create FlutterEngine: ${e.message}", e)
            }
        }

        override fun onSurfaceCreated(holder: SurfaceHolder) {
            super.onSurfaceCreated(holder)
            Log.e(TAG, ">>> onSurfaceCreated, valid=${holder.surface.isValid}")
            try {
                flutterEngine?.renderer?.startRenderingToSurface(holder.surface, false)
                isRendering = true

                val rect = holder.surfaceFrame
                if (rect.width() > 0 && rect.height() > 0) {
                    flutterEngine?.renderer?.surfaceChanged(rect.width(), rect.height())
                    val density = applicationContext.resources.displayMetrics.density
                    val metrics = FlutterRenderer.ViewportMetrics().apply {
                        this.width = rect.width()
                        this.height = rect.height()
                        this.devicePixelRatio = density
                    }
                    flutterEngine?.renderer?.setViewportMetrics(metrics)
                }
                flutterEngine?.lifecycleChannel?.appIsResumed()
                Log.e(TAG, ">>> Rendering started on surface")
            } catch (e: Exception) {
                Log.e(TAG, "!!! Failed to start rendering: ${e.message}", e)
            }
        }

        override fun onSurfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) {
            super.onSurfaceChanged(holder, format, width, height)
            Log.e(TAG, ">>> onSurfaceChanged: ${width}x${height}, format=$format")
            try {
                if (!isRendering) {
                    flutterEngine?.renderer?.startRenderingToSurface(holder.surface, false)
                    isRendering = true
                }
                // CRITICAL: Notify Flutter native C++ engine of the surface dimension change!
                flutterEngine?.renderer?.surfaceChanged(width, height)

                val density = applicationContext.resources.displayMetrics.density
                val metrics = FlutterRenderer.ViewportMetrics().apply {
                    this.width = width
                    this.height = height
                    this.devicePixelRatio = density
                }
                flutterEngine?.renderer?.setViewportMetrics(metrics)
                flutterEngine?.lifecycleChannel?.appIsResumed()
                Log.e(TAG, ">>> Viewport and surfaceChanged updated to ${width}x${height}")
            } catch (e: Exception) {
                Log.e(TAG, "!!! Failed to update viewport metrics: ${e.message}", e)
            }
        }

        override fun onSurfaceDestroyed(holder: SurfaceHolder) {
            Log.e(TAG, ">>> onSurfaceDestroyed")
            try {
                if (isRendering) {
                    flutterEngine?.renderer?.stopRenderingToSurface()
                    isRendering = false
                }
            } catch (e: Exception) {
                Log.e(TAG, "!!! Error stopping rendering: ${e.message}", e)
            }
            super.onSurfaceDestroyed(holder)
        }

        override fun onDestroy() {
            Log.e(TAG, ">>> onDestroy")
            try {
                flutterEngine?.destroy()
            } catch (e: Exception) {
                Log.e(TAG, "!!! Error destroying engine: ${e.message}", e)
            }
            flutterEngine = null
            super.onDestroy()
        }

        override fun onVisibilityChanged(visible: Boolean) {
            super.onVisibilityChanged(visible)
            Log.e(TAG, ">>> onVisibilityChanged: $visible")
            if (visible) {
                flutterEngine?.lifecycleChannel?.appIsResumed()
            } else {
                flutterEngine?.lifecycleChannel?.appIsInactive()
            }
        }
    }
}
