import 'package:flutter/material.dart';
import '../../models/mission_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/progress_card.dart';
import '../../widgets/mission_tile.dart';
import '../profile/profile_screen.dart';
import '../badges/badges_screen.dart';
import '../settings/settings_screen.dart';

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
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: "Badges"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }
}

class _DashboardHome extends StatelessWidget {
  const _DashboardHome();

  @override
  Widget build(BuildContext context) {
    // Mock data for demonstration
    final user = UserProgress(username: "DevExplorer", level: 4, experience: 3450, totalPoints: 1200);
    final missions = [
      Mission(
        id: "1",
        title: "The Null Pointer Mystery",
        description: "Find and fix the null pointer exception in the login logic.",
        type: MissionType.debug,
        points: 150,
        difficulty: 2,
        initialCode: "void login(User? user) { print(user.name); }",
        solution: "void login(User? user) { if(user != null) print(user.name); }",
      ),
      Mission(
        id: "2",
        title: "Async Await Mastery",
        description: "Complete the API fetch function using proper async/await.",
        type: MissionType.complete,
        points: 200,
        difficulty: 3,
        initialCode: "Future fetchData() { return ... }",
        solution: "Future fetchData() async { return await api.get(); }",
      ),
    ];

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
                            Text("Welcome back,", style: Theme.of(context).textTheme.bodyMedium),
                            Text(user.username, style: Theme.of(context).textTheme.headlineMedium),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ProfileScreen()),
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
                    Text("Active Missions", style: Theme.of(context).textTheme.titleLarge),
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
          ],
        ),
      ),
    );
  }
}
