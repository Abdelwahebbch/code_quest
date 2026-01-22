import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'login_screen.dart';
import '../onboarding/language_selection_screen.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.psychology, size: 80, color: AppTheme.primaryColor),
            const SizedBox(height: 16),
            Text(
              "Create Account",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            _buildTextField(context, "Full Name", Icons.person_outline),
            const SizedBox(height: 16),
            _buildTextField(context, "Email", Icons.email_outlined),
            const SizedBox(height: 16),
            _buildTextField(context, "Password", Icons.lock_outline, obscure: true),
            const SizedBox(height: 16),
            _buildTextField(context, "Confirm Password", Icons.lock_reset, obscure: true),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LanguageSelectionScreen()),
                );
              },
              child: const Text("SIGN UP"),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account?"),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Login"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(BuildContext context, String hint, IconData icon, {bool obscure = false}) {
    return TextField(
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
