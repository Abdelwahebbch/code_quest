# Party Mode - Multiplayer Quiz Feature

## Overview
Party Mode allows users to create or join multiplayer quiz sessions with friends. Players compete in real-time, answering questions and earning points based on speed and accuracy.

## Features

### 1. Party Home Screen (`party_home_screen.dart`)
- **Create Party**: Start a new multiplayer session with custom settings
- **Join Party**: Join existing parties using party codes or from available parties list
- Beautiful gradient UI with clear call-to-action buttons

### 2. Party Creation (`party_create_screen.dart`)
Users can configure:
- **Party Name**: Custom name for the session
- **Max Members**: 2-8 players (default: 4)
- **Difficulty Level**: Beginner, Intermediate, Advanced
- **Game Mode**: Quiz, Missions, or Mixed
- **Total Rounds**: 3-10 questions per session

### 3. Party Join (`party_join_screen.dart`)
- **Join with Code**: Enter party code to join specific sessions
- **Available Parties**: Browse and join public parties
- Shows party info: host name, member count, difficulty, game mode
- Real-time availability status

### 4. Party Lobby (`party_lobby_screen.dart`)
- **Member List**: See all players in the party
- **Ready Status**: Mark yourself as ready to start
- **Host Controls**: Only host can start the game when all players are ready
- **Party Info**: Display party code, difficulty, game mode
- Smooth animations and real-time updates

### 5. Party Quiz (`party_quiz_screen.dart`)
- **Live Gameplay**: Real-time quiz with 30-second timer per question
- **Multiple Choice**: 4 options per question
- **Instant Feedback**: See correct/incorrect answers immediately
- **Progress Tracking**: Visual progress bar showing round progress
- **Live Player Count**: See active players in real-time
- **Score Calculation**: Points based on speed and accuracy

### 6. Party Results (`party_results_screen.dart`)
- **Final Rankings**: Sorted leaderboard with medals for top 3
- **Winner Celebration**: Highlighted winner with 🎉 animation
- **Detailed Stats**: 
  - Individual scores
  - Accuracy percentage
  - Total questions answered
  - Average score across all players
- **Action Buttons**: Return to home or play again

## Data Models

### PartyMember
```dart
class PartyMember {
  String userId;
  String username;
  String imageId;
  int score;
  int correctAnswers;
  int totalAnswers;
  bool isReady;
  DateTime joinedAt;
  
  double get accuracy => (correctAnswers / totalAnswers) * 100;
}
```

### Party
```dart
class Party {
  String partyId;
  String partyName;
  String hostId;
  String hostName;
  List<PartyMember> members;
  List<Mission> missions;
  int maxMembers;
  int currentMissionIndex;
  bool isActive;
  bool isStarted;
  DateTime createdAt;
  String difficulty;
  String gameMode;
  int totalRounds;
  
  bool get isFull => members.length >= maxMembers;
  bool get canStart => members.length >= 2 && members.every((m) => m.isReady);
}
```

### PartyResult
```dart
class PartyResult {
  String partyId;
  String partyName;
  List<PartyMember> finalRanking;
  DateTime completedAt;
  int totalDuration;
  String winnerName;
  int winnerScore;
}
```

## Navigation Flow

```
Dashboard (Home)
    ↓
Party Home Screen
    ├─→ Create Party → Party Create Screen → Party Lobby → Party Quiz → Party Results
    └─→ Join Party → Party Join Screen → Party Lobby → Party Quiz → Party Results
```

## Integration with Dashboard

The Party feature is integrated into the main dashboard as a new tab:

**Bottom Navigation Items:**
1. Home (Dashboard)
2. **Party** (NEW) - Group icon
3. Badges
4. Settings

## Usage Example

```dart
// Navigate to Party Home
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const PartyHomeScreen(),
  ),
);

// Create a new party
final party = Party(
  partyId: DateTime.now().millisecondsSinceEpoch.toString(),
  partyName: 'Python Masters',
  hostId: 'user123',
  hostName: 'John Doe',
  createdAt: DateTime.now(),
  maxMembers: 6,
  difficulty: 'intermediate',
  gameMode: 'quiz',
  totalRounds: 5,
);

// Navigate to lobby
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => PartyLobbyScreen(party: party),
  ),
);
```

## Features Highlights

✅ **Real-time Multiplayer**: Live quiz with instant feedback
✅ **Customizable Sessions**: Configure difficulty, game mode, and rounds
✅ **Party Codes**: Easy sharing with friends
✅ **Leaderboard**: Final rankings with detailed statistics
✅ **Animations**: Smooth transitions and result animations
✅ **Responsive Design**: Works on all screen sizes
✅ **User-friendly UI**: Intuitive navigation and clear instructions

## Future Enhancements

- Voice chat during gameplay
- Replay functionality
- Party history and statistics
- Achievement badges for party wins
- Seasonal leaderboards
- Invite friends via social media
- Custom question sets
- Spectator mode
- Mobile notifications for party invites

## Technical Stack

- **Framework**: Flutter
- **State Management**: Provider
- **UI**: Material Design
- **Animations**: Flutter Animation APIs
- **Data**: Local models (ready for backend integration)

## Files Structure

```
lib/views/party/
├── party_home_screen.dart          # Main entry point
├── party_create_screen.dart        # Create new party
├── party_join_screen.dart          # Join existing party
├── party_lobby_screen.dart         # Wait room before game
├── party_quiz_screen.dart          # Live quiz gameplay
├── party_results_screen.dart       # Final rankings
└── PARTY_FEATURE_README.md         # This file

lib/models/
└── party_model.dart                # Data models
```

## Backend Integration Notes

The Party feature is designed to be easily integrated with a backend API:

1. **Party Creation**: POST `/api/parties` with party configuration
2. **Join Party**: POST `/api/parties/{partyId}/join` with user info
3. **Ready Status**: PATCH `/api/parties/{partyId}/ready` to mark as ready
4. **Start Game**: POST `/api/parties/{partyId}/start` (host only)
5. **Submit Answer**: POST `/api/parties/{partyId}/answer` with answer data
6. **Get Results**: GET `/api/parties/{partyId}/results` after game ends

## Contributing

When adding new features to Party Mode:
1. Update the relevant screen file
2. Modify `party_model.dart` if adding new data structures
3. Update this README with new features
4. Test on multiple device sizes
5. Ensure animations are smooth and responsive

---

**Last Updated**: March 2026
**Version**: 1.0.0
