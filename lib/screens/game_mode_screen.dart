import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/game_provider.dart';
import '../utils/constants.dart';
import '../utils/enums.dart';
import 'classic_game_screen.dart';
import 'airplane_game_screen.dart';
import 'login_screen.dart';

class GameModeScreen extends StatefulWidget {
  const GameModeScreen({super.key});

  @override
  State<GameModeScreen> createState() => _GameModeScreenState();
}

class _GameModeScreenState extends State<GameModeScreen> {
  @override
  void initState() {
    super.initState();
    // 사용자 정보를 게임 프로바이더에 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      final gameProvider = context.read<GameProvider>();
      if (userProvider.isLoggedIn) {
        gameProvider.setUser(userProvider.currentUser!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.background, AppColors.surface],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                // 사용자 정보 표시
                _buildUserInfoCard(context),
                const SizedBox(height: AppSpacing.xl),
                
                // 게임 모드 선택 제목
                Text(
                  AppStrings.selectGameMode,
                  style: AppTextStyles.heading2,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                
                // 게임 모드 카드들
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildGameModeCard(
                          context: context,
                          mode: GameMode.classic,
                          title: AppStrings.classicMode,
                          icon: Icons.quiz,
                          color: AppColors.primary,
                          onTap: () => _navigateToClassicSetup(context),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: _buildGameModeCard(
                          context: context,
                          mode: GameMode.airplane,
                          title: AppStrings.airplaneMode,
                          icon: AppIcons.airplane,
                          color: AppColors.secondary,
                          onTap: () => _navigateToAirplaneSetup(context),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 통계 정보
                const SizedBox(height: AppSpacing.md),
                _buildStatisticsCard(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoCard(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (!userProvider.isLoggedIn) return const SizedBox();
        
        final user = userProvider.currentUser!;
        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Text(
                    user.nickname.isNotEmpty 
                        ? user.nickname[0].toUpperCase() 
                        : '?',
                    style: AppTextStyles.heading3.copyWith(
                      color: AppColors.textLight,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.nickname,
                        style: AppTextStyles.heading3,
                      ),
                      Text(
                        '${user.school} ${user.grade}학년',
                        style: AppTextStyles.body2,
                      ),
                    ],
                  ),
                ),
                Icon(
                  AppIcons.school,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGameModeCard({
    required BuildContext context,
    required GameMode mode,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 8,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.1),
                  color.withOpacity(0.2),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 48,
                  color: color,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  title,
                  style: AppTextStyles.heading3.copyWith(color: color),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
                  ),
                  child: Text(
                    '플레이하기',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.textLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ),
    );
  }

  Widget _buildStatisticsCard(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final stats = gameProvider.getGameStatistics();
        
        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Text(
                  '🏆 게임 통계',
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      '클래식 최고점',
                      '${stats['classicHighScore']}점',
                      Icons.quiz,
                    ),
                    _buildStatItem(
                      '비행기 최고점',
                      '${stats['airplaneHighScore']}점',
                      AppIcons.airplane,
                    ),
                    _buildStatItem(
                      '총 게임 수',
                      '${stats['totalGames']}회',
                      Icons.games,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.body2,
        ),
      ],
    );
  }

  void _navigateToClassicSetup(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ClassicGameScreen(),
      ),
    );
  }

  void _navigateToAirplaneSetup(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AirplaneGameScreen(),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      await context.read<UserProvider>().logout();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }
}
