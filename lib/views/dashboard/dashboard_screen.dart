import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as authservice;
import 'package:provider/provider.dart';
import '../../models/mission_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/progress_card.dart';
import '../../widgets/mission_tile.dart';
import '../profile/profile_screen.dart';
import '../badges/badges_screen.dart';
import '../settings/settings_screen.dart';
import '../../services/appwrite_service.dart';

// big probleme
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  Future<void> showNotif(List<String> badges) async {
    print(badges);
    if (badges.isNotEmpty) {
      for (int i = 0; i < badges.length; i++) {
        await showMissionCompleted(context, badges[i]);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    final authservice = Provider.of<AppwriteService>(context, listen: false);
    List<String> badges = authservice.progress.showingBadges;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showNotif(badges);
      authservice.emptyShowingBadges();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      DashboardHome(),
      BadgesScreen(),
      SettingsScreen(),
    ];

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

  Future<void> showMissionCompleted(BuildContext context, String title) async {
    final overlay = Overlay.of(context);
    List<Map<String, dynamic>> allBadges = [
      {
        'name': 'Bug Hunter',
        'desc': 'Fix 10 debugging missions',
        'icon': Icons.bug_report,
        'color': Colors.green,
        'unlocked': false
      },
      {
        'name': 'Code Ninja',
        'desc': 'Complete 5 missions without hints',
        'icon': Icons.bolt,
        'color': Colors.orange,
        'unlocked': false
      },
      {
        'name': 'Test Master',
        'desc': 'Write 20 unit tests',
        'icon': Icons.verified,
        'color': Colors.blue,
        'unlocked': false
      },
      {
        'name': 'Fast Learner',
        'desc': 'Complete 3 missions in one day',
        'icon': Icons.speed,
        'color': Colors.purple,
        'unlocked': false
      },
      {
        'name': 'Architect',
        'desc': 'Design a complex system',
        'icon': Icons.architecture,
        'color': Colors.red,
        'unlocked': false
      },
      {
        'name': 'Clean Coder',
        'desc': 'Maintain high code quality',
        'icon': Icons.cleaning_services,
        'color': Colors.teal,
        'unlocked': false
      },
      {
        'name': 'Team Player',
        'desc': 'Review 5 peer solutions',
        'icon': Icons.groups,
        'color': Colors.indigo,
        'unlocked': false
      },
      {
        'name': 'AI Whisperer',
        'desc': 'Ask 50 insightful questions',
        'icon': Icons.psychology,
        'color': Colors.pink,
        'unlocked': false
      },
    ];
    Map<String, dynamic> badge = {};
    for (int i = 0; i < allBadges.length; i++) {
      if (allBadges[i]['name'] == title) {
        badge = allBadges[i];
      }
    }
    IconData icon = badge['icon'];
    Color color = badge['color'];
    double top = 60;
    double opacity = 1.0;

    final overlayEntry = OverlayEntry(
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            top: top,
            left: 20,
            right: 20,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: opacity,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.only(
                      top: 16, bottom: 16, right: 25, left: 25),
                  decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 10)
                      ],
                      border: BoxBorder.all(
                        color: Colors.black,
                      )),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Badge Completed:",
                        style: TextStyle(
                          color: AppTheme.warningColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: BoxBorder.all(
                                  color: color,
                                )),
                                child:Icon(icon, color: color), 
                          ),
                          
                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               Text(
                                "Mission Completed: $title",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                badge['desc'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                             
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );

    overlay.insert(overlayEntry);

    await Future.delayed(const Duration(seconds: 3));

    top = -100;
    opacity = 0;
    overlayEntry.markNeedsBuild();
    await Future.delayed(const Duration(milliseconds: 500));
    overlayEntry.remove();
  }
}

class DashboardHome extends StatefulWidget {
  const DashboardHome();

  @override
  State<DashboardHome> createState() => DashboardHomeState();
}

class DashboardHomeState extends State<DashboardHome> {
  late List<Mission> missions;

  @override
  void initState() {
    super.initState();
    final authservice = Provider.of<AppwriteService>(context, listen: false);
    missions = authservice.progress.missions;
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AppwriteService>(context);

    final user = authService.progress;
    final String userImage = user.imageId;
    NetworkImage dataBaseImage = NetworkImage(
        'https://fra.cloud.appwrite.io/v1/storage/buckets/69891b1d0012c9a7e862/files/$userImage/view?project=697295e70021593c3438&mode=admin');

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
                          child: CircleAvatar(
                            radius: 25,
                            backgroundColor: AppTheme.primaryColor,
                            backgroundImage:
                                userImage.isEmpty ? null : dataBaseImage,
                            child: userImage.isEmpty
                                ? Icon(Icons.person, color: Colors.white)
                                : null,
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
          ],
        ),
      ),
    );
  }
}
