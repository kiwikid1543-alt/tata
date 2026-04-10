// lib/notifier/center_notifier.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../core/utils/result.dart';
import 'location_notifier.dart';
import '../models/entities/center_entity.dart';
import '../models/repositories/center_repository_impl.dart';

part 'center_notifier.g.dart';

@riverpod
class CenterNotifier extends _$CenterNotifier {
  @override
  AsyncValue<CenterEntity?> build() {
    return const AsyncValue.data(null);
  }

  /// 내 위치 또는 설정된 지역을 기반으로 가장 가까운 센터를 찾아 상태에 반영 (저장은 하지 않음)
  Future<void> findNearestCenter() async {
    state = const AsyncValue.loading();

    // 1. 현재 설정된 위치 정보 가져오기 (Real GPS 또는 Mocked)
    final location = ref.read(locationNotifierProvider);
    double latitude = location.latitude;
    double longitude = location.longitude;

    // 2. 가장 가까운 센터 1개 조회
    final repository = ref.read(centerRepositoryProvider);
    final result = await repository.getNearestCenters(
      latitude: latitude,
      longitude: longitude,
      count: 1,
    );

    switch (result) {
      case Success(data: final centers):
        if (centers.isNotEmpty) {
          final nearest = centers.first;
          state = AsyncValue.data(nearest);
        } else {
          state = const AsyncValue.data(null);
        }
      case Error(failure: final f):
        state = AsyncValue.error(f.message, StackTrace.current);
    }
  }

  /// 모든 센터를 거리순으로 정렬하여 리스트로 반환
  Future<List<CenterEntity>> getOrderedCenters() async {
    final location = ref.read(locationNotifierProvider);
    final repository = ref.read(centerRepositoryProvider);

    final result = await repository.getNearestCenters(
      latitude: location.latitude,
      longitude: location.longitude,
      count: 1000, // 전체를 가져오도록 충분한 수 지정
    );

    switch (result) {
      case Success(data: final centers):
        return centers;
      case Error():
        return [];
    }
  }
}
