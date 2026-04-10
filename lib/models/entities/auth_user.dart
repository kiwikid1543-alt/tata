// lib/models/entities/auth_user.dart

class AuthUser {
  final String uid;
  final String? displayName;
  final String? phoneNumber;
  final String? nearestCenterName;
  final bool isQualified;

  AuthUser({
    required this.uid,
    this.displayName,
    this.phoneNumber,
    this.nearestCenterName,
    this.isQualified = true,
  });

  /// Firebase Auth의 User 객체로부터 엔티티 생성
  static AuthUser fromFirebase(dynamic user) {
    return AuthUser(
      uid: user.uid,
      displayName: user.displayName,
      phoneNumber: user.phoneNumber,
    );
  }

  /// Firestore 데이터로부터 객체 생성
  factory AuthUser.fromFirestore(Map<String, dynamic> json) {
    return AuthUser(
      uid: json['uid'] as String,
      displayName: json['displayName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      nearestCenterName: json['nearestCenterName'] as String?,
      isQualified: json['isQualified'] as bool? ?? true,
    );
  }

  /// Firestore에 저장할 JSON 형태로 변환
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'nearestCenterName': nearestCenterName,
      'isQualified': isQualified,
    };
  }

  /// 객체 복사 (불변성 유지)
  AuthUser copyWith({
    String? uid,
    String? displayName,
    String? phoneNumber,
    String? nearestCenterName,
    bool? isQualified,
  }) {
    return AuthUser(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      nearestCenterName: nearestCenterName ?? this.nearestCenterName,
      isQualified: isQualified ?? this.isQualified,
    );
  }
}
