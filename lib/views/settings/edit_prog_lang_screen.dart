import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:pfe_test/services/appwrite_service.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';

class EditProgLangScreen extends StatefulWidget {
  const EditProgLangScreen({super.key});

  @override
  State<EditProgLangScreen> createState() => _EditProgLangScreenState();
}

class _EditProgLangScreenState extends State<EditProgLangScreen> {
  List<String> items = ['Python', 'JavaScript', 'Dart', 'Java', 'C++'];
  String? selectedLanguage;
  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AppwriteService>(context, listen: false);
    selectedLanguage = authService.progress.progLanguage;
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AppwriteService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Language"),
        actions: [
          TextButton(
            onPressed: () {
              authService.updateLanguageSelected(selectedLanguage!);
              Navigator.pop(context);
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            const Text("Programming Language",
                style: TextStyle(
                    color: AppTheme.accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
            const SizedBox(height: 8),
            DropdownButton2(
              isExpanded: true,
              underline: const SizedBox(),
              hint: Text(
                selectedLanguage!,
                style: const TextStyle(color: Colors.white),
              ),
              items: items.map((lang) {
                return DropdownMenuItem<String>(
                  value: lang,
                  child: lang == selectedLanguage
                      ? Text(
                          lang,
                          style: const TextStyle(color: AppTheme.primaryColor),
                        )
                      : Text(lang),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedLanguage = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
