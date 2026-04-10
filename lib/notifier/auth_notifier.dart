// lib/notifier/auth_notifier.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../core/utils/result.dart';
import '../models/entities/auth_user.dart';
import '../models/repositories/auth_repository_impl.dart';

part 'auth_notifier.g.dart';

enum AuthStep { initial, smsSent, authenticating, success, error }

class AuthState {
  final AuthStep step;
  final String? verificationId;
  final AuthUser? user;
  final String? errorMessage;

  const AuthState({
    this.step = AuthStep.initial,
    this.verificationId,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStep? step,
    String? verificationId,
    AuthUser? user,
    String? errorMessage,
  }) {
    return AuthState(
      step: step ?? this.step,
      verificationId: verificationId ?? this.verificationId,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    return const AuthState();
  }

  /// SMS 인증번호 발송 요청
  Future<void> requestOtp(String phoneNumber) async {
    state = state.copyWith(step: AuthStep.authenticating, errorMessage: null);

    // 전화번호 정규화 (예: 01012345678 -> +821012345678)
    var normalizedPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), ''); // 숫자만 남김
    if (normalizedPhone.startsWith('0')) {
      normalizedPhone = '+82${normalizedPhone.substring(1)}';
    } else if (!normalizedPhone.startsWith('+')) {
      // 국가번호가 없고 0으로 시작하지도 않는 경우 기본값 +82 적용
      normalizedPhone = '+82$normalizedPhone';
    }

    final repository = ref.read(authRepositoryProvider);
    final result = await repository.verifyPhoneNumber(
      phoneNumber: normalizedPhone,
      onCodeAutoRetrieval: (code) {
        // 자동 완성 기능 (추후 UI 연동 가능)
      },
    );

    switch (result) {
      case Success(data: final vId):
        state = state.copyWith(step: AuthStep.smsSent, verificationId: vId);
      case Error(failure: final f):
        state = state.copyWith(step: AuthStep.error, errorMessage: f.message);
    }
  }

  /// OTP를 이용한 최종 로그인
  Future<void> loginWithOtp(String smsCode) async {
    final vId = state.verificationId;
    if (vId == null) return;

    state = state.copyWith(step: AuthStep.authenticating);
    
    final repository = ref.read(authRepositoryProvider);
    final result = await repository.signInWithSms(
      verificationId: vId,
      smsCode: smsCode,
    );

    switch (result) {
      case Success(data: final user):
        state = state.copyWith(step: AuthStep.success, user: user);
      case Error(failure: final f):
        state = state.copyWith(step: AuthStep.error, errorMessage: f.message);
    }
  }

  /// 로그아웃
  Future<void> logout() async {
    final repository = ref.read(authRepositoryProvider);
    await repository.signOut();
    state = const AuthState();
  }
}
