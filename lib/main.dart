import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/login_screen.dart';
import 'providers/user_provider.dart';
import 'providers/game_provider.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Hive 초기화
  await Hive.initFlutter();
  
  runApp(const MathTrainingApp());
}

class MathTrainingApp extends StatelessWidget {
  const MathTrainingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => GameProvider()),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'NotoSans', // 한글 폰트
          
          // AppBar 테마
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textLight,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: AppTextStyles.appBarTitle,
          ),
          
          // 버튼 테마
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textLight,
              minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
              ),
              textStyle: AppTextStyles.button,
            ),
          ),
          
          // 카드 테마
          cardTheme: CardThemeData(
            color: AppColors.cardBackground,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            ),
          ),
          
          // 입력 필드 테마
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
          ),
        ),
        home: const LoginScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
