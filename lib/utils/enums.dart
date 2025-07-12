/// 수학 연산 종류
enum OperationType {
  addition,    // 덧셈
  subtraction, // 뺄셈
  multiplication, // 곱셈
  division,    // 나눗셈
  random,      // 랜덤
}

/// 문제 난이도
enum Difficulty {
  oneDigit,    // 한자리 수
  twoDigit,    // 두자리 수
  threeDigit,  // 세자리 수
}

/// 게임 모드
enum GameMode {
  classic,     // 클래식 모드
  airplane,    // 비행기 게임
}

/// 게임 상태
enum GameState {
  waiting,     // 대기
  playing,     // 플레이 중
  paused,      // 일시정지
  gameOver,    // 게임 종료
  ended,       // 게임 결과 화면
}

/// 연산 타입 확장
extension OperationTypeExtension on OperationType {
  String get symbol {
    switch (this) {
      case OperationType.addition:
        return '+';
      case OperationType.subtraction:
        return '-';
      case OperationType.multiplication:
        return '×';
      case OperationType.division:
        return '÷';
      case OperationType.random:
        return '?';
    }
  }

  String get displayName {
    switch (this) {
      case OperationType.addition:
        return '덧셈';
      case OperationType.subtraction:
        return '뺄셈';
      case OperationType.multiplication:
        return '곱셈';
      case OperationType.division:
        return '나눗셈';
      case OperationType.random:
        return '랜덤';
    }
  }
}

/// 난이도 확장
extension DifficultyExtension on Difficulty {
  String get displayName {
    switch (this) {
      case Difficulty.oneDigit:
        return '한자리 수';
      case Difficulty.twoDigit:
        return '두자리 수';
      case Difficulty.threeDigit:
        return '세자리 수';
    }
  }

  int get maxNumber {
    switch (this) {
      case Difficulty.oneDigit:
        return 9;
      case Difficulty.twoDigit:
        return 99;
      case Difficulty.threeDigit:
        return 999;
    }
  }
}

/// 게임 모드 확장
extension GameModeExtension on GameMode {
  String get displayName {
    switch (this) {
      case GameMode.classic:
        return '클래식';
      case GameMode.airplane:
        return '비행기 게임';
    }
  }
}
