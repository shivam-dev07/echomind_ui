import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'core/auth_service.dart';
import 'core/dynamic_recording_indicator.dart';
import 'core/meeting_state.dart';
import 'core/recording_controller.dart';
import 'core/theme.dart';
import 'screens/login_screen.dart';
import 'screens/main_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize auth service
  await AuthService().init();

  runApp(const SmartMeetingApp());
}

class SmartMeetingApp extends StatelessWidget {
  const SmartMeetingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<RecordingController>(
          create: (_) => RecordingController()..init(),
        ),
        ChangeNotifierProvider<MeetingsController>(
          create: (_) => MeetingsController()..init(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'EchoMind',
        builder: (context, child) {
          return Stack(
            children: [
              if (child != null) child,
              Positioned(
                top: 10,
                left: 0,
                right: 0,
                child: Center(
                  child: DynamicRecordingIndicator(
                    onTap: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      MainLayout.globalKey.currentState?.openRecordTab();
                    },
                  ),
                ),
              ),
            ],
          );
        },
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primaryPeach,
            secondary: AppColors.secondaryBlue,
            surface: AppColors.surface,
            error: AppColors.error,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            iconTheme: const IconThemeData(color: AppColors.textPrimary),
            titleTextStyle: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
          ),
          textTheme: TextTheme(
            displayLarge: AppTypography.displayLarge,
            headlineMedium: AppTypography.headlineLarge,
            titleLarge: AppTypography.titleLarge,
            titleMedium: AppTypography.titleMedium,
            bodyLarge: AppTypography.bodyLarge,
            bodyMedium: AppTypography.bodyMedium,
            bodySmall: AppTypography.bodySmall,
          ),
          dividerTheme: const DividerThemeData(
            color: AppColors.border,
            thickness: 0.5,
            space: 0,
          ),
          snackBarTheme: SnackBarThemeData(
            backgroundColor: AppColors.surfaceElevated,
            contentTextStyle: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            behavior: SnackBarBehavior.floating,
          ),
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    
    if (authService.isAuthenticated) {
      return MainLayout(key: MainLayout.globalKey);
    } else {
      return const LoginScreen();
    }
  }
}
