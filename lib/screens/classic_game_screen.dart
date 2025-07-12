import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../utils/constants.dart';
import '../utils/enums.dart';
import 'game_result_screen.dart';

class ClassicGameScreen extends StatefulWidget {
  const ClassicGameScreen({super.key});

  @override
  State<ClassicGameScreen> createState() => _ClassicGameScreenState();
}

class _ClassicGameScreenState extends State<ClassicGameScreen> {
  OperationType _selectedOperation = OperationType.addition;
  Difficulty _selectedDifficulty = Difficulty.oneDigit;
  bool _isGameStarted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('클래식 모드'),
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          if (gameProvider.gameState.state == GameState.ended) {
            return GameResultScreen(
              gameState: gameProvider.gameState,
              onPlayAgain: () {
                gameProvider.restartGame();
              },
              onBackToSettings: () {
                gameProvider.backToSettings();
                setState(() {
                  _isGameStarted = false;
                });
              },
            );
          } else if (!_isGameStarted || !gameProvider.isGameActive) {
            return _buildGameSetup(context, gameProvider);
          } else {
            return _buildGamePlay(context, gameProvider);
          }
        },
      ),
    );
  }

  Widget _buildGameSetup(BuildContext context, GameProvider gameProvider) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          // 제목
          Text(
            '게임 설정',
            style: AppTextStyles.heading2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),

          // 연산 선택
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.selectOperation,
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: OperationType.values.map((operation) {
                      return ChoiceChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getOperationIcon(operation),
                              size: 16,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(operation.displayName),
                          ],
                        ),
                        selected: _selectedOperation == operation,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedOperation = operation;
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 난이도 선택
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.selectDifficulty,
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Column(
                    children: Difficulty.values.map((difficulty) {
                      return RadioListTile<Difficulty>(
                        title: Text(difficulty.displayName),
                        subtitle: Text(_getDifficultyDescription(difficulty)),
                        value: difficulty,
                        groupValue: _selectedDifficulty,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedDifficulty = value;
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // 게임 시작 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _startGame(gameProvider),
              child: const Text(AppStrings.startGame),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGamePlay(BuildContext context, GameProvider gameProvider) {
    final currentProblem = gameProvider.currentProblem;
    
    if (currentProblem == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          // 점수 및 문제 수 표시
          _buildScoreHeader(gameProvider),
          const SizedBox(height: AppSpacing.xl),

          // 문제 표시
          Card(
            elevation: 8,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  Text(
                    '문제',
                    style: AppTextStyles.body1,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    currentProblem.displayProblem,
                    style: AppTextStyles.problem,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // 답안 선택
          Text(
            '정답을 선택하세요',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: AppSpacing.lg),
          
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 3,
            childAspectRatio: 2,
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            children: currentProblem.options.map((option) {
              return ElevatedButton(
                onPressed: () => _submitAnswer(gameProvider, option),
                style: ElevatedButton.styleFrom(
                  textStyle: AppTextStyles.problem,
                ),
                child: Text(option.toString()),
              );
            }).toList(),
          ),
          
          const SizedBox(height: AppSpacing.xl),

          // 게임 제어 버튼
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _pauseGame(gameProvider),
                  child: const Text('일시정지'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _endGame(gameProvider),
                  child: const Text('게임 종료'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreHeader(GameProvider gameProvider) {
    return Card(
      color: AppColors.primary,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildScoreItem(
              '점수',
              gameProvider.currentScore.toString(),
              Icons.star,
            ),
            _buildScoreItem(
              '문제',
              gameProvider.problemsSolved.toString(),
              Icons.quiz,
            ),
            _buildScoreItem(
              '연속정답',
              gameProvider.gameState.consecutiveCorrect.toString(),
              Icons.whatshot,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.textLight,
          size: 20,
        ),
        Text(
          value,
          style: AppTextStyles.score.copyWith(
            color: AppColors.textLight,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.body2.copyWith(
            color: AppColors.textLight,
          ),
        ),
      ],
    );
  }

  IconData _getOperationIcon(OperationType operation) {
    switch (operation) {
      case OperationType.addition:
        return AppIcons.addition;
      case OperationType.subtraction:
        return AppIcons.subtraction;
      case OperationType.multiplication:
        return AppIcons.multiplication;
      case OperationType.division:
        return AppIcons.division;
      case OperationType.random:
        return AppIcons.random;
    }
  }

  String _getDifficultyDescription(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.oneDigit:
        return '1~9 숫자로 계산';
      case Difficulty.twoDigit:
        return '10~99 숫자로 계산';
      case Difficulty.threeDigit:
        return '100~999 숫자로 계산';
    }
  }

  void _startGame(GameProvider gameProvider) {
    gameProvider.startGame(
      mode: GameMode.classic,
      operation: _selectedOperation,
      difficulty: _selectedDifficulty,
    );
    
    setState(() {
      _isGameStarted = true;
    });
  }

  Future<void> _submitAnswer(GameProvider gameProvider, int answer) async {
    final isCorrect = await gameProvider.submitAnswer(answer);
    
    if (!mounted) return;

    if (isCorrect) {
      // 정답 피드백
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.correct),
          backgroundColor: AppColors.success,
          duration: const Duration(milliseconds: 500),
        ),
      );
    } else {
      // 오답 시 게임 종료 결과 표시
      _showGameOverDialog(gameProvider);
    }
  }

  void _pauseGame(GameProvider gameProvider) {
    gameProvider.pauseGame();
    // 일시정지 다이얼로그 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('게임 일시정지'),
        content: const Text('게임이 일시정지되었습니다.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              gameProvider.resumeGame();
            },
            child: const Text('계속하기'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _endGame(gameProvider);
            },
            child: const Text('게임 종료'),
          ),
        ],
      ),
    );
  }

  void _endGame(GameProvider gameProvider) {
    gameProvider.endGame();
    _showGameOverDialog(gameProvider);
  }

  void _showGameOverDialog(GameProvider gameProvider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          AppStrings.gameOver,
          style: AppTextStyles.heading2,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.emoji_events,
              size: 64,
              color: AppColors.warning,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '최종 점수: ${gameProvider.currentScore}점',
              style: AppTextStyles.heading3,
            ),
            Text(
              '해결한 문제: ${gameProvider.problemsSolved}개',
              style: AppTextStyles.body1,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // 게임 화면 종료
            },
            child: const Text('메뉴로'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              gameProvider.resetGame();
              setState(() {
                _isGameStarted = false;
              });
            },
            child: const Text(AppStrings.retry),
          ),
        ],
      ),
    );
  }
}
