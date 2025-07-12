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
  Timer? _answerSpawnTimer; // 답안 생성 타이머
  bool _waitingForAnswers = false; // 답안 생성 대기 상태
  double _currentAnswerSpeed = 0.004; // 현재 답안 떨어지는 속도

  // Getters
  GameStateModel get gameState => _gameState;
  double get airplaneX => _airplaneX;
  bool get airplaneFlashing => _airplaneFlashing;
  bool get waitingForAnswers => _waitingForAnswers;
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
  double get currentAnswerSpeed => _currentAnswerSpeed;

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
    String? vehicle,
  }) async {
    // 게임 상태 초기화
    _gameState = _gameState.startGame(
      gameMode: mode,
      operation: operation,
      difficulty: difficulty,
      vehicle: vehicle,
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
    
    _airplaneX = (_airplaneX - 0.025).clamp(0.0, 1.0); // 이동 속도를 절반으로 줄임 (0.05 → 0.025)
    notifyListeners();
  }

  /// 비행기 우측 이동
  void moveAirplaneRight() {
    if (!isAirplaneMode || !isGameActive) return;
    
    _airplaneX = (_airplaneX + 0.025).clamp(0.0, 1.0); // 이동 속도를 절반으로 줄임 (0.05 → 0.025)
    notifyListeners();
  }

  /// 게임 일시정지
  void pauseGame() {
    if (!isGameActive) return;
    
    _gameState = _gameState.pauseGame();
    _gameTimer?.cancel();
    _airplaneGameTimer?.cancel();
    _answerSpawnTimer?.cancel();
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

  /// 게임 결과 화면에서 설정으로 돌아가기
  void backToSettings() {
    _gameState = _gameState.backToSettings();
    notifyListeners();
  }

  /// 게임 다시 시작 (같은 설정으로)
  void restartGame() {
    startGame(
      mode: _gameState.mode,
      operation: _gameState.selectedOperation,
      difficulty: _gameState.selectedDifficulty,
      vehicle: _gameState.selectedVehicle,
    );
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

    print('📝 새 문제 생성: ${problem.displayProblem} = ${problem.correctAnswer}');
    _gameState = _gameState.setCurrentProblem(problem);
    _problemStartTime = DateTime.now();
    
    if (isAirplaneMode) {
      // 비행기 모드에서는 1초 후에 답안 생성
      _waitingForAnswers = true;
      _answerSpawnTimer?.cancel();
      print('⏱️ 답안 생성 대기 시작 (1초)');
      _answerSpawnTimer = Timer(const Duration(seconds: 1), () {
        print('🎯 답안 생성 시작');
        _createFallingAnswers(problem);
        _waitingForAnswers = false;
        print('🎯 답안 생성 완료: ${problem.options}');
        notifyListeners();
      });
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
    
    // 답안 속도 초기화
    _currentAnswerSpeed = 0.004; // 시작 속도
    
    // 배경 요소 생성
    final random = Random();
    for (int i = 0; i < 10; i++) {
      _backgroundElements.add(BackgroundElement(
        type: ['cloud', 'bird', 'star'][random.nextInt(3)],
        x: random.nextDouble(),
        y: random.nextDouble(),
        speed: 0.0025 + random.nextDouble() * 0.0025, // 배경 요소 속도도 절반으로 줄임
      ));
    }
  }

  void _startAirplaneGameLoop() {
    _airplaneGameTimer = Timer.periodic(
      const Duration(milliseconds: 16), // 속도를 절반으로 줄임 (8ms → 16ms, ~60fps)
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
        // 충돌 로그 (핵심 정보만)
        print('🚀 충돌 감지! 값: ${answer.value}, 정답: ${answer.isCorrect}, 비행기위치: ${_airplaneX.toStringAsFixed(2)}, 답안위치: ${answer.x.toStringAsFixed(2)}');
        
        if (answer.isCorrect) {
          print('✅ 정답 충돌 처리 시작');
          // 간단한 효과만 - 점수 팝업과 햅틱 피드백
          HapticFeedback.lightImpact();
          _createScorePopup(answer.x, answer.y, true);
          
          // 정답 처리 후 다음 문제로 진행
          _handleCorrectAnswerSync();
          // 모든 답안 제거
          _fallingAnswers.clear();
          print('✅ 정답 처리 완료, 다음 문제 생성');
          return; // 즉시 리턴하여 다음 문제 생성
        } else {
          print('❌ 오답 충돌 처리 시작');
          _handleWrongAnswer();
          // 오답 시 햅틱 피드백
          HapticFeedback.heavyImpact();
          // 오답 효과
          _createScorePopup(answer.x, answer.y, false);
          print('❌ 오답 처리 완료, 게임 종료');
          return; // 게임 종료
        }
      } else if (answer.isOffScreen) {
        answersToRemove.add(answer);
      }
    }
    
    // 제거할 답안들 삭제
    for (final answer in answersToRemove) {
      _fallingAnswers.remove(answer);
    }

    // 모든 답안이 화면 밖으로 나가면 다음 문제 생성 (오답 처리)
    if (_fallingAnswers.isEmpty && !_waitingForAnswers && currentProblem != null) {
      print('⏰ 시간 초과 - 모든 답안이 화면 밖으로 나감');
      _handleWrongAnswer();
      return;
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
    // 충돌 감지 영역을 더욱 크게 조정하여 반응성 증대
    const airplaneWidth = 0.15;  // 0.12 -> 0.15로 증가
    const airplaneHeight = 0.15; // 0.12 -> 0.15로 증가
    const answerWidth = 0.12;    // 0.10 -> 0.12로 증가
    const answerHeight = 0.10;   // 0.08 -> 0.10으로 증가
    
    const airplaneY = 0.7; // 비행기가 화면 아래쪽에 위치
    
    // 충돌 감지 (더 관대한 조건)
    final collisionDetected = (
      answer.x + answerWidth > _airplaneX &&
      answer.x < _airplaneX + airplaneWidth &&
      answer.y + answerHeight > airplaneY &&
      answer.y < airplaneY + airplaneHeight
    );
    
    // 프레임마다 모든 답안의 위치를 로그로 출력하여 실시간 추적
    if (answer.y > 0.6) { // 비행기 근처에 올 때만 로그 출력
      print('📍 답안 위치 추적: 값=${answer.value}, 위치=(${answer.x.toStringAsFixed(3)}, ${answer.y.toStringAsFixed(3)}), 비행기=(${_airplaneX.toStringAsFixed(3)}, ${airplaneY.toStringAsFixed(3)})');
    }
    
    if (collisionDetected) {
      print('� 충돌 감지! 값: ${answer.value}, 정답: ${answer.isCorrect}');
      print('   비행기 영역: x=${_airplaneX.toStringAsFixed(3)}-${(_airplaneX + airplaneWidth).toStringAsFixed(3)}, y=${airplaneY.toStringAsFixed(3)}-${(airplaneY + airplaneHeight).toStringAsFixed(3)}');
      print('   답안 영역: x=${answer.x.toStringAsFixed(3)}-${(answer.x + answerWidth).toStringAsFixed(3)}, y=${answer.y.toStringAsFixed(3)}-${(answer.y + answerHeight).toStringAsFixed(3)}');
    }
    
    return collisionDetected;
  }

  void _createFallingAnswers(MathProblem problem) {
    _fallingAnswers.clear();
    
    // 3개의 답안을 동시에 떨어뜨리기 위해 동일한 y 위치에서 시작
    final positions = [0.2, 0.5, 0.8]..shuffle();
    
    for (int i = 0; i < problem.options.length; i++) {
      _fallingAnswers.add(FallingAnswer(
        value: problem.options[i],
        isCorrect: problem.options[i] == problem.correctAnswer,
        x: positions[i],
        y: -0.25, // 답안을 더 위에서 시작하여 플레이어가 일찍 볼 수 있도록 함
        speed: _currentAnswerSpeed, // 현재 게임 속도 사용
      ));
    }
  }

  /// 충돌 효과 생성
  void _createCollisionEffect(FallingAnswer answer) {
    _collisionEffects.add(CollisionEffect(
      x: answer.x,
      y: answer.y,
      isCorrect: answer.isCorrect,
    ));
  }

  /// 점수 팝업 생성
  void _createScorePopup(double x, double y, bool isCorrect) {
    final points = isCorrect ? 
        ScoreCalculator.calculateBaseScore(
          _gameState.selectedOperation, 
          _gameState.selectedDifficulty
        ) : 0;
    
    _scorePopups.add(ScorePopup(
      x: x,
      y: y,
      points: points,
      isCorrect: isCorrect,
      combo: _gameState.consecutiveCorrect,
    ));
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

    // 답안 속도 증가 (정답을 맞출 때마다 점진적으로 빨라짐)
    _currentAnswerSpeed = (_currentAnswerSpeed + 0.0004).clamp(0.004, 0.012); // 더 부드럽게 증가

    // 연속 정답 특별 효과
    if (_gameState.consecutiveCorrect >= 3) {
      HapticFeedback.mediumImpact();
      _createComboEffect();
    }

    // 다음 프레임에서 새 문제 생성하여 동시 수정 방지
    Future.microtask(() {
      generateNewProblem();
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
    _answerSpawnTimer?.cancel();
    _gameTimer = null;
    _airplaneGameTimer = null;
    _airplaneFlashTimer = null;
    _answerSpawnTimer = null;
    _problemStartTime = null;
    _airplaneFlashing = false;
    _waitingForAnswers = false;
    _currentAnswerSpeed = 0.004; // 속도 리셋
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
  final double speed; // 떨어지는 속도 (동적으로 변경됨)

  FallingAnswer({
    required this.value,
    required this.isCorrect,
    required this.x,
    this.y = -0.2,
    this.speed = 0.004, // 기본 속도
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
  static const double duration = 1.5; // 속도 2배 빠르게 (3초 → 1.5초)

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
