import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/game_state.dart';
import '../models/math_problem.dart';
import '../models/user_info.dart';
import '../services/problem_generator.dart';
import '../services/score_calculator.dart';
import '../utils/enums.dart';
import '../utils/constants.dart';

class GameProvider extends ChangeNotifier {
  GameStateModel _gameState = const GameStateModel();
  Timer? _gameTimer;
  DateTime? _problemStartTime;
  
  // 비행기 게임 관련
  double _airplaneX = 0.5; // 0.0 ~ 1.0
  bool _airplaneFlashing = false; // 충돌 시 깜빡임 효과
  Timer? _airplaneFlashTimer;
  final List<FallingAnswer> _fallingAnswers = [];
  final List<BackgroundElement> _backgroundElements = [];
  final List<CollisionEffect> _collisionEffects = [];
  final List<ScorePopup> _scorePopups = [];
  Timer? _airplaneGameTimer;

  // Getters
  GameStateModel get gameState => _gameState;
  double get airplaneX => _airplaneX;
  bool get airplaneFlashing => _airplaneFlashing;
  List<FallingAnswer> get fallingAnswers => List.unmodifiable(_fallingAnswers);
  List<BackgroundElement> get backgroundElements => List.unmodifiable(_backgroundElements);
  List<CollisionEffect> get collisionEffects => List.unmodifiable(_collisionEffects);
  List<ScorePopup> get scorePopups => List.unmodifiable(_scorePopups);
  
  bool get isGameActive => _gameState.isGameActive;
  bool get isClassicMode => _gameState.mode == GameMode.classic;
  bool get isAirplaneMode => _gameState.mode == GameMode.airplane;
  MathProblem? get currentProblem => _gameState.currentProblem;
  int get currentScore => _gameState.currentScore;
  int get problemsSolved => _gameState.problemsSolved;

  /// 사용자 설정
  void setUser(UserInfo user) {
    _gameState = _gameState.setUser(user);
    notifyListeners();
  }

  /// 게임 시작
  Future<void> startGame({
    required GameMode mode,
    required OperationType operation,
    required Difficulty difficulty,
  }) async {
    // 게임 상태 초기화
    _gameState = _gameState.startGame(
      gameMode: mode,
      operation: operation,
      difficulty: difficulty,
    );

    // 모드별 게임 시작
    if (mode == GameMode.classic) {
      await _startClassicGame();
    } else {
      await _startAirplaneGame();
    }

    notifyListeners();
  }

  /// 답안 제출
  Future<bool> submitAnswer(int answer) async {
    if (!isGameActive || currentProblem == null) return false;

    final isCorrect = currentProblem!.isCorrectAnswer(answer);
    final answerTime = _problemStartTime != null 
        ? DateTime.now().difference(_problemStartTime!) 
        : const Duration(seconds: 5);

    if (isCorrect) {
      await _handleCorrectAnswer(answerTime);
    } else {
      await _handleWrongAnswer();
    }

    return isCorrect;
  }

  /// 비행기 이동
  void moveAirplane(double newX) {
    if (!isAirplaneMode || !isGameActive) return;
    
    _airplaneX = newX.clamp(0.0, 1.0);
    notifyListeners();
  }

  /// 비행기 좌측 이동
  void moveAirplaneLeft() {
    if (!isAirplaneMode || !isGameActive) return;
    
    _airplaneX = (_airplaneX - 0.05).clamp(0.0, 1.0);
    notifyListeners();
  }

  /// 비행기 우측 이동
  void moveAirplaneRight() {
    if (!isAirplaneMode || !isGameActive) return;
    
    _airplaneX = (_airplaneX + 0.05).clamp(0.0, 1.0);
    notifyListeners();
  }

  /// 게임 일시정지
  void pauseGame() {
    if (!isGameActive) return;
    
    _gameState = _gameState.pauseGame();
    _gameTimer?.cancel();
    _airplaneGameTimer?.cancel();
    notifyListeners();
  }

  /// 게임 재개
  void resumeGame() {
    if (_gameState.state != GameState.paused) return;
    
    _gameState = _gameState.resumeGame();
    
    if (isAirplaneMode) {
      _startAirplaneGameLoop();
    }
    
    notifyListeners();
  }

