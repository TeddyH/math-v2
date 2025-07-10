import 'package:equatable/equatable.dart';
import 'user_info.dart';
import '../utils/enums.dart';

class GameScore extends Equatable {
  final UserInfo user;
  final int score;
  final GameMode mode;
  final DateTime timestamp;
  final int problemsSolved;
  final OperationType operationType;
  final Difficulty difficulty;
  final int consecutiveCorrect;

  const GameScore({
    required this.user,
    required this.score,
    required this.mode,
    required this.timestamp,
    required this.problemsSolved,
    required this.operationType,
    required this.difficulty,
    this.consecutiveCorrect = 0,
  });

  /// 리더보드용 데이터로 변환
  Map<String, dynamic> toLeaderboardData() => {
        'school': user.school,
        'grade': user.grade,
        'nickname': user.nickname,
        'score': score,
        'mode': mode.name,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'problemsSolved': problemsSolved,
        'operationType': operationType.name,
        'difficulty': difficulty.name,
      };

  /// JSON으로 변환
  Map<String, dynamic> toJson() => {
        'user': user.toJson(),
        'score': score,
        'mode': mode.name,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'problemsSolved': problemsSolved,
        'operationType': operationType.name,
        'difficulty': difficulty.name,
        'consecutiveCorrect': consecutiveCorrect,
      };

  /// JSON에서 객체 생성
  factory GameScore.fromJson(Map<String, dynamic> json) {
    return GameScore(
      user: UserInfo.fromJson(json['user']),
      score: json['score'],
      mode: GameMode.values.firstWhere((e) => e.name == json['mode']),
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      problemsSolved: json['problemsSolved'],
      operationType: OperationType.values.firstWhere(
        (e) => e.name == json['operationType'],
      ),
      difficulty: Difficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
      ),
      consecutiveCorrect: json['consecutiveCorrect'] ?? 0,
    );
  }

  /// 복사본 생성
  GameScore copyWith({
    UserInfo? user,
    int? score,
    GameMode? mode,
    DateTime? timestamp,
    int? problemsSolved,
    OperationType? operationType,
    Difficulty? difficulty,
    int? consecutiveCorrect,
  }) {
    return GameScore(
      user: user ?? this.user,
      score: score ?? this.score,
      mode: mode ?? this.mode,
      timestamp: timestamp ?? this.timestamp,
      problemsSolved: problemsSolved ?? this.problemsSolved,
      operationType: operationType ?? this.operationType,
      difficulty: difficulty ?? this.difficulty,
      consecutiveCorrect: consecutiveCorrect ?? this.consecutiveCorrect,
    );
  }

  /// 점수 증가
  GameScore increaseScore(int points, {bool isConsecutive = false}) {
    return copyWith(
      score: score + points,
      consecutiveCorrect: isConsecutive ? consecutiveCorrect + 1 : 0,
    );
  }

  /// 문제 수 증가
  GameScore increaseProblemCount() {
    return copyWith(problemsSolved: problemsSolved + 1);
  }

  /// 평균 점수 (문제당)
  double get averageScore {
    return problemsSolved > 0 ? score / problemsSolved : 0.0;
  }

  /// 게임 정보 요약
  String get summary {
    return '${mode.displayName} - ${operationType.displayName}(${difficulty.displayName}) - $score점';
  }

  @override
  List<Object?> get props => [
        user,
        score,
        mode,
        timestamp,
        problemsSolved,
        operationType,
        difficulty,
        consecutiveCorrect,
      ];

  @override
  String toString() => 'GameScore(score: $score, problems: $problemsSolved, mode: $mode)';
}

/// 리더보드 엔트리
class LeaderboardEntry extends Equatable {
  final String school;
  final int grade;
  final String nickname;
  final int score;
  final GameMode mode;
  final DateTime timestamp;
  final int rank;

  const LeaderboardEntry({
    required this.school,
    required this.grade,
    required this.nickname,
    required this.score,
    required this.mode,
    required this.timestamp,
    this.rank = 0,
  });

  /// GameScore에서 생성
  factory LeaderboardEntry.fromGameScore(GameScore gameScore, {int rank = 0}) {
    return LeaderboardEntry(
      school: gameScore.user.school,
      grade: gameScore.user.grade,
      nickname: gameScore.user.nickname,
      score: gameScore.score,
      mode: gameScore.mode,
      timestamp: gameScore.timestamp,
      rank: rank,
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() => {
        'school': school,
        'grade': grade,
        'nickname': nickname,
        'score': score,
        'mode': mode.name,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'rank': rank,
      };

  /// JSON에서 객체 생성
  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      school: json['school'],
      grade: json['grade'],
      nickname: json['nickname'],
      score: json['score'],
      mode: GameMode.values.firstWhere((e) => e.name == json['mode']),
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      rank: json['rank'] ?? 0,
    );
  }

  /// 사용자 정보 표시
  String get userDisplay => '$school $grade학년 $nickname';

  @override
  List<Object?> get props => [
        school,
        grade,
        nickname,
        score,
        mode,
        timestamp,
        rank,
      ];

  @override
  String toString() => 'LeaderboardEntry(rank: $rank, user: $userDisplay, score: $score)';
}
