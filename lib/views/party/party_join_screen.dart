import 'package:flutter/material.dart';
import 'package:pfe_test/services/appwrite_service.dart';
import 'package:pfe_test/theme/app_theme.dart';
import 'package:pfe_test/models/party_model.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'party_lobby_screen.dart';

class PartyJoinScreen extends StatefulWidget {
  const PartyJoinScreen({super.key});

  @override
  State<PartyJoinScreen> createState() => _PartyJoinScreenState();
}

class _PartyJoinScreenState extends State<PartyJoinScreen> {
  String code = "";
  bool _isLoading = false;

  // Mock available parties deleteted
  final List<Party> _availableParties = [
    Party(
      partyId: '1',
      partyName: 'Python Masters',
      hostId: 'host1',
      hostName: 'John Doe',
      maxMembers: 6,
      difficulty: 'intermediate',
      gameMode: 'quiz',
      members: [
        PartyMember(
          userId: 'host1',
          username: 'John Doe',
          imageId: '',
          joinedAt: DateTime.now(),
        ),
        PartyMember(
          userId: 'user2',
          username: 'Jane Smith',
          imageId: '',
          joinedAt: DateTime.now(),
        ),
      ],
      partyCode: 'Abcd12',
    ),
    Party(
      partyId: '2',
      partyName: 'JavaScript Challenge',
      hostId: 'host2',
      hostName: 'Alice Johnson',
      maxMembers: 4,
      difficulty: 'advanced',
      gameMode: 'missions',
      members: [
        PartyMember(
          userId: 'host2',
          username: 'Alice Johnson',
          imageId: '',
          joinedAt: DateTime.now(),
        ),
      ],
      partyCode: 'zadzafd',
    ),
  ];

  void _joinPartyWithCode() {
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a party code')),
      );
      return;
    }
    final authService = Provider.of<AppwriteService>(context, listen: false);
    setState(() => _isLoading = true);

    Future.delayed(const Duration(seconds: 1), () async {
      setState(() => _isLoading = false);
      try {
        String rowId = await authService.joinParty(code);
        if (rowId.contains("Party is Full")) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Party is Full'),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PartyLobbyScreen(),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        print("Erreur fi join with code : $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Party not found !'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _joinPartyDirect(Party party) {
    if (party.isFull) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This party is full')),
      );
      return;
    }
  }

  @override
  void dispose() {
    code = "";
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Party'),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Join with Code Section
              Text(
                'Join with Code',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 15),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: PinCodeTextField(
                  appContext: context,
                  length: 6,
                  keyboardType: TextInputType.text,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  textStyle: const TextStyle(color: Colors.white),
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(8),
                    fieldHeight: 40,
                    fieldWidth: 40,
                    inactiveColor: Colors.grey,
                    activeColor: Colors.grey,
                  ),
                  onChanged: (value) {
                    code = value;
                  },
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _joinPartyWithCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Join Party',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 40),

              // Available Parties Section deleted
              Text(
                'Available Parties',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 15),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _availableParties.length,
                itemBuilder: (context, index) {
                  final party = _availableParties[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      party.partyName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Host: ${party.hostName}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Colors.grey[600],
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                child: Text(
                                  '${party.memberCount}/${party.maxMembers}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Chip(
                                label: Text(party.difficulty),
                                backgroundColor:
                                    AppTheme.accentColor.withValues(alpha: 0.2),
                              ),
                              const SizedBox(width: 8),
                              Chip(
                                label: Text(party.gameMode),
                                backgroundColor: AppTheme.primaryColor
                                    .withValues(alpha: 0.2),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: party.isFull
                                  ? null
                                  : () => _joinPartyDirect(party),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                party.isFull ? 'Party Full' : 'Join',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
