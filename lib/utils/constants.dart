import 'package:flutter/material.dart';

/// 앱 색상 팔레트 (초등학생 친화적)
class AppColors {
  static const Color primary = Color(0xFF2196F3);      // 파란색
  static const Color secondary = Color(0xFFFF9800);    // 주황색
  static const Color accent = Color(0xFF4CAF50);       // 초록색
  static const Color danger = Color(0xFFE91E63);       // 핑크색
  static const Color warning = Color(0xFFFFC107);      // 노란색
  static const Color success = Color(0xFF4CAF50);      // 초록색
  
  // 배경색
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFAFAFA);
  
  // 텍스트색
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFFFFFFF);
  
  // 게임 관련 색상
  static const Color airplane = Color(0xFF03A9F4);
  static const Color correctAnswer = Color(0xFF4CAF50);
  static const Color wrongAnswer = Color(0xFFE91E63);
  static const Color gameBackground = Color(0xFF87CEEB); // 하늘색
}

/// 앱 텍스트 스타일
class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textLight,
  );

  static const TextStyle problem = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle score = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  static const TextStyle appBarTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textLight,
  );
}

/// 앱 간격 상수
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

/// 앱 크기 상수
class AppSizes {
  static const double buttonHeight = 48.0;
  static const double iconSize = 24.0;
  static const double largeIconSize = 48.0;
  static const double cardRadius = 12.0;
  static const double buttonRadius = 8.0;
}

/// 앱 애니메이션 상수
class AppAnimations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 400);
  static const Duration slow = Duration(milliseconds: 600);
  
  // 게임 관련 애니메이션
  static const Duration fallSpeed = Duration(milliseconds: 3000);
  static const Duration explosionDuration = Duration(milliseconds: 800);
  static const Duration scorePopupDuration = Duration(milliseconds: 1200);
}

/// 로컬 스토리지 키
class StorageKeys {
  static const String userInfo = 'user_info';
  static const String highScores = 'high_scores';
  static const String gameSettings = 'game_settings';
  static const String soundEnabled = 'sound_enabled';
  static const String vibrationEnabled = 'vibration_enabled';
}

/// 게임 설정 상수
class GameConstants {
  // 클래식 게임
  static const int maxProblems = 100;
  static const int timeLimit = 60; // 초 (미사용)
  
  // 비행기 게임
  static const double airplaneSpeed = 0.05;
  static const double fallSpeed = 0.0065;
  static const int wrongAnswersCount = 2;
  static const int backgroundElementsCount = 10;
  
  // 점수 계산
  static const Map<String, int> baseScores = {
    'addition': 10,
    'subtraction': 15,
    'multiplication': 20,
    'division': 25,
    'random': 30,
  };
  
  static const Map<String, double> difficultyMultipliers = {
    'oneDigit': 1.0,
    'twoDigit': 1.5,
    'threeDigit': 2.0,
  };
  
  static const int comboBonus = 5; // 연속 정답 보너스
}

/// 앱 문자열 상수
class AppStrings {
  // 앱 정보
  static const String appName = '두뇌 트레이닝: 초등수학';
  static const String appVersion = '1.0.0';
  
  // 로그인 화면
  static const String loginTitle = '정보를 입력해주세요';
  static const String schoolHint = '학교명을 입력하세요';
  static const String gradeHint = '학년을 선택하세요';
  static const String nicknameHint = '이름(별명)을 입력하세요';
  static const String loginButton = '시작하기';
  
  // 게임 모드
  static const String selectGameMode = '게임 모드를 선택하세요';
  static const String classicMode = '클래식 모드';
  static const String airplaneMode = '비행기 게임';
  
  // 게임 설정
  static const String selectOperation = '연산을 선택하세요';
  static const String selectDifficulty = '난이도를 선택하세요';
  static const String startGame = '게임 시작';
  
  // 게임 플레이
  static const String score = '점수';
  static const String problems = '문제';
  static const String gameOver = '게임 종료';
  static const String correct = '정답!';
  static const String wrong = '틀렸습니다';
  
  // 랭킹
  static const String leaderboard = '랭킹';
  static const String classicRanking = '클래식 랭킹';
  static const String airplaneRanking = '비행기 게임 랭킹';
  static const String noData = '데이터가 없습니다';
  
  // 공통
  static const String ok = '확인';
  static const String cancel = '취소';
  static const String retry = '다시하기';
  static const String back = '뒤로';
  static const String next = '다음';
}

/// 앱 아이콘
class AppIcons {
  static const IconData addition = Icons.add;
  static const IconData subtraction = Icons.remove;
  static const IconData multiplication = Icons.close;
  static const IconData division = Icons.horizontal_rule;
  static const IconData random = Icons.shuffle;
  static const IconData airplane = Icons.airplanemode_active;
  static const IconData trophy = Icons.emoji_events;
  static const IconData settings = Icons.settings;
  static const IconData back = Icons.arrow_back;
  static const IconData home = Icons.home;
  static const IconData play = Icons.play_arrow;
  static const IconData pause = Icons.pause;
  static const IconData school = Icons.school;
  static const IconData person = Icons.person;
  static const IconData grade = Icons.grade;
}

/// 앱 이미지 경로
class AppImages {
  static const String airplane = 'assets/images/airplane.png';
  static const String cloud = 'assets/images/cloud.png';
  static const String bird = 'assets/images/bird.png';
}

/// 앱 이모지 (임시 이미지 대체용)
class AppEmojis {
  static const String airplane = '🛩️';
  static const String airplane2 = '✈️';
  static const String rocket = '🚀';
  static const String helicopter = '🚁';
  static const String cloud = '☁️';
  static const String bird = '🐦';
  static const String star = '⭐';
  static const String explosion = '💥';
  static const String sparkles = '✨';
  static const String rainbow = '🌈';
}
