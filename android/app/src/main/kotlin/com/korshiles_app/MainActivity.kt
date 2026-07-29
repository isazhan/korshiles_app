package com.korshiles_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Регистрация фабрики
        val factory = ListTileNativeAdFactory(context)
        GoogleMobileAdsPlugin.registerNativeAdFactory(flutterEngine, "listTile", factory)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        // Удаление фабрики при завершении работы
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "listTile")
        super.cleanUpFlutterEngine(flutterEngine)
    }
}