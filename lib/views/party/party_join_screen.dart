import 'package:appwrite/appwrite.dart';
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
  final List<Party> _availableParties = [];
  RealtimeSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _fetchParties();
    _subscribeToParties();
  }

  void _fetchParties() async {
    final authService = Provider.of<AppwriteService>(context, listen: false);
    try {
      final docs = await authService.database.listRows(
          databaseId: "6972adad002e2ba515f2",
          tableId: "party",
          queries: [
            Query.equal("isPublic", true),
            Query.notEqual("hostId", authService.user?.$id)
          ]);
      if (!mounted) return;
      setState(() {
        _availableParties.clear();
        _availableParties.addAll(
          docs.rows.map((doc) => Party(
              partyId: doc.$id,
              partyCode: doc.data["partyCode"],
              partyName: doc.data["partyName"],
              hostId: doc.data["hostId"],
              hostName: doc.data["hostName"],
              maxMembers: doc.data["maxMembers"] ?? 4,
              difficulty: doc.data["difficulty"] ?? "Normal",
              gameMode: doc.data["gameMode"] ?? "Classic",
              nbMembers: doc.data["memberCount"])),
        );
      });
    } catch (e) {
      debugPrint("Failed to fetch parties: $e");
    }
  }

  void _subscribeToParties() {
    final authService = Provider.of<AppwriteService>(context, listen: false);

    _subscription = authService.realtime.subscribe([
      Channel.tablesdb('6972adad002e2ba515f2').table('party').row()
    ], queries: [
      Query.equal("isPublic", true),
      Query.notEqual("hostId", authService.user?.$id)
    ]);

    _subscription!.stream.listen((res) {
      if (!mounted) return;
      final msg = res.payload;

      Party partyFromPayload() => Party(
          partyId: msg["\$id"],
          partyCode: msg["partyCode"],
          partyName: msg["partyName"],
          hostId: msg["hostId"],
          hostName: msg["hostName"],
          maxMembers: msg["maxMembers"],
          difficulty: msg["difficulty"],
          gameMode: msg["gameMode"],
          nbMembers: msg["memberCount"],
          isStarted : msg["isStarted"]);

      if (res.events.any((e) => e.contains("create"))) {
        if (!mounted) return;
        setState(() => _availableParties.add(partyFromPayload()));
      } else if (res.events.any((e) => e.contains("update"))) {
        if (!mounted) return;
        setState(() {
          final index =
              _availableParties.indexWhere((p) => p.partyId == msg["\$id"]);
          if (index != -1 && msg["isPublic"]) {
            _availableParties[index] = partyFromPayload();
          } else {
            _availableParties.add(partyFromPayload());
          }
        });
      } else if (res.events.any((e) => e.contains("delete"))) {
        if (!mounted) return;
        setState(() {
          _availableParties.removeWhere((p) => p.partyId == msg["\$id"]);
        });
      }
    });
  }

  void _joinPartyWithCode() async {
    if (code.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a full 6-character code')),
      );
      return;
    }

    final authService = Provider.of<AppwriteService>(context, listen: false);
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      await authService.checkExistingPartyMember();
      String rowId = await authService.joinParty(code);
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (rowId.contains("Party is Full")) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Party is Full'), duration: Duration(seconds: 2)),
        );
        return;
      }
      if(rowId.contains("Party already Started")){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Party already Started'), duration: Duration(seconds: 2)),
        );
        return;
      }
      if (rowId.contains("Party not found")) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Party not found'), duration: Duration(seconds: 2)),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PartyLobbyScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Connection Error'), duration: Duration(seconds: 2)),
      );
    }
  }

  void _joinPartyDirect(Party party) async {
    if (party.isFull) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This party is full')),
      );
      return;
    }
    if(party.isStarted){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Party already Started'), duration: Duration(seconds: 2)),
        );
        return;
      }
    final authService = Provider.of<AppwriteService>(context, listen: false);
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      await authService.checkExistingPartyMember();
      String rowId = await authService.joinParty(party.partyCode);
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (rowId.contains("Party is Full")) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Party is Full')),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PartyLobbyScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connection Error')),
      );
    }
  }

  @override
  void dispose() {
    _subscription?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
                      activeColor: AppTheme.primaryColor,
                      selectedColor: AppTheme.primaryColor,
                    ),
                    onChanged: (value) => setState(() => code = value),
                    onCompleted: (value) {
                      setState(() => code = value);
                      _joinPartyWithCode();
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
                                color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'Available Parties',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                _availableParties.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            children: [
                              Icon(Icons.search_off,
                                  size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 12),
                              Text(
                                'No parties available right now',
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Enter a code above or wait for a party to open',
                                style: TextStyle(
                                    color: Colors.grey[400], fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _availableParties.length,
                        itemBuilder: (context, index) =>
                            partyTile(_availableParties[index]),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget partyTile(Party party) {
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
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Host: ${party.hostName}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Text(
                    '${party.nbMembers}/${party.maxMembers}',
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
                  backgroundColor: AppTheme.accentColor.withValues(alpha: 0.2),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(party.gameMode),
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (party.isFull || _isLoading)
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
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
