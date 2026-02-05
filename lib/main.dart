import 'package:flutter/material.dart';
import 'package:pfe_test/views/onboarding/splash_screen.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'views/auth/login_screen.dart';
import 'services/appwrite_service.dart';
import 'views/onboarding/language_selection_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeManager()),
        ChangeNotifierProvider(create: (_) => AppwriteService()),
      ],
      child: const AITutorApp(),
    ),
  );
}

class AITutorApp extends StatelessWidget {
  const AITutorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);

    return MaterialApp(
      title: 'AI Tutor: Software Engineering',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeManager.themeMode,
      home: const SplashScreen()
    );
  }
}