  /// 게임 종료
  void endGame() {
    _gameState = _gameState.endGame();
    _cleanupGame();
    notifyListeners();
  }

  /// 게임 리셋
  void resetGame() {
    _gameState = _gameState.resetGame();
    _cleanupGame();
    notifyListeners();
  }

  /// 새 문제 생성
  void generateNewProblem() {
    if (!isGameActive) return;

    final problem = ProblemGenerator.generateProblem(
      _gameState.selectedOperation,
      _gameState.selectedDifficulty,
    );

    _gameState = _gameState.setCurrentProblem(problem);
    _problemStartTime = DateTime.now();
    
    if (isAirplaneMode) {
      _createFallingAnswers(problem);
    }
    
    notifyListeners();
  }

  /// 게임 통계
  Map<String, dynamic> getGameStatistics() {
    return {
      'totalGames': _gameState.gameHistory.length,
      'classicHighScore': _gameState.getHighScore(GameMode.classic),
      'airplaneHighScore': _gameState.getHighScore(GameMode.airplane),
      'classicAverage': _gameState.getAverageScore(GameMode.classic),
      'airplaneAverage': _gameState.getAverageScore(GameMode.airplane),
      'totalPlays': {
        'classic': _gameState.getTotalPlays(GameMode.classic),
        'airplane': _gameState.getTotalPlays(GameMode.airplane),
      },
    };
  }

  // 내부 메서드들

  Future<void> _startClassicGame() async {
    generateNewProblem();
  }

  Future<void> _startAirplaneGame() async {
    _initializeAirplaneGame();
    generateNewProblem();
    _startAirplaneGameLoop();
  }

  void _initializeAirplaneGame() {
    _airplaneX = 0.5;
    _fallingAnswers.clear();
    _backgroundElements.clear();
    
    // 배경 요소 생성
    final random = Random();
    for (int i = 0; i < 10; i++) {
      _backgroundElements.add(BackgroundElement(
        type: ['cloud', 'bird', 'star'][random.nextInt(3)],
        x: random.nextDouble(),
        y: random.nextDouble(),
        speed: 0.005 + random.nextDouble() * 0.005,
      ));
    }
  }

  void _startAirplaneGameLoop() {
    _airplaneGameTimer = Timer.periodic(
      const Duration(milliseconds: 50),
      (timer) => _updateAirplaneGame(),
    );
  }

  void _updateAirplaneGame() {
    if (!isAirplaneMode || !isGameActive) return;

    // 떨어지는 답안 업데이트
    final answersToRemove = <FallingAnswer>[];
    
    for (final answer in _fallingAnswers) {
      answer.update();
      
      // 비행기와 충돌 확인
      if (_checkCollision(answer)) {
        // 충돌 효과 생성
        _createCollisionEffect(answer);
        
        if (answer.isCorrect) {
          // 즉시 효과 먼저 생성
          HapticFeedback.lightImpact();
          _createScorePopup(answer.x, answer.y, true);
          _startAirplaneFlash(true);
          
          // 비행기 모드에서는 즉시 동기 처리
          if (isAirplaneMode) {
            _handleCorrectAnswerSync();
          } else {
            _handleCorrectAnswer(const Duration(milliseconds: 100));
          }
        } else {
          _handleWrongAnswer();
          // 오답 시 햅틱 피드백
          HapticFeedback.heavyImpact();
          // 오답 효과
          _createScorePopup(answer.x, answer.y, false);
          // 비행기 부정적 깜빡임
          _startAirplaneFlash(false);
        }
        answersToRemove.add(answer);
      } else if (answer.isOffScreen) {
        answersToRemove.add(answer);
      }
    }
    
    // 제거할 답안들 삭제
    for (final answer in answersToRemove) {
      _fallingAnswers.remove(answer);
    }

    // 배경 요소 업데이트
    for (final element in _backgroundElements) {
      element.update();
    }

    // 충돌 효과 업데이트
    final effectsToRemove = <CollisionEffect>[];
    for (final effect in _collisionEffects) {
      effect.update();
      if (effect.isFinished) {
        effectsToRemove.add(effect);
      }
    }
    for (final effect in effectsToRemove) {
      _collisionEffects.remove(effect);
    }

    // 점수 팝업 업데이트
    final popupsToRemove = <ScorePopup>[];
    for (final popup in _scorePopups) {
      popup.update();
      if (popup.isFinished) {
        popupsToRemove.add(popup);
      }
    }
    for (final popup in popupsToRemove) {
      _scorePopups.remove(popup);
    }

    notifyListeners();
  }

