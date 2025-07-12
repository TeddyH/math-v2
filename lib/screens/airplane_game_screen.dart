import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../utils/constants.dart';
import '../utils/enums.dart';
import '../widgets/animated_airplane.dart';
import 'game_result_screen.dart';

class AirplaneGameScreen extends StatefulWidget {
  const AirplaneGameScreen({super.key});

  @override
  State<AirplaneGameScreen> createState() => _AirplaneGameScreenState();
}

class _AirplaneGameScreenState extends State<AirplaneGameScreen> {
  OperationType _selectedOperation = OperationType.addition;
  Difficulty _selectedDifficulty = Difficulty.oneDigit;
  String _selectedAirplane = 'airplane'; // 'airplane', 'rocket', 'helicopter'
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: OperationType.values.map((operation) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedOperation = operation;
                          });
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _selectedOperation == operation 
                                ? AppColors.secondary 
                                : Colors.transparent,
                          ),
                          child: Center(
                            child: operation == OperationType.random 
                                ? Text(
                                    '랜덤',
                                    style: TextStyle(
                                      color: _selectedOperation == operation 
                                          ? AppColors.textLight
                                          : AppColors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : Icon(
                                    _getOperationIcon(operation),
                                    size: 28,
                                    color: _selectedOperation == operation 
                                        ? AppColors.textLight
                                        : AppColors.textPrimary,
                                  ),
                          ),
                        ),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: Difficulty.values.map((difficulty) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDifficulty = difficulty;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: _selectedDifficulty == difficulty 
                                ? AppColors.secondary 
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _getDifficultyDescription(difficulty),
                            style: TextStyle(
                              color: _selectedDifficulty == difficulty 
                                  ? AppColors.textLight 
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      'airplane',
                      'rocket',
                      'helicopter',
                    ].map((vehicleType) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedAirplane = vehicleType;
                          });
                        },
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _selectedAirplane == vehicleType 
                                ? AppColors.secondary.withOpacity(0.3) 
                                : Colors.transparent,
                            border: Border.all(
                              color: _selectedAirplane == vehicleType
                                  ? AppColors.secondary
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: AnimatedAirplane(
                              type: vehicleType,
                              size: 60,
                              normalColor: _selectedAirplane == vehicleType 
                                  ? AppColors.secondary 
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
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
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (KeyEvent event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            gameProvider.moveAirplaneLeft();
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            gameProvider.moveAirplaneRight();
          } else if (event.logicalKey == LogicalKeyboardKey.space) {
            _pauseGame(gameProvider);
          }
        }
      },
      child: GestureDetector(
        onTap: () {
          // 게임 영역 외부 탭으로 일시정지
          _pauseGame(gameProvider);
        },
        child: Container(
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
          child: SafeArea(
            child: Column(
              children: [
                // 상단 정보
                _buildGameInfo(gameProvider),
                
                // 게임 영역 (전체 화면 사용)
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return GestureDetector(
                        onPanUpdate: (details) {
                          // 게임 영역 내에서만 터치 드래그 제어
                          final gameAreaWidth = constraints.maxWidth;
                          final localX = details.localPosition.dx;
                          
                          // 게임 영역 너비 기준으로 0.0 ~ 1.0 비율로 변환
                          final normalizedX = (localX / gameAreaWidth).clamp(0.0, 1.0);
                          gameProvider.moveAirplane(normalizedX);
                        },
                        onPanStart: (details) {
                          // 드래그 시작 시에도 즉시 위치 동기화
                          final gameAreaWidth = constraints.maxWidth;
                          final localX = details.localPosition.dx;
                          
                          final normalizedX = (localX / gameAreaWidth).clamp(0.0, 1.0);
                          gameProvider.moveAirplane(normalizedX);
                        },
                        onTapDown: (details) {
                          // 탭 시에도 비행기 위치 이동
                          final gameAreaWidth = constraints.maxWidth;
                          final localX = details.localPosition.dx;
                          
                          final normalizedX = (localX / gameAreaWidth).clamp(0.0, 1.0);
                          gameProvider.moveAirplane(normalizedX);
                        },
                        child: Stack(
                          children: [
                            // 배경 요소들
                            ..._buildBackgroundElements(gameProvider, constraints),
                            
                            // 답안 블럭들
                            ..._buildFallingAnswers(gameProvider, constraints),
                            
                            // 비행기
                            _buildAirplane(gameProvider, constraints),
                            
                            // 충돌 효과 제거 - 너무 정신없어서 제거
                            // if (gameProvider.collisionEffects.isNotEmpty)
                            //   ..._buildCollisionEffects(gameProvider, constraints),
                            
                            // 점수 팝업
                            if (gameProvider.scorePopups.isNotEmpty)
                              ..._buildScorePopups(gameProvider, constraints),
                            
                            // 게임 오버 오버레이
                            if (!gameProvider.isGameActive && gameProvider.gameState != null)
                              Positioned.fill(
                                child: _buildGameOverOverlay(gameProvider),
                              ),
                            
                            // 조작 안내 텍스트
                            Positioned(
                              bottom: 20,
                              left: 20,
                              right: 20,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md, 
                                  vertical: AppSpacing.sm
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '← → 키보드 또는 터치로 이동 | 스페이스바나 상단 탭으로 일시정지',
                                  style: AppTextStyles.body2.copyWith(
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
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

  List<Widget> _buildBackgroundElements(GameProvider gameProvider, BoxConstraints constraints) {
    return gameProvider.backgroundElements.map((element) {
      return Positioned(
        left: element.x * constraints.maxWidth,
        top: element.y * constraints.maxHeight,
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

  List<Widget> _buildFallingAnswers(GameProvider gameProvider, BoxConstraints constraints) {
    return gameProvider.fallingAnswers.map((answer) {
      return Stack(
        children: [
          // 답안 블럭
          Positioned(
            left: answer.x * constraints.maxWidth - 40,
            top: answer.y * constraints.maxHeight,
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
          // 답안 블럭 충돌 영역 표시 제거 (시각적 깔끔함을 위해)
          // Positioned(
          //   left: answer.x * constraints.maxWidth - 45,
          //   top: answer.y * constraints.maxHeight - 15,
          //   child: Container(
          //     width: 90,
          //     height: 75,
          //     decoration: BoxDecoration(
          //       border: Border.all(
          //         color: Colors.red.withOpacity(0.5),
          //         width: 2,
          //       ),
          //       borderRadius: BorderRadius.circular(8),
          //     ),
          //   ),
          // ),
        ],
      );
    }).toList();
  }

  Widget _buildAirplane(GameProvider gameProvider, BoxConstraints constraints) {
    return Stack(
      children: [
        // 비행기
        Positioned(
          left: gameProvider.airplaneX * constraints.maxWidth - 40,
          bottom: 100,
          child: AnimatedAirplane(
            type: _selectedAirplane,
            size: 80,
            isFlashing: false, // 깜빡임 효과 제거
            flashingColor: AppColors.correctAnswer,
            normalColor: AppColors.airplane,
          ),
        ),
        // 비행기 충돌 영역 표시 제거 (시각적 깔끔함을 위해)
        // Positioned(
        //   left: gameProvider.airplaneX * constraints.maxWidth - 50,
        //   bottom: 85,
        //   child: Container(
        //     width: 100,
        //     height: 90,
        //     decoration: BoxDecoration(
        //       border: Border.all(
        //         color: Colors.red.withOpacity(0.5),
        //         width: 2,
        //       ),
        //       borderRadius: BorderRadius.circular(45),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  List<Widget> _buildCollisionEffects(GameProvider gameProvider, BoxConstraints constraints) {
    return gameProvider.collisionEffects.map((effect) {
      return Positioned(
        left: effect.x * constraints.maxWidth - 30,
        top: effect.y * constraints.maxHeight - 30,
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

  List<Widget> _buildScorePopups(GameProvider gameProvider, BoxConstraints constraints) {
    return gameProvider.scorePopups.map((popup) {
      return Positioned(
        left: popup.x * constraints.maxWidth - 30,
        top: popup.y * constraints.maxHeight - 30,
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
            child: Text(
              popup.points > 0 ? '+${popup.points}' : '${popup.points}',
              style: AppTextStyles.heading2.copyWith(
                color: popup.points > 0 
                    ? Colors.green[600] 
                    : Colors.red[600],
                fontWeight: FontWeight.bold,
                fontSize: 28,
                shadows: [
                  // 텍스트 그림자로 가독성 확보
                  Shadow(
                    color: Colors.white,
                    blurRadius: 4,
                    offset: const Offset(0, 0),
                  ),
                  Shadow(
                    color: Colors.white,
                    blurRadius: 8,
                    offset: const Offset(0, 0),
                  ),
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 2,
                    offset: const Offset(1, 1),
                  ),
                ],
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
              '해결한 문제: ${gameProvider.gameState?.problemsSolved ?? 0}',
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
        return '한자리';
      case Difficulty.twoDigit:
        return '두자리';
      case Difficulty.threeDigit:
        return '세자리';
    }
  }

  void _startGame(GameProvider gameProvider) {
    setState(() {
      _isGameStarted = true;
    });
    
    gameProvider.startGame(
      operation: _selectedOperation,
      difficulty: _selectedDifficulty,
      mode: GameMode.airplane,
      vehicle: _selectedAirplane,
    );
  }

  void _pauseGame(GameProvider gameProvider) {
    gameProvider.pauseGame();
    
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
              setState(() {
                _isGameStarted = false;
              });
              gameProvider.resetGame();
            },
            child: const Text('게임 종료'),
          ),
        ],
      ),
    );
  }
}
