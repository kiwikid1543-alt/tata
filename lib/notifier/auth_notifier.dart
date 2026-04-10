// lib/notifier/auth_notifier.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../core/utils/result.dart';
import '../models/entities/auth_user.dart';
import '../models/repositories/auth_repository_impl.dart';

part 'auth_notifier.g.dart';

enum AuthStep {
  initial,
  smsSent,
  authenticating,
  success,
  error,
  onboardingNickname,
  onboardingQualification
}

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

    var normalizedPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (normalizedPhone.startsWith('0')) {
      normalizedPhone = '+82${normalizedPhone.substring(1)}';
    } else if (!normalizedPhone.startsWith('+')) {
      normalizedPhone = '+82$normalizedPhone';
    }

    final repository = ref.read(authRepositoryProvider);
    final result = await repository.verifyPhoneNumber(
      phoneNumber: normalizedPhone,
      onCodeAutoRetrieval: (code) {
        // 자동 완성
      },
    );

    switch (result) {
      case Success(data: final vId):
        state = state.copyWith(step: AuthStep.smsSent, verificationId: vId);
      case Error(failure: final f):
        state = state.copyWith(step: AuthStep.error, errorMessage: f.message);
    }
  }

  /// OTP를 이용한 최종 로그인 및 가입 분기
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
      case Success(data: final authUser):
        // 1. 인증 성공 후 Firestore 프로필 확인
        final profileResult = await repository.getProfile(authUser.uid);

        switch (profileResult) {
          case Success(data: final profile):
            if (profile != null && profile.displayName != null && profile.displayName!.isNotEmpty) {
              // 2. 닉네임까지 있는 회원 -> 로그인 성공
              state = state.copyWith(step: AuthStep.success, user: profile);
            } else {
              // 3. 닉네임이 없는 회원 (신규 가입 절차 필요)
              state = state.copyWith(
                step: AuthStep.onboardingNickname,
                user: authUser, // Auth 정보만 있는 유저 객체 유지
              );
            }
          case Error(failure: final f):
            state = state.copyWith(step: AuthStep.error, errorMessage: f.message);
        }

      case Error(failure: final f):
        state = state.copyWith(step: AuthStep.error, errorMessage: f.message);
    }
  }

  /// 닉네임 설정 (온보딩)
  void setNickname(String nickname) {
    if (state.user == null) return;
    
    state = state.copyWith(
      user: state.user!.copyWith(displayName: nickname),
      step: AuthStep.onboardingQualification,
    );
  }

  /// 자격 확인 및 최종 가입 완료
  Future<void> completeSignup() async {
    if (state.user == null) return;

    state = state.copyWith(step: AuthStep.authenticating);
    
    final repository = ref.read(authRepositoryProvider);
    final result = await repository.updateProfile(state.user!);

    switch (result) {
      case Success():
        state = state.copyWith(step: AuthStep.success);
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
