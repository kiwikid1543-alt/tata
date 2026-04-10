// lib/views/auth/center_selection_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/entities/center_entity.dart';
import '../../notifier/center_notifier.dart';

class CenterSelectionView extends ConsumerStatefulWidget {
  const CenterSelectionView({super.key});

  @override
  ConsumerState<CenterSelectionView> createState() => _CenterSelectionViewState();
}

class _CenterSelectionViewState extends ConsumerState<CenterSelectionView> {
  final _searchController = TextEditingController();
  List<CenterEntity> _allCenters = [];
  List<CenterEntity> _filteredCenters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCenters();
    _searchController.addListener(_filterCenters);
  }

  Future<void> _loadCenters() async {
    final centers = await ref.read(centerNotifierProvider.notifier).getOrderedCenters();
    if (mounted) {
      setState(() {
        _allCenters = centers;
        _filteredCenters = centers;
        _isLoading = false;
      });
    }
  }

  void _filterCenters() {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      setState(() => _filteredCenters = _allCenters);
      return;
    }

    setState(() {
      _filteredCenters = _allCenters.where((center) {
        return center.name.toLowerCase().contains(query) ||
            center.address.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '센터 선택',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '센터명 또는 지역 검색',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredCenters.isEmpty
                    ? Center(
                        child: Text(
                          '검색 결과가 없습니다',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(24),
                        itemCount: _filteredCenters.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final center = _filteredCenters[index];
                          return InkWell(
                            onTap: () => Navigator.pop(context, center),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey[100]!),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          center.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          center.address,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 13,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${center.distanceInKm?.toStringAsFixed(1) ?? "0"}km',
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
