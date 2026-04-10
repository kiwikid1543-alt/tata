// lib/models/repositories/center_repository.dart

import '../../core/utils/result.dart';
import '../entities/center_entity.dart';

abstract class CenterRepository {
  /// 전국 모든 이동지원센터 데이터를 가져옴
  Future<Result<List<CenterEntity>>> getAllCenters();

  /// 사용자의 위치를 기반으로 하위 n개의 가장 가까운 센터를 가져옴
  Future<Result<List<CenterEntity>>> getNearestCenters({
    required double latitude,
    required double longitude,
    int count = 1,
  });
}
