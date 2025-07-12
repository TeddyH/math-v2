import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../utils/constants.dart';
import '../utils/enums.dart';

class AirplaneGameScreen extends StatefulWidget {
  const AirplaneGameScreen({super.key});

  @override
  State<AirplaneGameScreen> createState() => _AirplaneGameScreenState();
}

class _AirplaneGameScreenState extends State<AirplaneGameScreen> {
  OperationType _selectedOperation = OperationType.addition;
  Difficulty _selectedDifficulty = Difficulty.oneDigit;
  String _selectedAirplane = AppEmojis.airplane;
  bool _isGameStarted = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('비행기 게임'),
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          if (!_isGameStarted || !gameProvider.isGameActive) {
            return _buildGameSetup(context, gameProvider);
          } else {
            return _buildGamePlay(context, gameProvider);
          }
        },
      ),
    );
  }

  Widget _buildGameSetup(BuildContext context, GameProvider gameProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          // 제목
          Text(
            '비행기 게임 설정',
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
                      return FilterChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getOperationIcon(operation),
                              size: 16,
                              color: _selectedOperation == operation 
                                  ? AppColors.textLight 
                                  : AppColors.textPrimary,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              operation.displayName,
                              style: TextStyle(
                                color: _selectedOperation == operation 
                                    ? AppColors.textLight 
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        selected: _selectedOperation == operation,
                        selectedColor: AppColors.secondary,
                        onSelected: (selected) {
                          setState(() {
                            _selectedOperation = operation;
                          });
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
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: Difficulty.values.map((difficulty) {
                      return FilterChip(
                        label: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              difficulty.displayName,
                              style: TextStyle(
                                color: _selectedDifficulty == difficulty 
                                    ? AppColors.textLight 
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _getDifficultyDescription(difficulty),
                              style: TextStyle(
                                color: _selectedDifficulty == difficulty 
                                    ? AppColors.textLight.withOpacity(0.8)
                                    : AppColors.textPrimary.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        selected: _selectedDifficulty == difficulty,
                        selectedColor: AppColors.secondary,
                        onSelected: (selected) {
                          setState(() {
                            _selectedDifficulty = difficulty;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // 비행기 선택
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '비행기 선택',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.md,
                    children: [
                      AppEmojis.airplane,
                      AppEmojis.airplane2,
                      AppEmojis.rocket,
                      AppEmojis.helicopter,
                    ].map((airplane) {
                      return FilterChip(
                        label: Text(
                          airplane,
                          style: const TextStyle(fontSize: 24),
                        ),
                        selected: _selectedAirplane == airplane,
                        selectedColor: AppColors.secondary,
                        onSelected: (selected) {
                          setState(() {
                            _selectedAirplane = airplane;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // 게임 시작 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _startGame(gameProvider),
              icon: Icon(AppIcons.play),
              label: const Text(AppStrings.startGame),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(AppSpacing.md),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGamePlay(BuildContext context, GameProvider gameProvider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.gameBackground,
            AppColors.gameBackground.withOpacity(0.8),
          ],
        ),
      ),
      child: Stack(
        children: [
          // 배경 요소들
          ..._buildBackgroundElements(gameProvider),
          
          // 게임 UI
          SafeArea(
            child: Column(
              children: [
                // 상단 정보
                _buildGameInfo(gameProvider),
                
                // 게임 영역
                Expanded(
                  child: Stack(
                    children: [
                      // 답안 블럭들
                      ..._buildFallingAnswers(gameProvider),
                      
                      // 비행기
                      _buildAirplane(gameProvider),
                      
                      // 충돌 효과
                      if (gameProvider.collisionEffects.isNotEmpty)
                        ..._buildCollisionEffects(gameProvider),
                      
                      // 점수 팝업
                      if (gameProvider.scorePopups.isNotEmpty)
                        ..._buildScorePopups(gameProvider),
                    ],
                  ),
                ),
                
                // 하단 컨트롤
                _buildGameControls(gameProvider),
              ],
            ),
          ),
          
          // 게임 오버 오버레이
          if (!gameProvider.isGameActive && gameProvider.gameState != null)
            _buildGameOverOverlay(gameProvider),
        ],
      ),
    );
  }

  Widget _buildGameInfo(GameProvider gameProvider) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      color: AppColors.primary.withOpacity(0.9),
      child: Row(
        children: [
          // 현재 문제
          if (gameProvider.currentProblem != null)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${gameProvider.currentProblem!.operand1} ${gameProvider.currentProblem!.operation.symbol} ${gameProvider.currentProblem!.operand2} = ?',
                    style: AppTextStyles.problem.copyWith(
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
          
          // 점수 표시
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(
                AppIcons.trophy,
                color: AppColors.textLight,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${gameProvider.gameState?.currentScore ?? 0}',
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBackgroundElements(GameProvider gameProvider) {
    return gameProvider.backgroundElements.map((element) {
      return Positioned(
        left: element.x * MediaQuery.of(context).size.width,
        top: element.y * MediaQuery.of(context).size.height,
        child: _buildBackgroundElement(element.type),
      );
    }).toList();
  }

  Widget _buildBackgroundElement(String type) {
    String emoji;
    
    switch (type) {
      case 'cloud':
        emoji = AppEmojis.cloud;
        break;
      case 'bird':
        emoji = AppEmojis.bird;
        break;
      case 'star':
        emoji = AppEmojis.star;
        break;
      case 'sparkles':
        emoji = AppEmojis.sparkles;
        break;
      case 'rainbow':
        emoji = AppEmojis.rainbow;
        break;
      default:
        emoji = '⚪';
    }
    
    return Text(
      emoji,
      style: TextStyle(
        fontSize: 30,
        color: Colors.white.withOpacity(0.8),
      ),
    );
  }

  List<Widget> _buildFallingAnswers(GameProvider gameProvider) {
    return gameProvider.fallingAnswers.map((answer) {
      return Stack(
        children: [
          // 답안 블럭
          Positioned(
            left: answer.x * MediaQuery.of(context).size.width - 40,
            top: answer.y * MediaQuery.of(context).size.height,
            child: Container(
              width: 80,
              height: 60,
              decoration: BoxDecoration(
                color: answer.isCorrect 
                    ? AppColors.correctAnswer 
                    : AppColors.wrongAnswer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  answer.value.toString(),
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          // 답안 블럭 충돌 영역 표시 (반투명 빨간 테두리)
          Positioned(
            left: answer.x * MediaQuery.of(context).size.width - 45,
            top: answer.y * MediaQuery.of(context).size.height - 15,
            child: Container(
              width: 90,
              height: 75,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.red.withOpacity(0.5),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildAirplane(GameProvider gameProvider) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Stack(
      children: [
        // 비행기
        Positioned(
          left: gameProvider.airplaneX * screenWidth - 40,
          bottom: 100,
          child: Container(
            width: 80,
            height: 60,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                boxShadow: gameProvider.airplaneFlashing ? [
                  BoxShadow(
                    color: AppColors.correctAnswer.withOpacity(0.6),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ] : null,
              ),
              child: Transform.rotate(
                angle: 0,
                child: Text(
                  _selectedAirplane,
                  style: TextStyle(
                    fontSize: 50,
                    color: gameProvider.airplaneFlashing 
                        ? AppColors.correctAnswer
                        : AppColors.airplane,
                  ),
                ),
              ),
            ),
          ),
        ),
        // 비행기 충돌 영역 표시 (반투명 빨간 테두리)
        Positioned(
          left: gameProvider.airplaneX * screenWidth - 50,
          bottom: 85,
          child: Container(
            width: 100,
            height: 90,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.red.withOpacity(0.5),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(45),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGameControls(GameProvider gameProvider) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      color: Colors.black.withOpacity(0.1),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // 좌측 이동 버튼
            Expanded(
              child: ElevatedButton.icon(
                onPressed: gameProvider.moveAirplaneLeft,
                icon: const Icon(Icons.arrow_left),
                label: const Text('좌측'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            
            // 일시정지 버튼
            ElevatedButton.icon(
              onPressed: gameProvider.pauseGame,
              icon: Icon(AppIcons.pause),
              label: const Text('일시정지'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            
            // 우측 이동 버튼
            Expanded(
              child: ElevatedButton.icon(
                onPressed: gameProvider.moveAirplaneRight,
                icon: const Icon(Icons.arrow_right),
                label: const Text('우측'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCollisionEffects(GameProvider gameProvider) {
    return gameProvider.collisionEffects.map((effect) {
      return Positioned(
        left: effect.x * MediaQuery.of(context).size.width - 30,
        top: effect.y * MediaQuery.of(context).size.height - 30,
        child: _buildCollisionEffect(effect),
      );
    }).toList();
  }

  Widget _buildCollisionEffect(dynamic effect) {
    return AnimatedBuilder(
      animation: AlwaysStoppedAnimation(effect.progress),
      builder: (context, child) {
        final scale = 1.0 + (effect.progress * 3.0);
        final opacity = 1.0 - effect.progress;
        
        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: effect.isCorrect 
                    ? AppColors.correctAnswer.withOpacity(0.9)
                    : AppColors.wrongAnswer.withOpacity(0.9),
                boxShadow: [
                  BoxShadow(
                    color: effect.isCorrect 
                        ? AppColors.correctAnswer.withOpacity(0.5)
                        : AppColors.wrongAnswer.withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Text(
                effect.isCorrect ? '✅' : AppEmojis.explosion,
                style: const TextStyle(
                  fontSize: 50,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildScorePopups(GameProvider gameProvider) {
    return gameProvider.scorePopups.map((popup) {
      return Positioned(
        left: popup.x * MediaQuery.of(context).size.width - 30,
        top: popup.y * MediaQuery.of(context).size.height - 30,
        child: _buildScorePopup(popup),
      );
    }).toList();
  }

  Widget _buildScorePopup(dynamic popup) {
    return AnimatedBuilder(
      animation: AlwaysStoppedAnimation(popup.progress),
      builder: (context, child) {
        final scale = 1.0 + (popup.progress * 2.0);
        final opacity = 1.0 - popup.progress;
        
        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: popup.isPositive 
                    ? AppColors.correctAnswer 
                    : AppColors.wrongAnswer,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                popup.isPositive ? '+${popup.points}' : '${popup.points}',
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.textLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGameOverOverlay(GameProvider gameProvider) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppStrings.gameOver,
              style: AppTextStyles.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Icon(
              AppIcons.airplane,
              size: 80,
              color: AppColors.airplane,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '최종 점수: ${gameProvider.gameState?.currentScore ?? 0}',
              style: AppTextStyles.heading3,
              textAlign: TextAlign.center,
            ),
            Text(
              '해결한 문제: ${gameProvider.gameState?.problemsAnswered ?? 0}',
              style: AppTextStyles.body1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isGameStarted = false;
                });
                gameProvider.resetGame();
              },
              child: const Text(AppStrings.retry),
            ),
          ],
        ),
      ),
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
        return '1~9';
      case Difficulty.twoDigit:
        return '10~99';
      case Difficulty.threeDigit:
        return '100~999';
    }
  }

  void _startGame(GameProvider gameProvider) {
    setState(() {
      _isGameStarted = true;
    });
    
    gameProvider.startAirplaneGame(
      operation: _selectedOperation,
      difficulty: _selectedDifficulty,
    );
  }
}
