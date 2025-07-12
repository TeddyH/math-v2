import 'package:flutter/material.dart';
import 'package:games_services/games_services.dart';
import '../models/game_state.dart';
import '../utils/constants.dart';
import '../utils/enums.dart';
import '../widgets/animated_airplane.dart';

class GameResultScreen extends StatefulWidget {
  final GameStateModel gameState;
  final VoidCallback onPlayAgain;
  final VoidCallback onBackToSettings;

  const GameResultScreen({
    Key? key,
    required this.gameState,
    required this.onPlayAgain,
    required this.onBackToSettings,
  }) : super(key: key);

  @override
  State<GameResultScreen> createState() => _GameResultScreenState();
}

class _GameResultScreenState extends State<GameResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _showLeaderboard = false;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
    _initializeGameServices();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeGameServices() async {
    try {
      await GamesServices.signIn();
      
      final leaderboardId = widget.gameState.mode == GameMode.airplane 
          ? 'airplane_mode_leaderboard'
          : 'classic_mode_leaderboard';
      
      await GamesServices.submitScore(
        score: Score(
          androidLeaderboardID: leaderboardId,
          iOSLeaderboardID: leaderboardId,
          value: widget.gameState.currentScore,
        ),
      );
      
      setState(() {
        _showLeaderboard = true;
      });
    } catch (e) {
      print('게임 서비스 초기화 실패: $e');
    }
  }

  Future<void> _showLeaderboardDialog() async {
    if (!_showLeaderboard) return;
    
    try {
      final leaderboardId = widget.gameState.mode == GameMode.airplane 
          ? 'airplane_mode_leaderboard'
          : 'classic_mode_leaderboard';
          
      await GamesServices.showLeaderboards(
        iOSLeaderboardID: leaderboardId,
        androidLeaderboardID: leaderboardId,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('리더보드를 불러올 수 없습니다.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: _buildContent(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 비행기 아이콘
            AnimatedAirplane(
              size: 60,
              type: widget.gameState.selectedVehicle,
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // 게임 종료 타이틀
            Text(
              '게임 종료',
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // 결과 카드
            _buildResultCard(),
            
            const SizedBox(height: AppSpacing.lg),
            
            // 버튼들
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final highScore = widget.gameState.getHighScore(widget.gameState.mode);
    
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // 점수
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 28,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '${widget.gameState.currentScore}점',
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // 간단한 통계
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('정답', '${widget.gameState.problemsSolved}개', Colors.green),
                _buildStatItem('최고점수', '$highScore점', Colors.orange),
                _buildStatItem('연속정답', '${widget.gameState.consecutiveCorrect}개', Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.body1.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppTextStyles.body2.copyWith(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // 다시 플레이 버튼
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: widget.onPlayAgain,
            icon: const Icon(Icons.replay),
            label: const Text('다시 플레이'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: AppSpacing.sm),
        
        // 하단 버튼들
        Row(
          children: [
            // 리더보드 버튼
            if (_showLeaderboard) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showLeaderboardDialog,
                  icon: const Icon(Icons.leaderboard, size: 18),
                  label: const Text('랭킹'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            
            // 설정 버튼
            Expanded(
              child: OutlinedButton.icon(
                onPressed: widget.onBackToSettings,
                icon: const Icon(Icons.settings, size: 18),
                label: const Text('설정'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
