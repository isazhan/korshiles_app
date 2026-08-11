import 'dart:io';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

class AppTrackingService {
  /// Запрашивает разрешение на трекинг и возвращает итоговый статус.
  static Future<TrackingStatus> requestTrackingPermission() async {
    // На платформах, отличных от iOS, трекинг ATT не требуется
    if (!Platform.isIOS) {
      return TrackingStatus.notSupported;
    }

    final status = await AppTrackingTransparency.trackingAuthorizationStatus;

    if (status == TrackingStatus.notDetermined) {
      // Запрашиваем системное разрешение
      return await AppTrackingTransparency.requestTrackingAuthorization();
    }

    return status;
  }

  /// Возвращает рекламный идентификатор (IDFA), если статус authorized
  static Future<String?> getAdvertisingIdentifier() async {
    if (!Platform.isIOS) return null;

    final status = await AppTrackingTransparency.trackingAuthorizationStatus;
    if (status == TrackingStatus.authorized) {
      return await AppTrackingTransparency.getAdvertisingIdentifier();
    }
    
    return null;
  }
}