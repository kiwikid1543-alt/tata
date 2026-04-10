// lib/core/services/location_service.dart

import 'package:geolocator/geolocator.dart';

class LocationService {
  /// 현재 권한 상태 확인
  static Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// 권한 요청 루틴
  static Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// 현재 위치를 가져옴 (호출 전 권한이 확보되어 있어야 함)
  static Future<Position?> getCurrentPosition() async {
    bool serviceEnabled;

    // 1. 위치 서비스 활성화 여부 확인
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    // 2. 현재 위치 반환
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      // 위치 획득 실패 시 로그 출력 및 null 반환
      print('Location error: $e');
      return null;
    }
  }
}
