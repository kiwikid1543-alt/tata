// lib/models/entities/auth_user.dart

class AuthUser {
  final String uid;
  final String? phoneNumber;
  final String? displayName;
  final String? nearestCenterName;

  const AuthUser({
    required this.uid,
    this.phoneNumber,
    this.displayName,
    this.nearestCenterName,
  });

  AuthUser copyWith({
    String? uid,
    String? phoneNumber,
    String? displayName,
    String? nearestCenterName,
  }) {
    return AuthUser(
      uid: uid ?? this.uid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      nearestCenterName: nearestCenterName ?? this.nearestCenterName,
    );
  }

  /// Firestore 데이터에서 변환
  factory AuthUser.fromFirestore(Map<String, dynamic> data) {
    return AuthUser(
      uid: data['uid'] as String,
      phoneNumber: data['phoneNumber'] as String?,
      displayName: data['displayName'] as String?,
      nearestCenterName: data['nearestCenterName'] as String?,
    );
  }

  /// Firestore에 저장할 맵으로 변환
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'nearestCenterName': nearestCenterName,
    };
  }

  /// Firebase User 객체로부터 변환
  factory AuthUser.fromFirebase(dynamic firebaseUser) {
    return AuthUser(
      uid: firebaseUser.uid,
      phoneNumber: firebaseUser.phoneNumber,
      displayName: firebaseUser.displayName,
    );
  }
}
