import 'package:flutter/material.dart';
import '../models/mission_model.dart';
import '../theme/app_theme.dart';

class OrderingChallenge extends StatefulWidget {
  final Mission mission;
  final Function(List<String>) onOrderChanged;

  const OrderingChallenge({
    super.key, 
    required this.mission, 
    required this.onOrderChanged
  });

  @override
  State<OrderingChallenge> createState() => _OrderingChallengeState();
}

class _OrderingChallengeState extends State<OrderingChallenge> {
  late List<String> _currentOrder;

  @override
  void initState() {
    super.initState();
    // Shuffle the options initially for the challenge
    _currentOrder = List.from(widget.mission.options ?? [])..shuffle();
    widget.onOrderChanged(_currentOrder);
  }

  @override
  Widget build(BuildContext context) {
    //TODO : order missions by diff 
    return ReorderableListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) newIndex -= 1;
          final item = _currentOrder.removeAt(oldIndex);
          _currentOrder.insert(newIndex, item);
          widget.onOrderChanged(_currentOrder);
        });
      },
      children: [
        for (int i = 0; i < _currentOrder.length; i++)
          Card(
            key: ValueKey(_currentOrder[i]),
            margin: const EdgeInsets.only(bottom: 8),
            color: AppTheme.cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              leading: const Icon(Icons.drag_handle, color: Colors.grey),
              title: Text(
                _currentOrder[i],
                style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
              ),
              tileColor: Colors.transparent,
            ),
          ),
      ],
    );
  }
}
