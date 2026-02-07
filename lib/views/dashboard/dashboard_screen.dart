import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/mission_model.dart';
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
  late Future<List<Mission>> _missionsFuture;
  @override
  void initState() {
    super.initState();
    final authservice = Provider.of<AppwriteService>(context, listen: false);
    _missionsFuture = authservice.getMissions();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AppwriteService>(context);
   // final appwriteUser = authService.user;

    final user = authService.progress; 

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
            FutureBuilder<List<Mission>>(
              future: _missionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError) {
                  return const SliverToBoxAdapter(
                    child: Center(child: Text("Errorr cannot load Missions")),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Center(child: Text("No missions available.")),
                  );
                }

                final missions = snapshot.data!;
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => MissionTile(mission: missions[index]),
                    childCount: missions.length,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
