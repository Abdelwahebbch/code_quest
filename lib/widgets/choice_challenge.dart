import 'package:flutter/material.dart';
import '../models/mission_model.dart';
import '../theme/app_theme.dart';

class ChoiceChallenge extends StatefulWidget {
  final Mission mission;
  final Function(dynamic) onAnswerChanged;

  const ChoiceChallenge(
      {super.key, required this.mission, required this.onAnswerChanged});

  @override
  State<ChoiceChallenge> createState() => _ChoiceChallengeState();
}

class _ChoiceChallengeState extends State<ChoiceChallenge> {
  final List<String> _selectedOptions = [];
  String? _selectedSingleOption;

  @override
  Widget build(BuildContext context) {
    final options = widget.mission.options ?? [];
    final isMultiple = widget.mission.type == MissionType.multipleChoice;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index];
        final isSelected = isMultiple
            ? _selectedOptions.contains(option)
            : _selectedSingleOption == option;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: InkWell(
            onTap: () => _handleTap(option, isMultiple),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryColor.withValues(alpha: 0.2)
                    : AppTheme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : Colors.grey.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isMultiple
                        ? (isSelected
                            ? Icons.check_box
                            : Icons.check_box_outline_blank)
                        : (isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off),
                    color: isSelected ? AppTheme.primaryColor : Colors.grey,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleTap(String option, bool isMultiple) {
    setState(() {
      if (isMultiple) {
        if (_selectedOptions.contains(option)) {
          _selectedOptions.remove(option);
        } else {
          _selectedOptions.add(option);
        }
        widget.onAnswerChanged(_selectedOptions);
      } else {
        _selectedSingleOption = option;
        widget.onAnswerChanged(_selectedSingleOption);
      }
    });
  }
}
