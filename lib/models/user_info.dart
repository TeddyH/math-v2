import 'package:equatable/equatable.dart';

class UserInfo extends Equatable {
  final String school;
  final int grade;
  final String nickname;
  final String deviceId;

  const UserInfo({
    required this.school,
    required this.grade,
    required this.nickname,
    required this.deviceId,
  });

  /// JSON으로 변환
  Map<String, dynamic> toJson() => {
        'school': school,
        'grade': grade,
        'nickname': nickname,
        'deviceId': deviceId,
      };

  /// JSON에서 객체 생성
  factory UserInfo.fromJson(Map<String, dynamic> json) => UserInfo(
        school: json['school'] ?? '',
        grade: json['grade'] ?? 1,
        nickname: json['nickname'] ?? '',
        deviceId: json['deviceId'] ?? '',
      );

  /// 사용자 정보 표시용 문자열
  String get displayInfo => '$school $grade학년 $nickname';

  /// 복사본 생성
  UserInfo copyWith({
    String? school,
    int? grade,
    String? nickname,
    String? deviceId,
  }) {
    return UserInfo(
      school: school ?? this.school,
      grade: grade ?? this.grade,
      nickname: nickname ?? this.nickname,
      deviceId: deviceId ?? this.deviceId,
    );
  }

  /// 유효성 검사
  bool get isValid {
    return school.isNotEmpty && 
           grade >= 1 && 
           grade <= 6 && 
           nickname.isNotEmpty &&
           deviceId.isNotEmpty;
  }

  @override
  List<Object?> get props => [school, grade, nickname, deviceId];

  @override
  String toString() => 'UserInfo(school: $school, grade: $grade, nickname: $nickname)';
}
