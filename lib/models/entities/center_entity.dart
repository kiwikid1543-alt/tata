// lib/models/entities/center_entity.dart

import '../dto/center_dto.dart';
import 'dart:math' as math;

class CenterEntity {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String address;
  final String phone;
  final String region;
  final double? distanceInKm; // 사용자 위치로부터의 계산된 거리

  const CenterEntity({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.phone,
    required this.region,
    this.distanceInKm,
  });

  CenterEntity copyWith({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    String? address,
    String? phone,
    String? region,
    double? distanceInKm,
  }) {
    return CenterEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      region: region ?? this.region,
      distanceInKm: distanceInKm ?? this.distanceInKm,
    );
  }

  /// DTO에서 엔티티로 변환
  factory CenterEntity.fromDto(CenterDto dto) {
    return CenterEntity(
      id: dto.cntrId ?? '',
      name: dto.cntrNm ?? '이름 없음',
      latitude: double.tryParse(dto.lat ?? '0.0') ?? 0.0,
      longitude: double.tryParse(dto.lot ?? '0.0') ?? 0.0,
      address: dto.cntrRoadNmAddr ?? '주소 정보 없음',
      phone: dto.cntrTelno ?? '',
      region: dto.lclgvNm ?? '',
    );
  }

  /// 사용자 위치와의 거리(km)를 보관한 새로운 엔티티 반환
  CenterEntity withDistance(double userLat, double userLon) {
    final distance = _calculateDistance(userLat, userLon, latitude, longitude);
    return copyWith(distanceInKm: distance);
  }

  /// 하버사인 공식을 이용한 두 좌표 간 직선 거리 계산 (km 반환)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // 지구 반지름 (km)
    
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) * math.cos(_toRadians(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * (math.pi / 180);
  }
}
