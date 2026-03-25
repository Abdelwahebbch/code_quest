import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:pfe_test/services/appwrite_service.dart';
import 'package:pfe_test/theme/app_theme.dart';
import 'package:pfe_test/models/party_model.dart';
import 'package:provider/provider.dart';
import 'party_lobby_screen.dart';

class PartyCreateScreen extends StatefulWidget {
  final String username;
   const PartyCreateScreen({super.key, required this.username});

  @override
  State<PartyCreateScreen> createState() => _PartyCreateScreenState();
}

class _PartyCreateScreenState extends State<PartyCreateScreen> {
  final TextEditingController _partyNameController = TextEditingController();
  int _maxMembers = 4;
  String _difficulty = 'intermediate';
  String _gameMode = 'quiz';
  int _totalRounds = 5;
  bool isPublic = false;
  @override
  void initState() {
    super.initState();
    _partyNameController.text = "${widget.username}'s party";
  }

  @override
  void dispose() {
    _partyNameController.dispose();
    super.dispose();
  }

  Future<void> _createParty() async {
    final authService = Provider.of<AppwriteService>(context, listen: false);
    if (_partyNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a party name')),
      );
      return;
    }
    try {
      final mainMember = PartyMember(
        userId: authService.user!.$id,
        username: authService.user!.name,
        imageId: authService.progress.imageId,
        joinedAt: DateTime.now(),
        score: 0,
        correctAnswers: 0,
        totalAnswers: 0,
        isReady: false,
      );

      String partyID = ID.unique();
      String partyCode = authService.user!.$id.toString().substring(1, 4) +
          partyID.toString().substring(17, 20);
      final party = Party(
          partyId: partyID,
          partyCode: partyCode,
          partyName: _partyNameController.text,
          hostId: authService.user!.$id,
          hostName: authService.user!.name,
          maxMembers: _maxMembers,
          difficulty: _difficulty,
          gameMode: _gameMode,
          totalRounds: _totalRounds,
          members: [mainMember],
          isStarted: false,
          isPublic: isPublic);
      await authService.createParty(party);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PartyLobbyScreen(),
        ),
      );
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ooops error :(")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Party'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Party Name
              Text(
                'Party Name',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _partyNameController,
                decoration: InputDecoration(
                  hintText: 'Enter party name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.group),
                  filled: true,
                  fillColor: AppTheme.cardColor,
                ),
              ),
              const SizedBox(height: 30),

              // Max Members
              Text(
                'Maximum Members: $_maxMembers',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 10),
              Slider(
                value: _maxMembers.toDouble(),
                min: 2,
                max: 8,
                divisions: 6,
                label: _maxMembers.toString(),
                onChanged: (value) {
                  setState(() => _maxMembers = value.toInt());
                },
              ),
              const SizedBox(height: 30),

              // Difficulty
              Text(
                'Difficulty Level',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButton<String>(
                  value: _difficulty,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: ['beginner', 'intermediate', 'advanced']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          value.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() => _difficulty = newValue);
                    }
                  },
                ),
              ),
              const SizedBox(height: 30),

              // Game Mode
              Text(
                'Game Mode',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButton<String>(
                  value: _gameMode,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: ['quiz', 'missions', 'mixed'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          value.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() => _gameMode = newValue);
                    }
                  },
                ),
              ),
              const SizedBox(height: 30),

              // Total Rounds
              Text(
                'Total Rounds: $_totalRounds',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 10),
              Slider(
                value: _totalRounds.toDouble(),
                min: 3,
                max: 10,
                divisions: 7,
                label: _totalRounds.toString(),
                onChanged: (value) {
                  setState(() => _totalRounds = value.toInt());
                },
              ),
              const SizedBox(
                height: 10,
              ),
              SwitchListTile(
                  title: const Text("Make it public"),
                  value: isPublic,
                  onChanged: (x) {
                    setState(() {
                      isPublic = !isPublic;
                    });
                  }),
              const SizedBox(height: 40),

              // Create Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _createParty,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Create Party',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
