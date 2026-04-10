// lib/models/entities/auth_user.dart

class AuthUser {
  final String uid;
  final String? phoneNumber;
  final String? displayName;

  const AuthUser({
    required this.uid,
    this.phoneNumber,
    this.displayName,
  });

  AuthUser copyWith({
    String? uid,
    String? phoneNumber,
    String? displayName,
  }) {
    return AuthUser(
      uid: uid ?? this.uid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
    );
  }

  /// Firebase User 객체로부터 변환하는 팩토리 메서드 (선택 사항)
  factory AuthUser.fromFirebase(dynamic firebaseUser) {
    return AuthUser(
      uid: firebaseUser.uid,
      phoneNumber: firebaseUser.phoneNumber,
      displayName: firebaseUser.displayName,
    );
  }
}
