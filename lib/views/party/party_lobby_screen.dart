import 'package:flutter/material.dart';
import 'package:pfe_test/services/appwrite_service.dart';
import 'package:pfe_test/theme/app_theme.dart';
import 'package:pfe_test/models/party_model.dart';
import 'package:provider/provider.dart';
import 'party_quiz_screen.dart';

class PartyLobbyScreen extends StatefulWidget {
  final Party party;

  const PartyLobbyScreen({
    super.key,
    required this.party,
  });

  @override
  State<PartyLobbyScreen> createState() => _PartyLobbyScreenState();
}

class _PartyLobbyScreenState extends State<PartyLobbyScreen> {
  late Party _party;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _party = widget.party;
  }

  void _toggleReady() {
    setState(() {
      _isReady = !_isReady;
    });
  }

  void _startGame() {
    if (_party.canStart) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PartyQuizScreen(party: _party),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All players must be ready to start'),
        ),
      );
    }
  }

  void _copyPartyCode() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Party code copied: ${_party.partyId}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AppwriteService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Party Lobby'),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.content_copy),
            onPressed: _copyPartyCode,
            tooltip: 'Copy party code',
          ),
        ],
      ),
      body: Column(
        children: [
          // Party Info Header
          Container(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _party.partyName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Host: ${_party.hostName}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Chip(
                      label: Text('${_party.memberCount}/${_party.maxMembers}'),
                      backgroundColor:
                          AppTheme.primaryColor.withValues(alpha: 0.2),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(_party.difficulty),
                      backgroundColor:
                          AppTheme.accentColor.withValues(alpha: 0.2),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(_party.gameMode),
                      backgroundColor: Colors.green.withValues(alpha: 0.2),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Members List
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Players (${_party.memberCount}/${_party.maxMembers})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child: _party.members.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Waiting for players...',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _party.members.length,
                            itemBuilder: (context, index) {
                              final member = _party.members[index];
                              final isHost = member.userId == _party.hostId;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: AppTheme.cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: member.isReady
                                        ? Colors.green.withValues(alpha: 0.3)
                                        : Colors.grey.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: AppTheme.primaryColor
                                            .withValues(alpha: 0.2),
                                        child: Text(
                                          member.username[0].toUpperCase(),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  member.username,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleSmall
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),
                                                if (isHost)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: AppTheme
                                                            .primaryColor
                                                            .withValues(
                                                                alpha: 0.2),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                      ),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 6,
                                                        vertical: 2,
                                                      ),
                                                      child: Text(
                                                        'HOST',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .labelSmall
                                                            ?.copyWith(
                                                              color: AppTheme
                                                                  .primaryColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Joined ${member.joinedAt.difference(DateTime.now()).inMinutes.abs()} min ago',
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
                                          color: member.isReady
                                              ? Colors.green
                                                  .withValues(alpha: .2)
                                              : Colors.orange
                                                  .withValues(alpha: .2),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        child: Text(
                                          member.isReady
                                              ? '✓ Ready'
                                              : 'Waiting',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: member.isReady
                                                ? Colors.green
                                                : Colors.orange,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Actions
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _toggleReady,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isReady ? Colors.green : AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _isReady ? '✓ Ready' : 'Mark as Ready',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                if (_party.hostId ==
                   authService.user!.$id) // Check if current user is host
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                     
                      onPressed: _party.canStart ? _startGame : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Start Game',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
