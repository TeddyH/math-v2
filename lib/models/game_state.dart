import 'package:equatable/equatable.dart';
import 'user_info.dart';
import 'math_problem.dart';
import 'score.dart';
import '../utils/enums.dart';

class GameStateModel extends Equatable {
  final UserInfo? user;
  final int currentScore;
  final int currentLevel;
  final bool isGameActive;
  final GameMode mode;
  final GameState state;
  final MathProblem? currentProblem;
  final int problemsSolved;
  final int consecutiveCorrect;
  final OperationType selectedOperation;
  final Difficulty selectedDifficulty;
  final List<GameScore> gameHistory;

  const GameStateModel({
    this.user,
    this.currentScore = 0,
    this.currentLevel = 1,
    this.isGameActive = false,
    this.mode = GameMode.classic,
    this.state = GameState.waiting,
    this.currentProblem,
    this.problemsSolved = 0,
    this.consecutiveCorrect = 0,
    this.selectedOperation = OperationType.addition,
    this.selectedDifficulty = Difficulty.oneDigit,
    this.gameHistory = const [],
  });

  /// 복사본 생성
  GameStateModel copyWith({
    UserInfo? user,
    int? currentScore,
    int? currentLevel,
    bool? isGameActive,
    GameMode? mode,
    GameState? state,
    MathProblem? currentProblem,
    int? problemsSolved,
    int? consecutiveCorrect,
    OperationType? selectedOperation,
    Difficulty? selectedDifficulty,
    List<GameScore>? gameHistory,
  }) {
    return GameStateModel(
      user: user ?? this.user,
      currentScore: currentScore ?? this.currentScore,
      currentLevel: currentLevel ?? this.currentLevel,
      isGameActive: isGameActive ?? this.isGameActive,
      mode: mode ?? this.mode,
      state: state ?? this.state,
      currentProblem: currentProblem ?? this.currentProblem,
      problemsSolved: problemsSolved ?? this.problemsSolved,
      consecutiveCorrect: consecutiveCorrect ?? this.consecutiveCorrect,
      selectedOperation: selectedOperation ?? this.selectedOperation,
      selectedDifficulty: selectedDifficulty ?? this.selectedDifficulty,
      gameHistory: gameHistory ?? this.gameHistory,
    );
  }

  /// 게임 시작
  GameStateModel startGame({
    required GameMode gameMode,
    required OperationType operation,
    required Difficulty difficulty,
  }) {
    return copyWith(
      mode: gameMode,
      selectedOperation: operation,
      selectedDifficulty: difficulty,
      state: GameState.playing,
      isGameActive: true,
      currentScore: 0,
      problemsSolved: 0,
      consecutiveCorrect: 0,
      currentLevel: 1,
    );
  }

  /// 게임 종료
  GameStateModel endGame() {
    final gameScore = GameScore(
      user: user!,
      score: currentScore,
      mode: mode,
      timestamp: DateTime.now(),
      problemsSolved: problemsSolved,
      operationType: selectedOperation,
      difficulty: selectedDifficulty,
      consecutiveCorrect: consecutiveCorrect,
    );

    return copyWith(
      state: GameState.gameOver,
      isGameActive: false,
      gameHistory: [...gameHistory, gameScore],
    );
  }

  /// 점수 증가
  GameStateModel increaseScore(int points, {bool isConsecutive = false}) {
    return copyWith(
      currentScore: currentScore + points,
      consecutiveCorrect: isConsecutive ? consecutiveCorrect + 1 : 0,
    );
  }

  /// 문제 해결
  GameStateModel solveProblem() {
    return copyWith(
      problemsSolved: problemsSolved + 1,
    );
  }

  /// 새 문제 설정
  GameStateModel setCurrentProblem(MathProblem problem) {
    return copyWith(currentProblem: problem);
  }

  /// 게임 일시정지
  GameStateModel pauseGame() {
    return copyWith(
      state: GameState.paused,
      isGameActive: false,
    );
  }

  /// 게임 재개
  GameStateModel resumeGame() {
    return copyWith(
      state: GameState.playing,
      isGameActive: true,
    );
  }

  /// 게임 초기화
  GameStateModel resetGame() {
    return copyWith(
      currentScore: 0,
      currentLevel: 1,
      isGameActive: false,
      state: GameState.waiting,
      currentProblem: null,
      problemsSolved: 0,
      consecutiveCorrect: 0,
    );
  }

  /// 사용자 설정
  GameStateModel setUser(UserInfo userInfo) {
    return copyWith(user: userInfo);
  }

  /// 최고 점수 (모드별)
  int getHighScore(GameMode gameMode) {
    final modeScores = gameHistory
        .where((score) => score.mode == gameMode)
        .map((score) => score.score);
    
    return modeScores.isEmpty ? 0 : modeScores.reduce((a, b) => a > b ? a : b);
  }

  /// 평균 점수 (모드별)
  double getAverageScore(GameMode gameMode) {
    final modeScores = gameHistory
        .where((score) => score.mode == gameMode)
        .map((score) => score.score);
    
    if (modeScores.isEmpty) return 0.0;
    
    final sum = modeScores.reduce((a, b) => a + b);
    return sum / modeScores.length;
  }

  /// 총 플레이 횟수 (모드별)
  int getTotalPlays(GameMode gameMode) {
    return gameHistory.where((score) => score.mode == gameMode).length;
  }

  /// 게임 통계 요약
  String get statisticsSummary {
    final classicPlays = getTotalPlays(GameMode.classic);
    final airplanePlays = getTotalPlays(GameMode.airplane);
    final classicHigh = getHighScore(GameMode.classic);
    final airplaneHigh = getHighScore(GameMode.airplane);
    
    return '클래식: ${classicPlays}회 (최고 ${classicHigh}점), 비행기: ${airplanePlays}회 (최고 ${airplaneHigh}점)';
  }

  /// 현재 게임 진행률
  double get gameProgress {
    if (!isGameActive || problemsSolved == 0) return 0.0;
    return (problemsSolved / 100.0).clamp(0.0, 1.0); // 최대 100문제 기준
  }

  @override
  List<Object?> get props => [
        user,
        currentScore,
        currentLevel,
        isGameActive,
        mode,
        state,
        currentProblem,
        problemsSolved,
        consecutiveCorrect,
        selectedOperation,
        selectedDifficulty,
        gameHistory,
      ];

  @override
  String toString() =>
      'GameStateModel(score: $currentScore, problems: $problemsSolved, state: $state)';
}
