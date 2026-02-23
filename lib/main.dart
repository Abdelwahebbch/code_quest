import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pfe_test/services/appwrite_cloud_functions_service.dart';
import 'package:pfe_test/services/notifications_service.dart';
import 'package:pfe_test/views/onboarding/splash_screen.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'services/appwrite_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationsService().initNotification();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeManager()),
        ChangeNotifierProvider(create: (_) => AppwriteService()),
        ChangeNotifierProvider(create: (_) => AppwritecloudfunctionsService()),
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
        scrollBehavior: const MaterialScrollBehavior()
            .copyWith(dragDevices: PointerDeviceKind.values.toSet()),
        title: 'AI Tutor: Software Engineering',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeManager.themeMode,
        home: const SplashScreen());
  }
}
