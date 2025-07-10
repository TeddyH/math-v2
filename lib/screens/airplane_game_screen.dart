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
                        selectedColor: AppColors.accent,
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

          const SizedBox(height: AppSpacing.xl),

          // 게임 시작 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _startGame(gameProvider),
              icon: Icon(AppIcons.play),
              label: const Text(AppStrings.startGame),
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

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (node, event) => _handleKeyEvent(event, gameProvider),
      child: GestureDetector(
        onPanUpdate: (details) => _handlePanUpdate(details, gameProvider),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.gameBackground,
                Color(0xFFE3F2FD),
              ],
            ),
          ),
          child: Stack(
            children: [
              // 배경 요소들
              ..._buildBackgroundElements(gameProvider),
              
              // 게임 UI
              Column(
                children: [
                  // 상단 정보 바
                  _buildGameHeader(gameProvider, currentProblem),
                  
                  // 게임 영역
                  Expanded(
                    child: Stack(
                      children: [
                        // 떨어지는 답안들
                        ..._buildFallingAnswers(gameProvider),
                        
                        // 비행기
                        _buildAirplane(gameProvider),
                        
                        // 충돌 효과들
                        ..._buildCollisionEffects(gameProvider),
                        
                        // 점수 팝업들
                        ..._buildScorePopups(gameProvider),
                      ],
                    ),
                  ),
                  
                  // 하단 컨트롤
                  _buildGameControls(gameProvider),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameHeader(GameProvider gameProvider, dynamic currentProblem) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      color: AppColors.primary.withOpacity(0.9),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 문제 표시
            Text(
              currentProblem.displayProblem,
              style: AppTextStyles.problem.copyWith(
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            
            // 점수 정보
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildHeaderItem(
                  '점수',
                  gameProvider.currentScore.toString(),
                  Icons.star,
                ),
                _buildHeaderItem(
                  '문제',
                  gameProvider.problemsSolved.toString(),
                  Icons.quiz,
                ),
                _buildHeaderItem(
                  '연속',
                  gameProvider.gameState.consecutiveCorrect.toString(),
                  Icons.whatshot,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderItem(String label, String value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: AppColors.textLight,
          size: 16,
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          '$label: $value',
          style: AppTextStyles.body1.copyWith(
            color: AppColors.textLight,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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
    IconData icon;
    Color color;
    
    switch (type) {
      case 'cloud':
        icon = Icons.cloud;
        color = Colors.white.withOpacity(0.7);
        break;
      case 'bird':
        icon = Icons.flutter_dash;
        color = Colors.brown.withOpacity(0.6);
        break;
      case 'star':
        icon = Icons.star;
        color = Colors.yellow.withOpacity(0.6);
        break;
      default:
        icon = Icons.circle;
        color = Colors.grey.withOpacity(0.5);
    }
    
    return Icon(
      icon,
      color: color,
      size: 24,
    );
  }

  List<Widget> _buildFallingAnswers(GameProvider gameProvider) {
    return gameProvider.fallingAnswers.map((answer) {
      return Positioned(
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
      );
    }).toList();
  }

  Widget _buildAirplane(GameProvider gameProvider) {
    return Positioned(
      left: gameProvider.airplaneX * MediaQuery.of(context).size.width - 40,
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
            angle: 0, // 회전 없음 (비행기가 위쪽을 향하도록)
            child: Icon(
              AppIcons.airplane,
              size: 60,
              color: gameProvider.airplaneFlashing 
                  ? AppColors.correctAnswer
                  : AppColors.airplane,
            ),
          ),
        ),
      ),
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
            OutlinedButton.icon(
              onPressed: () => _pauseGame(gameProvider),
              icon: Icon(AppIcons.pause),
              label: const Text('일시정지'),
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

  KeyEventResult _handleKeyEvent(KeyEvent event, GameProvider gameProvider) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        gameProvider.moveAirplaneLeft();
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        gameProvider.moveAirplaneRight();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  void _handlePanUpdate(DragUpdateDetails details, GameProvider gameProvider) {
    final screenWidth = MediaQuery.of(context).size.width;
    final newX = details.globalPosition.dx / screenWidth;
    gameProvider.moveAirplane(newX);
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
      mode: GameMode.airplane,
      operation: _selectedOperation,
      difficulty: _selectedDifficulty,
    );
    
    setState(() {
      _isGameStarted = true;
    });
    
    // 키보드 포커스 설정
    _focusNode.requestFocus();
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
              _focusNode.requestFocus();
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
              AppIcons.airplane,
              size: 64,
              color: AppColors.airplane,
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

  List<Widget> _buildCollisionEffects(GameProvider gameProvider) {
    print('Building ${gameProvider.collisionEffects.length} collision effects');
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
        final scale = 1.0 + (effect.progress * 3.0); // 더 크게 확대
        final opacity = 1.0 - effect.progress;
        
        print('Rendering collision effect: progress=${effect.progress}, scale=${scale}, opacity=${opacity}');
        
        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: 80, // 더 크게
              height: 80, // 더 크게
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: effect.isCorrect 
                    ? AppColors.correctAnswer.withOpacity(0.9) // 더 진하게
                    : AppColors.wrongAnswer.withOpacity(0.9), // 더 진하게
                boxShadow: [
                  BoxShadow(
                    color: effect.isCorrect 
                        ? AppColors.correctAnswer.withOpacity(0.5)
                        : AppColors.wrongAnswer.withOpacity(0.5),
                    blurRadius: 30, // 더 강한 그림자
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                effect.isCorrect ? Icons.check : Icons.close,
                color: AppColors.textLight,
                size: 40, // 더 큰 아이콘
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildScorePopups(GameProvider gameProvider) {
    print('Building ${gameProvider.scorePopups.length} score popups');
    return gameProvider.scorePopups.map((popup) {
      return Positioned(
        left: popup.x * MediaQuery.of(context).size.width - 40,
        top: popup.y * MediaQuery.of(context).size.height - 60 - (popup.progress * 80),
        child: _buildScorePopup(popup),
      );
    }).toList();
  }

  Widget _buildScorePopup(dynamic popup) {
    return AnimatedBuilder(
      animation: AlwaysStoppedAnimation(popup.progress),
      builder: (context, child) {
        final opacity = popup.progress < 0.8 ? 1.0 : (1.0 - (popup.progress - 0.8) / 0.2);
        final scale = 0.5 + (popup.progress * 0.5);
        
        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: popup.isCorrect 
                    ? AppColors.correctAnswer 
                    : AppColors.wrongAnswer,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    popup.isCorrect ? '+${popup.points}' : '오답!',
                    style: AppTextStyles.heading3.copyWith(
                      color: AppColors.textLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (popup.isCorrect && popup.combo > 1)
                    Text(
                      '연속 ${popup.combo}회!',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textLight,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
