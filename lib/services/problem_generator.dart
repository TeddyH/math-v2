import 'dart:math';
import '../models/math_problem.dart';
import '../utils/enums.dart';

class ProblemGenerator {
  static final Random _random = Random();

  /// 단일 문제 생성
  static MathProblem generateProblem(
    OperationType operation,
    Difficulty difficulty,
  ) {
    // 랜덤 연산인 경우 랜덤하게 연산 선택
    if (operation == OperationType.random) {
      final operations = [
        OperationType.addition,
        OperationType.subtraction,
        OperationType.multiplication,
        OperationType.division,
      ];
      operation = operations[_random.nextInt(operations.length)];
    }

    return MathProblem.generate(operation, difficulty);
  }

  /// 연속 문제 생성 (난이도 점진적 증가)
  static List<MathProblem> generateProgressiveProblems({
    required OperationType operation,
    required Difficulty startDifficulty,
    required int count,
    bool increaseDifficulty = true,
  }) {
    final problems = <MathProblem>[];
    var currentDifficulty = startDifficulty;

    for (int i = 0; i < count; i++) {
      problems.add(generateProblem(operation, currentDifficulty));

      // 5문제마다 난이도 증가 (옵션)
      if (increaseDifficulty && (i + 1) % 5 == 0) {
        currentDifficulty = _getNextDifficulty(currentDifficulty);
      }
    }

    return problems;
  }

  /// 혼합 문제 생성 (여러 연산 타입)
  static List<MathProblem> generateMixedProblems({
    required List<OperationType> operations,
    required List<Difficulty> difficulties,
    required int count,
  }) {
    final problems = <MathProblem>[];

    for (int i = 0; i < count; i++) {
      final operation = operations[_random.nextInt(operations.length)];
      final difficulty = difficulties[_random.nextInt(difficulties.length)];
      problems.add(generateProblem(operation, difficulty));
    }

    return problems;
  }

  /// 특정 패턴의 문제 생성
  static List<MathProblem> generatePatternProblems({
    required OperationType operation,
    required Difficulty difficulty,
    required int count,
    String? pattern,
  }) {
    final problems = <MathProblem>[];

    switch (pattern) {
      case 'sequential': // 순차적 증가
        problems.addAll(_generateSequentialProblems(operation, difficulty, count));
        break;
      case 'table': // 구구단 패턴
        if (operation == OperationType.multiplication) {
          problems.addAll(_generateTableProblems(difficulty, count));
        } else {
          problems.addAll(_generateDefaultProblems(operation, difficulty, count));
        }
        break;
      case 'reverse': // 역순 패턴
        problems.addAll(_generateReverseProblems(operation, difficulty, count));
        break;
      default:
        problems.addAll(_generateDefaultProblems(operation, difficulty, count));
    }

    return problems;
  }

  /// 사용자 수준에 맞는 문제 생성
  static MathProblem generateAdaptiveProblem({
    required OperationType operation,
    required Difficulty baseDifficulty,
    required double successRate, // 0.0 ~ 1.0
    required int consecutiveCorrect,
  }) {
    var adjustedDifficulty = baseDifficulty;

    // 성공률과 연속 정답에 따른 난이도 조정
    if (successRate > 0.8 && consecutiveCorrect >= 5) {
      adjustedDifficulty = _getNextDifficulty(baseDifficulty);
    } else if (successRate < 0.5) {
      adjustedDifficulty = _getPreviousDifficulty(baseDifficulty);
    }

    return generateProblem(operation, adjustedDifficulty);
  }

  /// 복습용 문제 생성 (틀린 문제 유형 기반)
  static List<MathProblem> generateReviewProblems({
    required List<MathProblem> incorrectProblems,
    required int count,
  }) {
    final problems = <MathProblem>[];
    
    if (incorrectProblems.isEmpty) {
      // 틀린 문제가 없으면 기본 문제 생성
      return _generateDefaultProblems(
        OperationType.addition,
        Difficulty.oneDigit,
        count,
      );
    }

    // 틀린 문제 패턴 분석
    final operationCounts = <OperationType, int>{};
    final difficultyCounts = <Difficulty, int>{};

    for (final problem in incorrectProblems) {
      operationCounts[problem.operation] = 
          (operationCounts[problem.operation] ?? 0) + 1;
      difficultyCounts[problem.difficulty] = 
          (difficultyCounts[problem.difficulty] ?? 0) + 1;
    }

    // 가장 많이 틀린 연산과 난이도로 문제 생성
    final mostMissedOperation = operationCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    final mostMissedDifficulty = difficultyCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    for (int i = 0; i < count; i++) {
      problems.add(generateProblem(mostMissedOperation, mostMissedDifficulty));
    }

    return problems;
  }

