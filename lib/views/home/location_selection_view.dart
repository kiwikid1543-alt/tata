// lib/views/home/location_selection_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../notifier/location_notifier.dart';
import '../../notifier/center_notifier.dart';

class LocationSelectionView extends ConsumerWidget {
  const LocationSelectionView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(locationNotifierProvider);
    final locationNotifier = ref.read(locationNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('위치 설정'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _buildLocationTile(
            context,
            ref,
            title: '내 실제 위치 (GPS)',
            subtitle: '현재 GPS 기기 정보를 사용합니다.',
            isSelected: !locationState.isMocked,
            onTap: () async {
              await locationNotifier.useRealLocation();
              if (context.mounted) {
                ref.read(centerNotifierProvider.notifier).findAndSaveNearestCenter();
                Navigator.pop(context);
              }
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Divider(height: 1),
          ),
          _buildLocationTile(
            context,
            ref,
            title: '서울시청',
            subtitle: '서울특별시 중구 (37.5665, 126.9780)',
            isSelected: locationState.isMocked && locationState.name == '서울시청',
            onTap: () {
              locationNotifier.setMockLocation('서울시청', 37.5665, 126.9780);
              ref.read(centerNotifierProvider.notifier).findAndSaveNearestCenter();
              Navigator.pop(context);
            },
          ),
          _buildLocationTile(
            context,
            ref,
            title: '대전시청',
            subtitle: '대전광역시 서구 (36.3504, 127.3845)',
            isSelected: locationState.isMocked && locationState.name == '대전시청',
            onTap: () {
              locationNotifier.setMockLocation('대전시청', 36.3504, 127.3845);
              ref.read(centerNotifierProvider.notifier).findAndSaveNearestCenter();
              Navigator.pop(context);
            },
          ),
          _buildLocationTile(
            context,
            ref,
            title: '인천시청',
            subtitle: '인천광역시 남동구 (37.4563, 126.7052)',
            isSelected: locationState.isMocked && locationState.name == '인천시청',
            onTap: () {
              locationNotifier.setMockLocation('인천시청', 37.4563, 126.7052);
              ref.read(centerNotifierProvider.notifier).findAndSaveNearestCenter();
              Navigator.pop(context);
            },
          ),
          _buildLocationTile(
            context,
            ref,
            title: '강원도청',
            subtitle: '강원도 춘천시 (37.8853, 127.7298)',
            isSelected: locationState.isMocked && locationState.name == '강원도청',
            onTap: () {
              locationNotifier.setMockLocation('강원도청', 37.8853, 127.7298);
              ref.read(centerNotifierProvider.notifier).findAndSaveNearestCenter();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLocationTile(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      title: Text(
        title, 
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
        )
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.6) : Colors.grey),
      ),
      trailing: isSelected 
          ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor)
          : const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      onTap: onTap,
    );
  }
}
