import 'package:flutter/material.dart';
import 'package:pfe_test/services/appwrite_service.dart';
import 'package:pfe_test/views/settings/edit_prog_lang_screen.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';
import '../profile/edit_profile_screen.dart';
import 'support_screens.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _selectedDifficulty = 'Intermediate';

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AppwriteService>(context, listen: true);
    final themeManager = Provider.of<ThemeManager>(context);

    final isDark = themeManager.themeMode == ThemeMode.dark;
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(
            height: 40,
          ),
          const Text(
            "Settings",
            style: TextStyle(
                color: Colors.white, fontSize: 21, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 16,
          ),
          _buildSectionHeader("Account"),
          _buildSettingTile(
            icon: Icons.person_outline,
            title: "Edit Profile",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const EditProfileScreen()),
              );
            },
          ),
          _buildSettingTile(
            icon: Icons.language,
            title: "Change Learning Language",
            subtitle: "Current: ${authService.progress.progLanguage}",
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const EditProgLangScreen()));
            },
          ),
          const SizedBox(height: 24),
          _buildSectionHeader("Preferences"),
          SwitchListTile(
            title: const Text("Push Notifications"),
            subtitle: const Text("Get mission reminders"),
            value: _notificationsEnabled,
            activeTrackColor: AppTheme.primaryColor,
            onChanged: (val) => setState(() => _notificationsEnabled = val),
          ),
          SwitchListTile(
            title: const Text("Dark Mode"),
            value: isDark,
            activeTrackColor: AppTheme.primaryColor,
            onChanged: (val) => themeManager.toggleTheme(val),
          ),
          ListTile(
            title: const Text("AI Tutor Difficulty"),
            subtitle: Text(_selectedDifficulty),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showDifficultyPicker,
          ),
          const SizedBox(height: 24),
          _buildSectionHeader("Support"),
          _buildSettingTile(
            icon: Icons.help_outline,
            title: "Help Center",
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const HelpCenterScreen()));
            },
          ),
          _buildSettingTile(
            icon: Icons.privacy_tip_outlined,
            title: "Privacy Policy",
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PrivacyPolicyScreen()));
            },
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () async {
              await authService.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                    (route) => false);
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withValues(alpha: 0.8)),
            child: const Text("LOGOUT"),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text("Version 1.0.0",
                style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(
            color: AppTheme.accentColor,
            fontWeight: FontWeight.bold,
            fontSize: 12),
      ),
    );
  }

  Widget _buildSettingTile(
      {required IconData icon,
      required String title,
      String? subtitle,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(color: Colors.grey))
          : null,
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }

  void _showDifficultyPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: ['Beginner', 'Intermediate', 'Advanced']
            .map((level) => ListTile(
                  title: Text(level),
                  onTap: () {
                    setState(() => _selectedDifficulty = level);
                    Navigator.pop(context);
                  },
                ))
            .toList(),
      ),
    );
  }
}