  /// 시간 제한 문제 생성 (빠른 계산 연습용)
  static List<MathProblem> generateSpeedProblems({
    required OperationType operation,
    required Difficulty difficulty,
    required int count,
  }) {
    final problems = <MathProblem>[];

    for (int i = 0; i < count; i++) {
      // 빠른 계산을 위해 간단한 수로 제한
      var problem = generateProblem(operation, difficulty);
      
      // 결과가 너무 복잡하지 않도록 재생성
      while (_isComplexProblem(problem)) {
        problem = generateProblem(operation, difficulty);
      }
      
      problems.add(problem);
    }

    return problems;
  }

  // 내부 헬퍼 메서드들

  static Difficulty _getNextDifficulty(Difficulty current) {
    switch (current) {
      case Difficulty.oneDigit:
        return Difficulty.twoDigit;
      case Difficulty.twoDigit:
        return Difficulty.threeDigit;
      case Difficulty.threeDigit:
        return Difficulty.threeDigit; // 최고 난이도 유지
    }
  }

  static Difficulty _getPreviousDifficulty(Difficulty current) {
    switch (current) {
      case Difficulty.oneDigit:
        return Difficulty.oneDigit; // 최저 난이도 유지
      case Difficulty.twoDigit:
        return Difficulty.oneDigit;
      case Difficulty.threeDigit:
        return Difficulty.twoDigit;
    }
  }

  static List<MathProblem> _generateDefaultProblems(
    OperationType operation,
    Difficulty difficulty,
    int count,
  ) {
    return List.generate(
      count,
      (index) => generateProblem(operation, difficulty),
    );
  }

  static List<MathProblem> _generateSequentialProblems(
    OperationType operation,
    Difficulty difficulty,
    int count,
  ) {
    final problems = <MathProblem>[];
    
    for (int i = 0; i < count; i++) {
      var problem = generateProblem(operation, difficulty);
      
      // 순차적 패턴 적용 (첫 번째 피연산자를 순차 증가)
      final baseOperand = (i % 10) + 1;
      problem = MathProblem.generate(operation, difficulty);
      
      problems.add(problem);
    }
    
    return problems;
  }

  static List<MathProblem> _generateTableProblems(
    Difficulty difficulty,
    int count,
  ) {
    final problems = <MathProblem>[];
    final tables = [2, 3, 4, 5, 6, 7, 8, 9]; // 구구단
    
    for (int i = 0; i < count; i++) {
      final table = tables[i % tables.length];
      final multiplier = (i % 9) + 1;
      
      final problem = MathProblem(
        operand1: table,
        operand2: multiplier,
        operation: OperationType.multiplication,
        correctAnswer: table * multiplier,
        options: _generateMultiplicationOptions(table * multiplier),
        difficulty: difficulty,
      );
      
      problems.add(problem);
    }
    
    return problems;
  }

  static List<MathProblem> _generateReverseProblems(
    OperationType operation,
    Difficulty difficulty,
    int count,
  ) {
    final problems = <MathProblem>[];
    
    for (int i = 0; i < count; i++) {
      var problem = generateProblem(operation, difficulty);
      
      // 피연산자 순서 바꾸기 (뺄셈, 나눗셈 제외)
      if (operation == OperationType.addition || 
          operation == OperationType.multiplication) {
        problem = MathProblem(
          operand1: problem.operand2,
          operand2: problem.operand1,
          operation: problem.operation,
          correctAnswer: problem.correctAnswer,
          options: problem.options,
          difficulty: problem.difficulty,
        );
      }
      
      problems.add(problem);
    }
    
    return problems;
  }

  static List<int> _generateMultiplicationOptions(int correctAnswer) {
    final options = <int>[correctAnswer];
    final Set<int> usedNumbers = {correctAnswer};
    
    while (options.length < 3) {
      int wrongAnswer;
      
      if (_random.nextBool()) {
        wrongAnswer = correctAnswer + _random.nextInt(10) + 1;
      } else {
        wrongAnswer = max(0, correctAnswer - _random.nextInt(10) - 1);
      }
      
      if (!usedNumbers.contains(wrongAnswer) && wrongAnswer >= 0) {
        options.add(wrongAnswer);
        usedNumbers.add(wrongAnswer);
      }
    }
    
    options.shuffle();
    return options;
  }

  static bool _isComplexProblem(MathProblem problem) {
    // 복잡한 문제인지 판단 (빠른 계산에 부적합)
    if (problem.correctAnswer > 100) return true;
    if (problem.operation == OperationType.division && 
        problem.correctAnswer > 20) return true;
    if (problem.operation == OperationType.multiplication && 
        (problem.operand1 > 12 || problem.operand2 > 12)) return true;
    
    return false;
  }
}
