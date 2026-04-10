// lib/core/utils/result.dart

import 'failure.dart';

sealed class Result<T> {
  const Result();

  /// 성공 상태일 때 호출되는 팩토리 메서드
  factory Result.success(T data) = Success<T>;

  /// 실패 상태일 때 호출되는 팩토리 메서드
  factory Result.failure(Failure failure) = Error<T>;

  /// 데이터 또는 null 반환
  T? get dataOrNull => switch (this) {
        Success(data: final d) => d,
        _ => null,
      };

  /// 실패 또는 null 반환
  Failure? get failureOrNull => switch (this) {
        Error(failure: final f) => f,
        _ => null,
      };
}

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

final class Error<T> extends Result<T> {
  final Failure failure;
  const Error(this.failure);
}
