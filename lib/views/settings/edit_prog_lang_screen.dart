import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class EditProgLangScreen extends StatelessWidget {
  const EditProgLangScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Language"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              //TODO : zid el save w el load fi el database
            },
            child: const Text("SAVE",
                style: TextStyle(
                    color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 32),
            _buildEditField(context, "Programming Language", "Python"),
          ],
        ),
      ),
    );
  }

  Widget _buildEditField(
      BuildContext context, String label, String initialValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppTheme.accentColor,
                fontWeight: FontWeight.bold,
                fontSize: 12)),
        const SizedBox(height: 8),
        TextField(
          controller: TextEditingController(text: initialValue),
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}
