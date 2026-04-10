// lib/notifier/location_notifier.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../core/services/location_service.dart';

part 'location_notifier.g.dart';

class LocationState {
  final double latitude;
  final double longitude;
  final String name;
  final bool isMocked;

  const LocationState({
    required this.latitude,
    required this.longitude,
    required this.name,
    this.isMocked = false,
  });

  LocationState copyWith({
    double? latitude,
    double? longitude,
    String? name,
    bool? isMocked,
  }) {
    return LocationState(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      name: name ?? this.name,
      isMocked: isMocked ?? this.isMocked,
    );
  }
}

@riverpod
class LocationNotifier extends _$LocationNotifier {
  @override
  LocationState build() {
    // 초기값: 서울시청 (에뮬레이터 초기 좌표 오류 - 8,000km 방지를 위해 기본 목킹 평면 적용)
    return const LocationState(
      latitude: 37.5665,
      longitude: 126.9780,
      name: '서울시청 (테스트)',
      isMocked: true,
    );
  }

  /// 특정 위치로 고정 (Mocking)
  void setMockLocation(String name, double lat, double lon) {
    state = LocationState(
      latitude: lat,
      longitude: lon,
      name: name,
      isMocked: true,
    );
  }

  /// 실제 GPS 위치 사용
  Future<void> useRealLocation() async {
    final position = await LocationService.getCurrentPosition();
    if (position != null) {
      state = LocationState(
        latitude: position.latitude,
        longitude: position.longitude,
        name: '내 실제 위치 (GPS)',
        isMocked: false,
      );
    }
  }
}
