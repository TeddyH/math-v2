import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../utils/constants.dart';
import 'game_mode_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _schoolController = TextEditingController();
  final _nicknameController = TextEditingController();
  int _selectedGrade = 1;

  @override
  void initState() {
    super.initState();
    _loadSavedUser();
  }

  @override
  void dispose() {
    _schoolController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedUser() async {
    final userProvider = context.read<UserProvider>();
    
    // Build 완료 후 실행
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await userProvider.loadSavedUser();
      
      if (userProvider.isLoggedIn && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const GameModeScreen()),
        );
      }
    });
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final userProvider = context.read<UserProvider>();
    
    final success = await userProvider.login(
      school: _schoolController.text,
      grade: _selectedGrade,
      nickname: _nicknameController.text,
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const GameModeScreen()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('로그인에 실패했습니다. 다시 시도해주세요.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.secondary],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Card(
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 앱 로고 및 제목
                        const Icon(
                          Icons.calculate,
                          size: 64,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          AppStrings.appName,
                          style: AppTextStyles.heading1.copyWith(
                            color: AppColors.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        
                        // 부제목
                        Text(
                          AppStrings.loginTitle,
                          style: AppTextStyles.heading3,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // 학교명 입력
                        TextFormField(
                          controller: _schoolController,
                          decoration: InputDecoration(
                            labelText: '학교명',
                            hintText: AppStrings.schoolHint,
                            prefixIcon: const Icon(AppIcons.school),
                          ),
                          validator: context.read<UserProvider>().validateSchool,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // 학년 선택
                        DropdownButtonFormField<int>(
                          value: _selectedGrade,
                          decoration: const InputDecoration(
                            labelText: '학년',
                            prefixIcon: Icon(AppIcons.grade),
                          ),
                          items: context.read<UserProvider>().availableGrades
                              .map((grade) => DropdownMenuItem(
                                    value: grade,
                                    child: Text('$grade학년'),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedGrade = value ?? 1;
                            });
                          },
                          validator: (value) => context
                              .read<UserProvider>()
                              .validateGrade(value),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // 이름(별명) 입력
                        TextFormField(
                          controller: _nicknameController,
                          decoration: InputDecoration(
                            labelText: '이름(별명)',
                            hintText: AppStrings.nicknameHint,
                            prefixIcon: const Icon(AppIcons.person),
                          ),
                          validator: context.read<UserProvider>().validateNickname,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleLogin(),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // 로그인 버튼
                        Consumer<UserProvider>(
                          builder: (context, userProvider, child) {
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: userProvider.isLoading 
                                    ? null 
                                    : _handleLogin,
                                child: userProvider.isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            AppColors.textLight,
                                          ),
                                        ),
                                      )
                                    : const Text(AppStrings.loginButton),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // 안내 텍스트
                        Text(
                          '입력하신 정보는 게임 진행과 랭킹에만 사용됩니다.',
                          style: AppTextStyles.body2,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