  bool _checkCollision(FallingAnswer answer) {
    const airplaneWidth = 0.1;
    const airplaneHeight = 0.1;
    const answerWidth = 0.08;
    const answerHeight = 0.06;
    
    const airplaneY = 0.7; // 비행기가 화면 아래쪽에 위치
    
    return (answer.x < _airplaneX + airplaneWidth &&
            answer.x + answerWidth > _airplaneX &&
            answer.y < airplaneY + airplaneHeight &&
            answer.y + answerHeight > airplaneY);
  }

  void _createFallingAnswers(MathProblem problem) {
    _fallingAnswers.clear();
    
    final positions = [0.2, 0.5, 0.8]..shuffle();
    
    for (int i = 0; i < problem.options.length; i++) {
      _fallingAnswers.add(FallingAnswer(
        value: problem.options[i],
        isCorrect: problem.options[i] == problem.correctAnswer,
        x: positions[i],
        y: -0.3 - (i * 0.3), // 화면 위쪽에서 시작해서 시간차를 두고 떨어지게
      ));
    }
  }

  /// 충돌 효과 생성
  void _createCollisionEffect(FallingAnswer answer) {
    print('Creating collision effect at (${answer.x}, ${answer.y}) - correct: ${answer.isCorrect}');
    _collisionEffects.add(CollisionEffect(
      x: answer.x,
      y: answer.y,
      isCorrect: answer.isCorrect,
    ));
    print('Total collision effects: ${_collisionEffects.length}');
  }

  /// 점수 팝업 생성
  void _createScorePopup(double x, double y, bool isCorrect) {
    final points = isCorrect ? 
        ScoreCalculator.calculateBaseScore(
          _gameState.selectedOperation, 
          _gameState.selectedDifficulty
        ) : 0;
    
    print('Creating score popup at (${x}, ${y}) - correct: ${isCorrect}, points: ${points}');
    _scorePopups.add(ScorePopup(
      x: x,
      y: y,
      points: points,
      isCorrect: isCorrect,
      combo: _gameState.consecutiveCorrect,
    ));
    print('Total score popups: ${_scorePopups.length}');
  }

  /// 연속 정답 특별 효과 생성
  void _createComboEffect() {
    // 여러 개의 작은 폭발 효과를 랜덤 위치에 생성
    final random = Random();
    for (int i = 0; i < 5; i++) {
      _collisionEffects.add(CollisionEffect(
        x: random.nextDouble(),
        y: random.nextDouble() * 0.8,
        isCorrect: true,
      ));
    }
  }

  /// 비행기 깜빡임 효과 시작
  void _startAirplaneFlash(bool isPositive) {
    _airplaneFlashTimer?.cancel();
    _airplaneFlashing = true;
    notifyListeners();
    
    _airplaneFlashTimer = Timer(
      Duration(milliseconds: isPositive ? 300 : 500),
      () {
        _airplaneFlashing = false;
        notifyListeners();
      },
    );
  }

  Future<void> _handleCorrectAnswer(Duration answerTime) async {
    if (currentProblem == null) return;

    // 점수 계산
    final points = ScoreCalculator.calculateFinalScore(
      problem: currentProblem!,
      mode: _gameState.mode,
      answerTime: answerTime,
      consecutiveCorrect: _gameState.consecutiveCorrect,
      currentLevel: _gameState.currentLevel,
      isCorrect: true,
    );

    // 게임 상태 업데이트
    _gameState = _gameState
        .increaseScore(points, isConsecutive: true)
        .solveProblem();

    // 연속 정답 특별 효과
    if (_gameState.consecutiveCorrect >= 3) {
      // 강한 햅틱 피드백
      HapticFeedback.mediumImpact();
      // 연속 정답 특별 효과 생성 (예: 화면 전체에 반짝임)
      _createComboEffect();
    }

    // 다음 문제 생성
    if (isClassicMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      generateNewProblem();
    } else {
      // 비행기 모드에서는 즉시 진행 (UI 반응성 향상)
      generateNewProblem();
      notifyListeners(); // 즉시 UI 업데이트
    }
  }

