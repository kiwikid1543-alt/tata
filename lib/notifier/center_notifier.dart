// lib/notifier/center_notifier.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../core/services/location_service.dart';
import '../core/utils/result.dart';
import '../models/entities/center_entity.dart';
import '../models/repositories/center_repository_impl.dart';
import 'auth_notifier.dart';

part 'center_notifier.g.dart';

@riverpod
class CenterNotifier extends _$CenterNotifier {
  @override
  AsyncValue<CenterEntity?> build() {
    return const AsyncValue.data(null);
  }

  /// 내 위치를 기반으로 가장 가까운 센터를 찾아 상태에 반영하고 유저 정보에 저장
  Future<void> findAndSaveNearestCenter() async {
    state = const AsyncValue.loading();

    // 1. 현재 위치 가져오기 (이 시점에 권한은 이미 UI에서 처리되었어야 함)
    final position = await LocationService.getCurrentPosition();
    if (position == null) {
      state = AsyncValue.error('위치 정보를 가져올 수 없습니다. 설정에서 위치 권한을 확인해주세요.', StackTrace.current);
      return;
    }

    // 2. 가장 가까운 센터 1개 조회
    final repository = ref.read(centerRepositoryProvider);
    final result = await repository.getNearestCenters(
      latitude: position.latitude,
      longitude: position.longitude,
      count: 1,
    );

    switch (result) {
      case Success(data: final centers):
        if (centers.isNotEmpty) {
          final nearest = centers.first;
          state = AsyncValue.data(nearest);
          
          // 3. 유저 정보에 가까운 센터명 저장 (AuthNotifier 연동)
          ref.read(authNotifierProvider.notifier).updateNearestCenter(nearest.name);
        } else {
          state = const AsyncValue.data(null);
        }
      case Error(failure: final f):
        state = AsyncValue.error(f.message, StackTrace.current);
    }
  }
}
