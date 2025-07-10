import '../models/math_problem.dart';
import '../utils/enums.dart';
import '../utils/constants.dart';

class ScoreCalculator {
  /// 기본 점수 계산
  static int calculateBaseScore(OperationType operation, Difficulty difficulty) {
    final baseScore = GameConstants.baseScores[operation.name] ?? 10;
    final multiplier = GameConstants.difficultyMultipliers[difficulty.name] ?? 1.0;
    
    return (baseScore * multiplier).round();
  }

  /// 연속 정답 보너스 계산
  static int calculateComboBonus(int consecutiveCorrect) {
    return consecutiveCorrect * GameConstants.comboBonus;
  }

  /// 총 점수 계산 (기본 점수 + 보너스)
  static int calculateTotalScore({
    required OperationType operation,
    required Difficulty difficulty,
    int consecutiveCorrect = 0,
    bool isCorrect = true,
  }) {
    if (!isCorrect) return 0;
    
    final baseScore = calculateBaseScore(operation, difficulty);
    final comboBonus = calculateComboBonus(consecutiveCorrect);
    
    return baseScore + comboBonus;
  }

  /// 시간 보너스 계산 (빠른 답변 시)
  static int calculateTimeBonus(Duration answerTime, Difficulty difficulty) {
    // 기준 시간 (난이도별)
    final baseTime = switch (difficulty) {
      Difficulty.oneDigit => const Duration(seconds: 5),
      Difficulty.twoDigit => const Duration(seconds: 8),
      Difficulty.threeDigit => const Duration(seconds: 12),
    };
    
    // 기준 시간보다 빠르면 보너스
    if (answerTime < baseTime) {
      final savedTime = baseTime.inMilliseconds - answerTime.inMilliseconds;
      return (savedTime / 1000).round(); // 절약한 초당 1점
    }
    
    return 0;
  }

  /// 레벨별 점수 배수
  static double getLevelMultiplier(int level) {
    if (level <= 5) return 1.0;
    if (level <= 10) return 1.2;
    if (level <= 20) return 1.5;
    return 2.0;
  }

  /// 완벽한 게임 보너스 (연속 정답 수에 따라)
  static int calculatePerfectGameBonus(int consecutiveCorrect) {
    if (consecutiveCorrect >= 50) return 1000;
    if (consecutiveCorrect >= 30) return 500;
    if (consecutiveCorrect >= 20) return 300;
    if (consecutiveCorrect >= 10) return 100;
    return 0;
  }

  /// 게임 모드별 점수 조정
  static int adjustScoreByGameMode(int baseScore, GameMode mode) {
    switch (mode) {
      case GameMode.classic:
        return baseScore;
      case GameMode.airplane:
        return (baseScore * 1.2).round(); // 비행기 게임은 20% 보너스
    }
  }

  /// 문제 분석에 따른 점수 조정
  static int adjustScoreByProblemAnalysis(MathProblem problem, int baseScore) {
    // 큰 수의 계산일 때 추가 점수
    final largestOperand = problem.operand1 > problem.operand2 
        ? problem.operand1 
        : problem.operand2;
    
    if (largestOperand > 100) {
      baseScore = (baseScore * 1.1).round();
    }
    
    // 특별한 연산 조합 보너스
    if (problem.operation == OperationType.division && 
        problem.operand1 % problem.operand2 == 0) {
      baseScore += 5; // 나누어 떨어지는 나눗셈 보너스
    }
    
    return baseScore;
  }

  /// 최종 점수 계산 (모든 요소 고려)
  static int calculateFinalScore({
    required MathProblem problem,
    required GameMode mode,
    required Duration answerTime,
    required int consecutiveCorrect,
    required int currentLevel,
    required bool isCorrect,
  }) {
    if (!isCorrect) return 0;
    
    // 기본 점수
    int score = calculateBaseScore(problem.operation, problem.difficulty);
    
    // 문제 분석 조정
    score = adjustScoreByProblemAnalysis(problem, score);
    
    // 게임 모드 조정
    score = adjustScoreByGameMode(score, mode);
    
    // 연속 정답 보너스
    score += calculateComboBonus(consecutiveCorrect);
    
    // 시간 보너스
    score += calculateTimeBonus(answerTime, problem.difficulty);
    
    // 레벨 배수 적용
    final levelMultiplier = getLevelMultiplier(currentLevel);
    score = (score * levelMultiplier).round();
    
    return score;
  }

  /// 점수 등급 계산
  static String calculateGrade(int score, int problemsSolved) {
    if (problemsSolved == 0) return 'F';
    
    final averageScore = score / problemsSolved;
    
    if (averageScore >= 50) return 'S+';
    if (averageScore >= 40) return 'S';
    if (averageScore >= 35) return 'A+';
    if (averageScore >= 30) return 'A';
    if (averageScore >= 25) return 'B+';
    if (averageScore >= 20) return 'B';
    if (averageScore >= 15) return 'C+';
    if (averageScore >= 10) return 'C';
    return 'D';
  }

  /// 점수에 따른 격려 메시지
  static String getEncouragementMessage(int score, int consecutiveCorrect) {
    if (consecutiveCorrect >= 20) {
      return '🏆 완벽해요! 연속 ${consecutiveCorrect}개 정답!';
    } else if (consecutiveCorrect >= 10) {
      return '🎉 훌륭해요! 연속 ${consecutiveCorrect}개 정답!';
    } else if (consecutiveCorrect >= 5) {
      return '👏 잘하고 있어요! 연속 ${consecutiveCorrect}개 정답!';
    } else if (score > 100) {
      return '🌟 좋아요! ${score}점 달성!';
    } else if (score > 50) {
      return '😊 잘하고 있어요!';
    } else {
      return '💪 화이팅! 계속 도전해보세요!';
    }
  }
}
