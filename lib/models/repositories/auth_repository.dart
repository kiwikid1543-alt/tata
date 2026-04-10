// lib/models/repositories/auth_repository.dart

import '../../core/utils/result.dart';
import '../entities/auth_user.dart';

abstract interface class AuthRepository {
  /// 전화번호 인증을 요청하고 verificationId 또는 에러를 반환
  Future<Result<String>> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String code) onCodeAutoRetrieval,
  });

  /// 인증번호(OTP)를 사용하여 로그인 수행
  Future<Result<AuthUser>> signInWithSms({
    required String verificationId,
    required String smsCode,
  });

  /// 로그아웃
  Future<Result<void>> signOut();

  /// 현재 로그인된 사용자 정보 가져오기 (Firebase Auth 기준)
  AuthUser? get currentUser;

  /// Firestore에서 유저 프로필 정보 가져오기
  Future<Result<AuthUser?>> getProfile(String uid);

  /// Firestore에 유저 프로필 정보 저장/업데이트
  Future<Result<void>> updateProfile(AuthUser user);
}
