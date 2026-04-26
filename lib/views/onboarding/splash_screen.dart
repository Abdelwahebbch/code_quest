import 'package:flutter/material.dart';
import 'package:pfe_test/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    
    super.initState();
 
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _controller.forward();

  }



  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 Image(
                  height: 170,
                  width: 170,
                  image: AssetImage('assets/icon/icon.png'),
                ),
                SizedBox(height: 8),
                Text(
                  "Master Software Engineering",
                  style: TextStyle(color: Colors.grey, letterSpacing: 1.2),
                ),
                SizedBox(height: 48),
                CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
