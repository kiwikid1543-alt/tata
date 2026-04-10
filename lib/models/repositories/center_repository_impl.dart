// lib/models/repositories/center_repository_impl.dart

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../core/utils/failure.dart';
import '../../core/utils/result.dart';
import '../dto/center_dto.dart';
import '../entities/center_entity.dart';
import 'center_repository.dart';

part 'center_repository_impl.g.dart';

class CenterRepositoryImpl implements CenterRepository {
  final Dio _dio;
  
  // 공공데이터 API 설정
  static const String _baseUrl = 'https://apis.data.go.kr/B551982/tsdo_v2/center_info_v2';
  final String _serviceKey = dotenv.env['DATA_GO_KR_SERVICE_KEY'] ?? '';

  CenterRepositoryImpl(this._dio);

  @override
  Future<Result<List<CenterEntity>>> getAllCenters() async {
    try {
      final response = await _dio.get(
        _baseUrl,
        queryParameters: {
          'serviceKey': _serviceKey,
          'pageNo': 1,
          'numOfRows': 1000, // 충분히 큰 수로 전체 센터 획득
          '_type': 'json',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        // 공공데이터 API 특유의 중첩 구조 파악 (body -> item)
        final List<dynamic>? items = data['body']?['item'];
        
        if (items == null) {
          return const Success([]);
        }

        final entities = items
            .map((json) => CenterEntity.fromDto(CenterDto.fromJson(json)))
            .toList();
            
        return Success(entities);
      } else {
        return Error(Failure('API 호출 실패 (상태 코드: ${response.statusCode})'));
      }
    } catch (e) {
      return Error(Failure('네트워크 오류: ${e.toString()}'));
    }
  }

  @override
  Future<Result<List<CenterEntity>>> getNearestCenters({
    required double latitude,
    required double longitude,
    int count = 1,
  }) async {
    final result = await getAllCenters();
    
    switch (result) {
      case Success(data: final centers):
        // 1. 모든 센터의 사용자와의 거리를 계산
        final centersWithDistance = centers.map((c) => c.withDistance(latitude, longitude)).toList();
        
        // 2. 거리 순 정렬 (오름차순)
        centersWithDistance.sort((a, b) => (a.distanceInKm ?? 0).compareTo(b.distanceInKm ?? 0));
        
        // 3. 요청된 개수만큼 반환
        return Success(centersWithDistance.take(count).toList());
        
      case Error(failure: final f):
        return Error(f);
    }
  }
}

@riverpod
CenterRepository centerRepository(CenterRepositoryRef ref) {
  return CenterRepositoryImpl(Dio());
}
