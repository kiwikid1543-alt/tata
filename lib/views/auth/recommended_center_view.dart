// lib/views/auth/recommended_center_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../notifier/auth_notifier.dart';
import '../../notifier/center_notifier.dart';
import '../../core/services/location_service.dart';
import 'package:geolocator/geolocator.dart';

class RecommendedCenterView extends ConsumerStatefulWidget {
  const RecommendedCenterView({super.key});

  @override
  ConsumerState<RecommendedCenterView> createState() =>
      _RecommendedCenterViewState();
}

class _RecommendedCenterViewState extends ConsumerState<RecommendedCenterView> {
  @override
  void initState() {
    super.initState();
    // 페이지 진입 시 즉시 시스템 권한 확인 및 요청 시작
    Future.microtask(() => _handleLocationPermission());
  }

  /// 위치 권한 흐름 처리 (시스템 팝업 직접 호출)
  Future<void> _handleLocationPermission() async {
    // 1. 현재 권한 상태 확인
    LocationPermission status = await LocationService.checkPermission();

    if (status == LocationPermission.denied) {
      // 2. 권한이 없다면 즉시 시스템 권한 팝업 요청
      status = await LocationService.requestPermission();
    }

    if (status == LocationPermission.always ||
        status == LocationPermission.whileInUse) {
      // 3. 권한 획득 시 검색 시작
      _startCenterSearch();
    }
  }

  void _startCenterSearch() {
    if (!mounted) return;
    ref.read(centerNotifierProvider.notifier).findAndSaveNearestCenter();
  }

  @override
  Widget build(BuildContext context) {
    final centerState = ref.watch(centerNotifierProvider);
    final authUser = ref.watch(authNotifierProvider).user;
    final userName = authUser?.displayName ?? '고객';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () =>
              ref.read(authNotifierProvider.notifier).previousStep(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // 헤더 섹션
              Text(
                '$userName님, 환영해요!',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),

              // 동적 메시지 섹션 (RichText로 특정 부분 강조)
              centerState.when(
                data: (center) => Text.rich(
                  TextSpan(
                    children: [
                      if (center != null) ...[
                        const TextSpan(
                          text: '고객님과 가장 가까운 센터는\n',
                          style: TextStyle(color: Colors.black87),
                        ),
                        TextSpan(
                          text: center.name,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w800, // 더 두껍게
                          ),
                        ),
                        const TextSpan(
                          text: ' 이에요',
                          style: TextStyle(color: Colors.black87),
                        ),
                      ] else
                        const TextSpan(text: '가장 가까운 센터를 찾지 못했어요.'),
                    ],
                  ),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                loading: () => const Text(
                  '가장 가까운 센터를\n찾고 있어요...',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                error: (err, _) => const Text(
                  '위치 정보를 확인할 수 없어\n센터를 추천해드리지 못했어요.',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                    color: Colors.grey,
                  ),
                ),
              ),

              const Spacer(),

              // 센터 상세 정보 카드 (데이터가 있을 때만 노출)
              if (centerState.hasValue && centerState.value != null)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Theme.of(context).primaryColor,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '직선거리 약 ${centerState.value!.distanceInKm?.toStringAsFixed(1)}km',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        centerState.value!.address,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.phone, color: Colors.grey, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            centerState.value!.phone,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              const Spacer(),

              // 하단 버튼
              ElevatedButton(
                onPressed: () {
                  ref.read(authNotifierProvider.notifier).finishOnboarding();
                },
                child: const Text('시작하기'),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
