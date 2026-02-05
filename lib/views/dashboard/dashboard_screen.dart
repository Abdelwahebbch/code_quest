import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/mission_model.dart';
import '../../models/user_progress_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/progress_card.dart';
import '../../widgets/mission_tile.dart';
import '../profile/profile_screen.dart';
import '../badges/badges_screen.dart';
import '../settings/settings_screen.dart';
import '../../services/appwrite_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _DashboardHome(),
    const BadgesScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: AppTheme.cardColor,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events), label: "Badges"),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }
}

class _DashboardHome extends StatefulWidget {
  const _DashboardHome();

  @override
  State<_DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<_DashboardHome> {
  // ignore: unused_field
  late Future<List<Mission>> _missionsFuture;
  @override
  void initState() {
    super.initState();
    final authservice = Provider.of<AppwriteService>(context, listen: false);
    _missionsFuture = authservice.getMissions();
  }

  @override
  Widget build(BuildContext context) {
    //Mock Missions
    final missions = [
      Mission(
        id: "1",
        title: "The Null Pointer Mystery",
        description:
            "Find and fix the null pointer exception in the login logic.",
        type: MissionType.debug,
        points: 150,
        difficulty: 2,
        initialCode: "void login(User? user) { print(user.name); }",
        solution:
            "void login(User? user) { if(user != null) print(user.name); }",
      ),
      Mission(
        id: "2",
        title: "Data Types Quiz",
        description:
            "Which of the following is an immutable data type in Python?",
        type: MissionType.singleChoice,
        points: 50,
        difficulty: 1,
        options: ["List", "Dictionary", "Tuple", "Set"],
        solution: "Tuple",
      ),
      Mission(
        id: "3",
        title: "SOLID Principles",
        description: "Select all principles that belong to SOLID.",
        type: MissionType.multipleChoice,
        points: 100,
        difficulty: 3,
        options: [
          "Single Responsibility",
          "Open-Closed",
          "Encapsulation",
          "Liskov Substitution"
        ],
        solution: "Single Responsibility,Open-Closed,Liskov Substitution",
      ),
      Mission(
        id: "4",
        title: "Algorithm Sequencing",
        description: "Order the steps of a Binary Search algorithm correctly.",
        type: MissionType.ordering,
        points: 150,
        difficulty: 4,
        options: [
          "Find the middle element",
          "Compare with target",
          "Divide the range",
          "Repeat until found"
        ],
        correctOrder: [
          "Find the middle element",
          "Compare with target",
          "Divide the range",
          "Repeat until found"
        ],
      ),
    ];
    final authService = Provider.of<AppwriteService>(context);
    final appwriteUser = authService.user;

    final user = UserProgress(
        username: appwriteUser?.name ?? "AlooAloo",
        level: 4,
        experience: 3450,
        totalPoints: 1200,
        progLanguage: 'Python');

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Welcome back,",
                                style: Theme.of(context).textTheme.bodyMedium),
                            Text(user.username,
                                style:
                                    Theme.of(context).textTheme.headlineMedium),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ProfileScreen()),
                            );
                          },
                          child: const CircleAvatar(
                            radius: 25,
                            backgroundColor: AppTheme.primaryColor,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    ProgressCard(user: user),
                    const SizedBox(height: 30),
                    Text("Active Missions",
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => MissionTile(mission: missions[index]),
                childCount: missions.length,
              ),
            ),
            //Pour afficher le mission depuis DataBase

            // FutureBuilder<List<Mission>>(
            //   future: _missionsFuture,
            //   builder: (context, snapshot) {
            //     if (snapshot.connectionState == ConnectionState.waiting) {
            //       return const SliverToBoxAdapter(
            //         child: Center(child: CircularProgressIndicator()),
            //       );
            //     } else if (snapshot.hasError) {
            //       return SliverToBoxAdapter(
            //         child: Center(child: Text("Error: ${snapshot.error}")),
            //       );
            //     } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            //       return const SliverToBoxAdapter(
            //         child: Center(child: Text("No missions available.")),
            //       );
            //     }

            //     final missions = snapshot.data!;
            //     return SliverList(
            //       delegate: SliverChildBuilderDelegate(
            //         (context, index) => MissionTile(mission: missions[index]),
            //         childCount: missions.length,
            //       ),
            //     );
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
