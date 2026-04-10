import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../notifier/auth_notifier.dart';
import '../../notifier/center_notifier.dart';
import '../../core/services/location_service.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/entities/center_entity.dart';
import 'center_selection_view.dart';

class RecommendedCenterView extends ConsumerStatefulWidget {
  const RecommendedCenterView({super.key});

  @override
  ConsumerState<RecommendedCenterView> createState() =>
      _RecommendedCenterViewState();
}

class _RecommendedCenterViewState extends ConsumerState<RecommendedCenterView> {
  CenterEntity? _manuallySelectedCenter;

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
    ref.read(centerNotifierProvider.notifier).findNearestCenter();
  }

  Future<void> _pickCenter() async {
    final result = await Navigator.push<CenterEntity>(
      context,
      MaterialPageRoute(builder: (context) => const CenterSelectionView()),
    );

    if (result != null) {
      setState(() {
        _manuallySelectedCenter = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final centerState = ref.watch(centerNotifierProvider);
    final authUser = ref.watch(authNotifierProvider).user;
    final userName = authUser?.displayName ?? '고객';

    // 표시할 최종 센터 결정
    final displayCenter = _manuallySelectedCenter ?? centerState.value;

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
              // Step Indicator
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 32,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 32,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
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

              // 동적 메시지 섹션
              if (displayCenter != null)
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: _manuallySelectedCenter != null
                            ? '선택하신 센터는\n'
                            : '고객님과 가장 가까운 센터는\n',
                        style: const TextStyle(color: Colors.black87),
                      ),
                      TextSpan(
                        text: displayCenter.name,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const TextSpan(
                        text: ' 이에요',
                        style: TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                )
              else
                centerState.when(
                  data: (_) => const Text(
                    '가장 가까운 센터를 찾지 못했어요.',
                    style: TextStyle(
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

              // 센터 상세 정보 카드
              if (displayCenter != null)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
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
                            '직선거리 약 ${displayCenter.distanceInKm?.toStringAsFixed(1) ?? "0"}km',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        displayCenter.address,
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
                            displayCenter.phone,
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

              const SizedBox(height: 24),

              // 다른 센터 선택 버튼
              Center(
                child: TextButton(
                  onPressed: _pickCenter,
                  child: Text(
                    '다른 센터 선택하기',
                    style: TextStyle(
                      color: Colors.grey[600],
                      decoration: TextDecoration.underline,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // 하단 버튼
              ElevatedButton(
                onPressed: displayCenter != null
                    ? () async {
                        // 선택된 센터의 이름을 저장
                        await ref
                            .read(authNotifierProvider.notifier)
                            .saveMyCenter(displayCenter.name);
                        if (mounted) {
                          ref.read(authNotifierProvider.notifier).finishOnboarding();
                        }
                      }
                    : null,
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
