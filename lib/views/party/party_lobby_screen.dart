import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:pfe_test/services/appwrite_service.dart';
import 'package:pfe_test/theme/app_theme.dart';
import 'package:pfe_test/models/party_model.dart';
import 'package:provider/provider.dart';
import 'party_quiz_screen.dart';

class PartyLobbyScreen extends StatefulWidget {
  const PartyLobbyScreen({super.key});

  @override
  State<PartyLobbyScreen> createState() => _PartyLobbyScreenState();
}

class _PartyLobbyScreenState extends State<PartyLobbyScreen> {
  late Party _party;
  bool _isReady = false;
  RealtimeSubscription? subscription;
  RealtimeSubscription? subscription1;
  @override
  void dispose() {
    subscription?.close();
    subscription1?.close();
    super.dispose();
  }
  
  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AppwriteService>(context, listen: false);
    _party = authService.party;
    subscription = authService.realtime.subscribe([
      Channel.tablesdb("6972adad002e2ba515f2")
          .table("party")
          .row(_party.partyId)
    ]);
    subscription?.stream.listen((response) {
      if (response.payload["isStarted"] == true) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PartyQuizScreen(),
          ),
        );
      }
    });
    subscription1 = authService.realtime.subscribe(
        [Channel.tablesdb("6972adad002e2ba515f2").table("party_member").row()],
        queries: [Query.equal("partyId", _party.partyId)]);
    subscription1?.stream.listen((response) {
      print("Realtime resp : ${response.payload}");
      Map<String, dynamic> row = response.payload;
      if (response.events.first.contains("create")) {
        PartyMember partyMember = PartyMember(
            userId: row["userId"],
            username: row["username"],
            imageId: row["imageId"],
            joinedAt: DateTime.parse(row["joinedAt"]),
            score: row["score"],
            correctAnswers: row["correctAnswers"],
            totalAnswers: row["totalAnswers"],
            isReady: row["isReady"],
            isSubmit: row["isSubmit"]);

        setState(() {
          authService.addMember(partyMember);
        });
      } else if (response.events.first.contains("delete")) {
        bool isHost = _party.hostId == authService.user!.$id;
        setState(() {
          authService.deleteMember(row["userId"]);
        });
        if (!isHost && row["userId"] == _party.hostId && mounted) {
          deleteAllMembers();
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('The owner just close the party'),
            ),
          );
        }
      }
      if (response.events.first.contains("update")) {
        for (int i = 0; i < _party.members.length; i++) {
          if (row["userId"] == _party.members[i].userId) {
            setState(() {
              authService.toggleReadyLocaly(i, row["isReady"]);
            });
          }
        }
      }
    });
  }
  Future<void> deleteAllMembers() async {
    final authService = Provider.of<AppwriteService>(context, listen: false);
    await authService.deleteAllMembers();
  }
  
  Future<void> _toggleReady() async {
    final authService = Provider.of<AppwriteService>(context, listen: false);
    await authService.toggleReady(_party.partyId);
    setState(() {
      _isReady = !_isReady;
    });
  }

  void _startGame() async {
    if (_party.canStart) {
      final authService = Provider.of<AppwriteService>(context, listen: false);
      await authService.startParty(_party.partyId);
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
        content: Text('Party code copied: ${_party.partyCode}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AppwriteService>(context, listen: false);
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                  height: 110,
                  width: double.infinity,
                  color: AppTheme.primaryColor),
              Positioned(
                  bottom: 2,
                  left: 0,
                  right: 0,
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 3,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 25,
                        ),
                        onPressed: () async {
                          await authService.quiteLobby();
                          Navigator.pop(context);
                        },
                      ),

                      const SizedBox(width: 20),

                      Text(
                        "Party Lobby",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                      ),

                      const Spacer(),

                      // Party code
                      Text(
                        "${_party.partyCode.substring(0, 3)} ${_party.partyCode.substring(3, 6)}",
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                      ),

                      IconButton(
                        icon:
                            const Icon(Icons.content_copy, color: Colors.white),
                        onPressed: _copyPartyCode,
                        tooltip: 'Copy party code',
                      ),
                    ],
                  ))
            ],
          ),

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