  /// 비행기 모드 전용 즉시 정답 처리 (동기)
  void _handleCorrectAnswerSync() {
    if (currentProblem == null) return;

    // 점수 계산 (즉시)
    final points = ScoreCalculator.calculateFinalScore(
      problem: currentProblem!,
      mode: _gameState.mode,
      answerTime: const Duration(milliseconds: 100), // 빠른 반응 시간
      consecutiveCorrect: _gameState.consecutiveCorrect,
      currentLevel: _gameState.currentLevel,
      isCorrect: true,
    );

    // 게임 상태 업데이트 (즉시)
    _gameState = _gameState
        .increaseScore(points, isConsecutive: true)
        .solveProblem();

    // 연속 정답 특별 효과
    if (_gameState.consecutiveCorrect >= 3) {
      HapticFeedback.mediumImpact();
      _createComboEffect();
    }

    // 다음 프레임에서 새 문제 생성하여 동시 수정 방지
    Future.microtask(() {
      generateNewProblem();
      notifyListeners();
    });
  }

  Future<void> _handleWrongAnswer() async {
    // 연속 정답 리셋
    _gameState = _gameState.increaseScore(0, isConsecutive: false);
    
    // 클래식 모드에서는 게임 종료
    if (isClassicMode) {
      endGame();
    } else {
      // 비행기 모드에서도 게임 종료
      endGame();
    }
  }

  void _cleanupGame() {
    _gameTimer?.cancel();
    _airplaneGameTimer?.cancel();
    _airplaneFlashTimer?.cancel();
    _gameTimer = null;
    _airplaneGameTimer = null;
    _airplaneFlashTimer = null;
    _problemStartTime = null;
    _airplaneFlashing = false;
    _fallingAnswers.clear();
    _backgroundElements.clear();
    _collisionEffects.clear();
    _scorePopups.clear();
  }

  @override
  void dispose() {
    _cleanupGame();
    super.dispose();
  }
}

/// 떨어지는 답안 클래스
class FallingAnswer {
  final int value;
  final bool isCorrect;
  double x; // 가로 위치
  double y; // 세로 위치 (0.0에서 시작해서 1.0으로)
  final double speed = 0.01; // 떨어지는 속도

  FallingAnswer({
    required this.value,
    required this.isCorrect,
    required this.x,
    this.y = -0.3,
  });

  void update() => y += speed; // 아래로 떨어지도록 변경
  bool get isOffScreen => y > 1.1; // 화면 아래쪽으로 벗어났는지 확인
}

/// 배경 요소 클래스
class BackgroundElement {
  final String type; // 'cloud', 'bird', 'star'
  double x, y;
  final double speed;

  BackgroundElement({
    required this.type,
    required this.x,
    required this.y,
    required this.speed,
  });

  void update() {
    y += speed; // 아래로 떨어지도록 변경
    if (y > 1.1) { // 화면 아래쪽으로 벗어나면
      y = -0.1; // 화면 위쪽에서 다시 시작
      x = Random().nextDouble();
    }
  }
}

/// 충돌 효과 클래스
class CollisionEffect {
  final double x, y;
  final bool isCorrect;
  double progress = 0.0;
  static const double duration = 2.0; // 2초로 늘림

  CollisionEffect({
    required this.x,
    required this.y,
    required this.isCorrect,
  });

  void update() {
    progress += 1 / 60 / duration;
  }

  bool get isFinished => progress >= 1.0;
}

/// 점수 팝업 클래스
class ScorePopup {
  final double x, y;
  final int points;
  final bool isCorrect;
  final int combo;
  double progress = 0.0;
  static const double duration = 3.0; // 3초로 늘림

  ScorePopup({
    required this.x,
    required this.y,
    required this.points,
    required this.isCorrect,
    required this.combo,
  });

  void update() {
    progress += 1 / 60 / duration;
  }

  bool get isFinished => progress >= 1.0;
}
