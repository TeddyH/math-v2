import 'dart:math';
import 'package:equatable/equatable.dart';
import '../utils/enums.dart';

class MathProblem extends Equatable {
  final int operand1;
  final int operand2;
  final OperationType operation;
  final int correctAnswer;
  final List<int> options; // 정답 1개 + 오답 2개
  final Difficulty difficulty;

  const MathProblem({
    required this.operand1,
    required this.operand2,
    required this.operation,
    required this.correctAnswer,
    required this.options,
    required this.difficulty,
  });

  /// 문제 표시용 문자열
  String get displayProblem {
    return '$operand1 ${operation.symbol} $operand2 = ?';
  }

  /// 정답인지 확인
  bool isCorrectAnswer(int answer) {
    return answer == correctAnswer;
  }

  /// 옵션에서 정답의 인덱스 반환
  int get correctAnswerIndex {
    return options.indexOf(correctAnswer);
  }

  /// 문제 생성 (정적 메서드)
  static MathProblem generate(OperationType operation, Difficulty difficulty) {
    final random = Random();
    final maxNumber = difficulty.maxNumber;
    
    int operand1, operand2, correctAnswer;
    
    // 연산 종류에 따른 피연산자 생성
    switch (operation) {
      case OperationType.addition:
        operand1 = random.nextInt(maxNumber) + 1;
        operand2 = random.nextInt(maxNumber) + 1;
        correctAnswer = operand1 + operand2;
        break;
        
      case OperationType.subtraction:
        // 결과가 음수가 되지 않도록 조정
        operand1 = random.nextInt(maxNumber) + 1;
        operand2 = random.nextInt(operand1) + 1;
        correctAnswer = operand1 - operand2;
        break;
        
      case OperationType.multiplication:
        // 곱셈 결과가 너무 커지지 않도록 조정
        final maxForMultiplication = sqrt(maxNumber).floor();
        operand1 = random.nextInt(maxForMultiplication) + 1;
        operand2 = random.nextInt(maxForMultiplication) + 1;
        correctAnswer = operand1 * operand2;
        break;
        
      case OperationType.division:
        // 나누어 떨어지도록 조정
        operand2 = random.nextInt(maxNumber ~/ 2) + 1;
        final quotient = random.nextInt(maxNumber ~/ operand2) + 1;
        operand1 = operand2 * quotient;
        correctAnswer = quotient;
        break;
        
      case OperationType.random:
        // 랜덤 연산 선택
        final operations = [
          OperationType.addition,
          OperationType.subtraction,
          OperationType.multiplication,
          OperationType.division,
        ];
        final randomOperation = operations[random.nextInt(operations.length)];
        return generate(randomOperation, difficulty);
    }
    
    // 오답 옵션 생성
    final options = <int>[correctAnswer];
    final Set<int> usedNumbers = {correctAnswer};
    
    while (options.length < 3) {
      int wrongAnswer;
      
      // 정답 주변의 합리적인 오답 생성
      if (random.nextBool()) {
        wrongAnswer = correctAnswer + random.nextInt(10) + 1;
      } else {
        wrongAnswer = max(0, correctAnswer - random.nextInt(10) - 1);
      }
      
      if (!usedNumbers.contains(wrongAnswer) && wrongAnswer >= 0) {
        options.add(wrongAnswer);
        usedNumbers.add(wrongAnswer);
      }
    }
    
    // 옵션 섞기
    options.shuffle();
    
    return MathProblem(
      operand1: operand1,
      operand2: operand2,
      operation: operation,
      correctAnswer: correctAnswer,
      options: options,
      difficulty: difficulty,
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() => {
        'operand1': operand1,
        'operand2': operand2,
        'operation': operation.name,
        'correctAnswer': correctAnswer,
        'options': options,
        'difficulty': difficulty.name,
      };

  /// JSON에서 객체 생성
  factory MathProblem.fromJson(Map<String, dynamic> json) {
    return MathProblem(
      operand1: json['operand1'],
      operand2: json['operand2'],
      operation: OperationType.values.firstWhere(
        (e) => e.name == json['operation'],
      ),
      correctAnswer: json['correctAnswer'],
      options: List<int>.from(json['options']),
      difficulty: Difficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
      ),
    );
  }

  @override
  List<Object?> get props => [
        operand1,
        operand2,
        operation,
        correctAnswer,
        options,
        difficulty,
      ];

  @override
  String toString() =>
      'MathProblem($operand1 ${operation.symbol} $operand2 = $correctAnswer)';
}
