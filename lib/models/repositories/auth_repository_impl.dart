import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/utils/failure.dart';
import '../../core/utils/result.dart';
import '../entities/auth_user.dart';
import 'auth_repository.dart';

part 'auth_repository_impl.g.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl(this._auth, this._firestore);

  @override
  Future<Result<String>> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String code) onCodeAutoRetrieval,
  }) async {
    final completer = Completer<Result<String>>();

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          if (credential.smsCode != null) {
            onCodeAutoRetrieval(credential.smsCode!);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          if (!completer.isCompleted) {
            completer.complete(
              Result.failure(
                Failure(e.message ?? '인증 요청 실패', originalError: e),
              ),
            );
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          if (!completer.isCompleted) {
            completer.complete(Result.success(verificationId));
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // 타임아웃
        },
      );
    } catch (e) {
      return Result.failure(Failure('서버와의 통신에 실패했습니다.', originalError: e));
    }

    return completer.future;
  }

  @override
  Future<Result<AuthUser>> signInWithSms({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        return Result.success(AuthUser.fromFirebase(userCredential.user!));
      } else {
        return Result.failure(const Failure('로그인 실패: 유저 정보가 없습니다.'));
      }
    } on FirebaseAuthException catch (e) {
      return Result.failure(
        Failure(e.message ?? '인증번호가 올바르지 않습니다.', originalError: e),
      );
    } catch (e) {
      return Result.failure(
        Failure('로그인 중 알 수 없는 오류가 발생했습니다.', originalError: e),
      );
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _auth.signOut();
      return Result.success(null);
    } catch (e) {
      return Result.failure(Failure('로그아웃 중 오류가 발생했습니다.', originalError: e));
    }
  }

  @override
  AuthUser? get currentUser {
    final user = _auth.currentUser;
    return user != null ? AuthUser.fromFirebase(user) : null;
  }

  @override
  Future<Result<AuthUser?>> getProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return Result.success(AuthUser.fromFirestore(doc.data()!));
      }
      return Result.success(null);
    } catch (e) {
      return Result.failure(Failure('프로필 정보를 가져오지 못했습니다.', originalError: e));
    }
  }

  @override
  Future<Result<void>> updateProfile(AuthUser user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(
            user.toMap(),
            SetOptions(merge: true),
          );
      return Result.success(null);
    } catch (e) {
      return Result.failure(Failure('프로필 정보를 저장하지 못했습니다.', originalError: e));
    }
  }
}

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepositoryImpl(
    FirebaseAuth.instance,
    FirebaseFirestore.instance,
  );
}
