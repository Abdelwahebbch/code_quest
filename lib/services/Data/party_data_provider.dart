import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart' hide Row;
import 'package:pfe_test/models/party_model.dart';
import 'package:pfe_test/models/user_info_model.dart';
import 'package:pfe_test/services/Auth/auth_provider.dart';
import 'package:pfe_test/services/Data/data_repository.dart';
import 'package:pfe_test/services/appwrite_service.dart';


class PartyDataProvider with ChangeNotifier {
  final DataRepository dataRepository;
  final AuthProvider authProvider;
  final AppwriteService appwriteService ;
  bool _isLoading = false;

   UserInfo progress;
  late Party party;

  late PartyMember partyMember;

  late Map<String, dynamic> userGoals;
  PartyDataProvider({required this.appwriteService ,  required this.dataRepository, required this.authProvider , required this.progress});


  bool get isLoading => _isLoading;



  Future<String> checkExistingParty() async {
    var row = await dataRepository.getRows(
      tableId: "party",
      queries: [
        Query.equal("hostId", authProvider.currentUser!.id),
      ],
    );
    if (row.rows.isNotEmpty) {
      return row.rows[0].$id;
    }
    return "";
  }

  Future<void> createParty(Party party) async {
    try {
      this.party = party;
      partyMember = PartyMember(
        userId: authProvider.currentUser!.id,
        username: authProvider.currentUser!.name,
        imageId: progress.imageId,
        joinedAt: DateTime.now(),
        score: 0,
        correctAnswers: 0,
        totalAnswers: 0,
        isReady: false,
      );
      notifyListeners();
      await dataRepository.createRow(
        tableId: "party",
        rowId: party.partyId,
        data: {
          "partyCode": party.partyCode,
          "partyName": party.partyName,
          "hostId": party.hostId,
          "hostName": party.hostName,
          "maxMembers": party.maxMembers,
          "difficulty": party.difficulty,
          "gameMode": party.gameMode,
          "totalRounds": party.totalRounds,
          "isStarted": party.isStarted,
          "isPublic": party.isPublic
        },
      );
      await dataRepository.createRow(
        tableId: "party_member",
        data: {
          "partyId": party.partyId,
          "userId": authProvider.currentUser!.id,
          "username": authProvider.currentUser!.name,
          "imageId": progress.imageId,
          "joinedAt": DateTime.now().toString(),
          "score": 0,
          "correctAnswers": 0,
          "totalAnswers": 0,
          "isReady": false,
          "isSubmit": false,
        },
        rowId: authProvider.currentUser!.id,
      );
    } catch (e) {
      rethrow;
    }
  }
  void toggleReadyLocaly(int memberIndex, bool isReady) {
    party.members[memberIndex].isReady = isReady;
    if (party.members[memberIndex].userId == authProvider.currentUser!.id) {
      partyMember.isReady = isReady;
    }
    notifyListeners();
  }
  Future<void> checkExistingPartyMember() async {
    try {
      await dataRepository.getRow(
          tableId: "party_member", rowId: authProvider.currentUser!.id);

      await dataRepository.deleteRow(
          tableId: "party_member", rowId: authProvider.currentUser!.id);
    } catch (e) {
      null;
    }
  }

