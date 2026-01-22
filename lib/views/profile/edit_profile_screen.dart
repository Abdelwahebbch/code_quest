import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("SAVE", style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Stack(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: AppTheme.primaryColor,
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: AppTheme.accentColor, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildEditField(context, "Username", "DevExplorer"),
            const SizedBox(height: 16),
            _buildEditField(context, "Email", "dev@example.com"),
            const SizedBox(height: 16),
            _buildEditField(context, "Bio", "Passionate about software engineering and AI."),
          ],
        ),
      ),
    );
  }

  Widget _buildEditField(BuildContext context, String label, String initialValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 8),
        TextField(
          controller: TextEditingController(text: initialValue),
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}
