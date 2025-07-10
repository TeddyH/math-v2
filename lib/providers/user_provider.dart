import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_info.dart';
import '../utils/constants.dart';

class UserProvider extends ChangeNotifier {
  UserInfo? _currentUser;
  bool _isLoading = false;

  UserInfo? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null && _currentUser!.isValid;

  /// 사용자 로그인
  Future<bool> login({
    required String school,
    required int grade,
    required String nickname,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 디바이스 ID 생성
      final deviceId = await _generateDeviceId();
      
      final user = UserInfo(
        school: school.trim(),
        grade: grade,
        nickname: nickname.trim(),
        deviceId: deviceId,
      );

      // 유효성 검사
      if (!user.isValid) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // 로컬 스토리지에 저장
      await _saveUserToLocal(user);
      
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      
      return true;
    } catch (e) {
      debugPrint('로그인 오류: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 사용자 로그아웃
  Future<void> logout() async {
    _currentUser = null;
    await _clearUserFromLocal();
    notifyListeners();
  }

  /// 저장된 사용자 정보 로드
  Future<void> loadSavedUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(StorageKeys.userInfo);
      
      if (userJson != null) {
        final userMap = <String, dynamic>{};
        final queryParams = Uri.splitQueryString(userJson);
        queryParams.forEach((key, value) {
          userMap[key] = key == 'grade' ? int.parse(value) : value;
        });
        
        _currentUser = UserInfo.fromJson(userMap);
      }
    } catch (e) {
      debugPrint('사용자 정보 로드 오류: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// 사용자 정보 업데이트
  Future<bool> updateUser({
    String? school,
    int? grade,
    String? nickname,
  }) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final updatedUser = _currentUser!.copyWith(
        school: school,
        grade: grade,
        nickname: nickname,
      );

      if (!updatedUser.isValid) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await _saveUserToLocal(updatedUser);
      _currentUser = updatedUser;
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('사용자 정보 업데이트 오류: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 학년 목록 반환
  List<int> get availableGrades => List.generate(6, (index) => index + 1);

  /// 사용자 통계 정보
  Map<String, dynamic> getUserStats() {
    if (!isLoggedIn) return {};
    
    return {
      'school': _currentUser!.school,
      'grade': _currentUser!.grade,
      'nickname': _currentUser!.nickname,
      'joinDate': DateTime.now().toString().split(' ')[0], // 임시
    };
  }

  /// 입력 유효성 검사
  String? validateSchool(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '학교명을 입력해주세요';
    }
    if (value.trim().length < 2) {
      return '학교명은 2글자 이상 입력해주세요';
    }
    return null;
  }

  String? validateNickname(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '이름을 입력해주세요';
    }
    if (value.trim().length < 2) {
      return '이름은 2글자 이상 입력해주세요';
    }
    if (value.trim().length > 10) {
      return '이름은 10글자 이하로 입력해주세요';
    }
    return null;
  }

  String? validateGrade(int? value) {
    if (value == null || value < 1 || value > 6) {
      return '올바른 학년을 선택해주세요';
    }
    return null;
  }

  // 내부 메서드들

  Future<String> _generateDeviceId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? deviceId = prefs.getString('device_id');
      
      if (deviceId == null) {
        // 플랫폼별 디바이스 ID 생성
        if (Platform.isAndroid || Platform.isIOS) {
          deviceId = DateTime.now().millisecondsSinceEpoch.toString();
        } else {
          deviceId = 'web_${DateTime.now().millisecondsSinceEpoch}';
        }
        await prefs.setString('device_id', deviceId);
      }
      
      return deviceId;
    } catch (e) {
      // 기본 디바이스 ID 반환
      return 'default_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  Future<void> _saveUserToLocal(UserInfo user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = _encodeUserToString(user.toJson());
      await prefs.setString(StorageKeys.userInfo, userJson);
    } catch (e) {
      debugPrint('사용자 정보 저장 오류: $e');
      rethrow;
    }
  }

  Future<void> _clearUserFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(StorageKeys.userInfo);
    } catch (e) {
      debugPrint('사용자 정보 삭제 오류: $e');
    }
  }

  String _encodeUserToString(Map<String, dynamic> userJson) {
    return userJson.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
  }
}