  Future<void> gotToExisteParty(String partyIdDb) async {
    try {
      final partyRow =
          await dataRepository.getRow(tableId: "party", rowId: partyIdDb);
      final membersResult = await dataRepository.getRows(
        tableId: "party_member",
        queries: [
          Query.equal("partyId", partyIdDb),
        ],
      );
      final List<PartyMember> members = membersResult.rows
          .map((m) => PartyMember(
              userId: m.data["userId"],
              username: m.data["username"],
              imageId: m.data["imageId"],
              joinedAt: DateTime.parse(m.data["joinedAt"]),
              score: m.data["score"],
              correctAnswers: m.data["correctAnswers"],
              totalAnswers: m.data["totalAnswers"],
              isReady: m.data["isReady"],
              isSubmit: m.data["isSubmit"]))
          .toList();
      partyMember = PartyMember(
          userId: authProvider.currentUser!.id,
          username: authProvider.currentUser!.name,
          imageId: progress.imageId,
          joinedAt: DateTime.now(),
          score: 0,
          correctAnswers: 0,
          totalAnswers: 0,
          isReady: false,
          isSubmit: false);
      final m = await dataRepository.getRow(
          tableId: "party_member", rowId: authProvider.currentUser!.id);
      partyMember = PartyMember(
          userId: m.data["userId"],
          username: m.data["username"],
          imageId: m.data["imageId"],
          joinedAt: DateTime.parse(m.data["joinedAt"]),
          score: m.data["score"],
          correctAnswers: m.data["correctAnswers"],
          totalAnswers: m.data["totalAnswers"],
          isReady: m.data["isReady"],
          isSubmit: m.data["isSubmit"]);
      party = Party(
        partyId: partyRow.$id,
        partyCode: partyRow.data["partyCode"],
        partyName: partyRow.data["partyName"],
        hostId: partyRow.data["hostId"],
        hostName: partyRow.data["hostName"],
        members: members,
        maxMembers: partyRow.data["maxMembers"],
        difficulty: partyRow.data["difficulty"],
        gameMode: partyRow.data["gameMode"],
        totalRounds: partyRow.data["totalRounds"],
        isStarted: partyRow.data["isStarted"],
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> quiteLobby(String? row) async {
    try {
      if (row == null) {
        if (party.hostId.contains(authProvider.currentUser!.id)) {
          await dataRepository.deleteRow(
              tableId: "party", rowId: party.partyId);
          deleteAllMembers();
        } else {
          await dataRepository.deleteRow(
              tableId: "party_member", rowId: authProvider.currentUser!.id);
        }
      } else {
        await dataRepository.deleteRow(tableId: "party", rowId: row);
        await dataRepository.deleteRow(
            tableId: "party_member", rowId: authProvider.currentUser!.id);
      }
      //notifyListeners();
    } catch (e) {
      print("Erreur quite lobby $e");
      rethrow;
    }
  }

  Future<String> joinParty(String code) async {
    try {
      final partyResult = await dataRepository.getRows(
        tableId: "party",
        queries: [
          Query.equal("partyCode", code),
        ],
      );

      if (partyResult.rows.isEmpty) {
        return "Party not found";
      }
      final partyRow = partyResult.rows.first;
      final String rowId = partyRow.$id;
      final bool isStarted = partyRow.data["isStarted"];
      print(isStarted);
      if (isStarted == true) {
        return "Party already Started";
      }
      final int maxMembers = partyRow.data["maxMembers"] ?? 0;
      final membersResult = await dataRepository.getRows(
        tableId: "party_member",
        queries: [
          Query.equal("partyId", rowId),
        ],
      );

      final currentMembersCount = membersResult.rows.length;

      if (currentMembersCount >= maxMembers) {
        return "Party is Full";
      }
      final memberData = {
        "partyId": rowId,
        "userId": authProvider.currentUser!.id,
        "username": authProvider.currentUser!.name,
        "imageId": progress.imageId,
        "joinedAt": DateTime.now().toIso8601String(),
        "score": 0,
        "correctAnswers": 0,
        "totalAnswers": 0,
        "isReady": false,
      };
      await dataRepository.createRow(
        tableId: "party_member",
        rowId: authProvider.currentUser!.id,
        data: memberData,
      );
      final List<PartyMember> members = membersResult.rows
          .map((m) => PartyMember(
              userId: m.data["userId"],
              username: m.data["username"],
              imageId: m.data["imageId"],
              joinedAt: DateTime.parse(m.data["joinedAt"]),
              score: m.data["score"],
              correctAnswers: m.data["correctAnswers"],
              totalAnswers: m.data["totalAnswers"],
              isReady: m.data["isReady"],
              isSubmit: m.data["isSubmit"]))
          .toList();
      partyMember = PartyMember(
          userId: authProvider.currentUser!.id,
          username: authProvider.currentUser!.name,
          imageId: progress.imageId,
          joinedAt: DateTime.now(),
          score: 0,
          correctAnswers: 0,
          totalAnswers: 0,
          isReady: false,
          isSubmit: false);

      members.add(partyMember);

      party = Party(
        partyId: partyRow.$id,
        partyCode: partyRow.data["partyCode"],
        partyName: partyRow.data["partyName"],
        hostId: partyRow.data["hostId"],
        hostName: partyRow.data["hostName"],
        members: members,
        maxMembers: partyRow.data["maxMembers"],
        difficulty: partyRow.data["difficulty"],
        gameMode: partyRow.data["gameMode"],
        totalRounds: partyRow.data["totalRounds"],
        isStarted: partyRow.data["isStarted"],
      );
      notifyListeners();
      return rowId;
    } catch (e) {
      //Mazelt el cas mte kif yabdew yal3bo w yo5rej
      print("Error joining party: $e");
      rethrow;
    }
  }

  Future<void> deleteAllMembers() async {
    try {
      await Future.wait(party.members.map((m) => dataRepository.deleteRow(
            tableId: "party_member",
            rowId: m.userId,
          )));
      party.members.clear();
    } catch (e) {
      print("Erreur fi deleteAllMembers $e");
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getQuiz() async {
    try {
      List<Map<String, dynamic>> quizs = [];
      var rows = await dataRepository.getRows(
        tableId: "quizzes",
        queries: [
          Query.equal("partyId", party.partyId),
          Query.orderDesc("\$createdAt"),
        ],
      );
      for (int i = 0; i < rows.rows.length; i++) {
        final row = await dataRepository.getRow(
            tableId: "quizzes", rowId: rows.rows[i].$id);
        quizs.add({
          'question': row.data['question'],
          'options': row.data['options'],
          'correct': row.data['correct'],
          'category': row.data['category']
        });
      }
      return quizs;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> toggleReady(String rowId) async {
    try {
      bool isReady = false;
      for (int i = 0; i < party.members.length; i++) {
        if (party.members[i].username == authProvider.currentUser!.name) {
          isReady = party.members[i].isReady;
          party.members[i].isReady = !isReady;
          partyMember.isReady = !isReady;
        }
      }

      await dataRepository.getRows(
        tableId: "party_member",
        queries: [
          Query.equal("partyId", rowId),
          Query.equal("userId", authProvider.currentUser!.id)
        ],
      );
      await dataRepository.updateRow(
        tableId: "party_member",
        rowId: authProvider.currentUser!.id,
        data: {'isReady': !isReady},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> startParty(String rowId) async {
    try {
      await dataRepository.updateRow(
        tableId: "party",
        rowId: rowId,
        data: {'isStarted': true},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> kickMember(String userId) async {
    try {
      await dataRepository.deleteRow(tableId: "party_member", rowId: userId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> submitAnswer(PartyMember partyMember) async {
    try {
      this.partyMember.score = partyMember.score;
      this.partyMember.correctAnswers = partyMember.correctAnswers;
      this.partyMember.totalAnswers = partyMember.totalAnswers;
      await dataRepository.updateRow(
        tableId: "party_member",
        rowId: authProvider.currentUser!.id,
        data: {
          'correctAnswers': partyMember.correctAnswers,
          "score": partyMember.score,
          "totalAnswers": partyMember.totalAnswers,
          "isSubmit": true
        },
      );
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateMembersDetails(String rowId) async {
    print(party.memberCount);
    bool isAllSubmit = false;
    while (isAllSubmit == false) {
      isAllSubmit = true;
      await Future.delayed(const Duration(seconds: 2));
      var rows = await dataRepository.getRows(
        tableId: "party_member",
        queries: [
          Query.equal("partyId", rowId),
        ],
      );
      for (int i = 0; i < rows.rows.length; i++) {
        for (int j = 0; j < party.memberCount; j++) {
          if (party.members[j].userId == rows.rows[i].data["userId"]) {
            party.members[j].score = rows.rows[i].data["score"];
            party.members[j].correctAnswers =
                rows.rows[i].data["correctAnswers"];
            party.members[j].totalAnswers = rows.rows[i].data["totalAnswers"];
            party.members[j].isSubmit = rows.rows[i].data["isSubmit"];
            if (!party.members[j].isSubmit) {
              isAllSubmit = false;
              break;
            }
          }
        }
        if (!isAllSubmit) {
          break;
        }
      }
      notifyListeners();
    }
  }

  Future<void> savePartyHistory(List<PartyMember> rankedMembers) async {
    List<String> jsonMembers = [];
    for (int i = 0; i < rankedMembers.length; i++) {
      jsonMembers.add(rankedMembers[i].toJson());
    }
    await dataRepository.createRow(
      tableId: "party_history",
      // kenet ID.unique
      rowId: ID.unique(),
      data: {
        "partyId": party.partyId,
        "partyName": party.partyName,
        "partyMembers": jsonMembers,
        "startedAt": party.startedAt.toString(),
        "completedAt": party.endedAt.toString(),
      },
    );
  }

  Future<void> partyPlayAgain() async {
    try {
      await dataRepository.updateRow(
        tableId: "party",
        rowId: party.partyId,
        data: {'isStarted': false},
      );
    } catch (e) {
      rethrow;
    }
  }
}
