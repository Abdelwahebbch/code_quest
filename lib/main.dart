import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pfe_test/services/Auth/auth_provider.dart';
import 'package:pfe_test/services/Auth/auth_repository.dart';
import 'package:pfe_test/services/Data/data_provider.dart';
import 'package:pfe_test/services/Data/data_repository.dart';
import 'package:pfe_test/services/Data/party_data_provider.dart';
import 'package:pfe_test/services/appwrite_service.dart';
import 'package:pfe_test/theme/app_theme.dart';
import 'package:pfe_test/views/auth/login_screen.dart';
import 'package:pfe_test/views/dashboard/dashboard_screen.dart';
import 'package:pfe_test/views/onboarding/splash_screen.dart';

import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final AppwriteService appwriteService = AppwriteService();

  runApp(
    MultiProvider(
      providers: [
        Provider<AppwriteService>(create: (_) => appwriteService),
        Provider<AuthRepository>(
            create: (context) => AuthRepository(
                appwriteService: context.read<AppwriteService>())),
        Provider<DataRepository>(
            create: (context) => DataRepository(
                appwriteService: context.read<AppwriteService>())),
        ChangeNotifierProvider(create: (_) => ThemeManager()),
        ChangeNotifierProvider<AuthProvider>(
            create: (context) =>
                AuthProvider(authRepository: context.read<AuthRepository>())
                  ..init()),
        ChangeNotifierProvider<DataProvider>(
            create: (context) => DataProvider(
                dataRepository: context.read<DataRepository>(),
                authProvider: context.read<AuthProvider>())
              ..init()),
        ChangeNotifierProvider<PartyDataProvider>(
            create: (context) => PartyDataProvider(
              appwriteService: context.read<AppwriteService>(),
                dataRepository: context.read<DataRepository>(),
                authProvider: context.read<AuthProvider>(),
                progress: context.read<DataProvider>().progress)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context , listen: false);
    return MaterialApp(
      scrollBehavior: const MaterialScrollBehavior()
          .copyWith(dragDevices: PointerDeviceKind.values.toSet()),
      title: 'AI Tutor: Software Engineering',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeManager.themeMode,
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          // 1. FIRST, check if Auth is loading
          if (authProvider.isLoading) {
            return const SplashScreen();
          }

          // 2. SECOND, if we have a user, check DataProvider
          else if (authProvider.currentUser != null) {
            return Consumer<DataProvider>(
              builder: (context, dataProvider, child) {
                // Now we wait for the data to load
                if (dataProvider.isLoading) {
                  // You can show the Splash screen here, or a different loading indicator
                  return const SplashScreen();
                }
                // Both Auth and Data are ready!
                return const DashboardScreen();
              },
            );
          }

          // 3. THIRD, if no user is found, go to Login
          else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
