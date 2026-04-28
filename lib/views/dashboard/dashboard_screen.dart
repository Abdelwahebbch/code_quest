import 'package:flutter/material.dart';
import 'package:pfe_test/models/mission_model.dart';
import 'package:pfe_test/services/Auth/auth_provider.dart';
import 'package:pfe_test/services/Data/data_provider.dart';
import 'package:pfe_test/theme/app_theme.dart';
import 'package:pfe_test/views/badges/badges_screen.dart';
import 'package:pfe_test/views/party/party_home_screen.dart';
import 'package:pfe_test/views/profile/profile_screen.dart';
import 'package:pfe_test/views/settings/settings_screen.dart';
import 'package:pfe_test/widgets/mission_tile.dart';
import 'package:pfe_test/widgets/progress_card.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  late String username;

  Future<void> showNotif(List<String> badges) async {
    if (badges.isNotEmpty) {
      for (int i = 0; i < badges.length; i++) {
        await showMissionCompleted(context, badges[i]);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    final authservice = Provider.of<DataProvider>(context, listen: false);
    username = authservice.authProvider.currentUser!.name;
    List<String> badges = [];
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      showNotif(badges);
      authservice.emptyShowingBadges();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const DashboardHome(),
      PartyHomeScreen(
        username: Provider.of<AuthProvider>(context).currentUser!.name.split(' ').first,
      ),
      const BadgesScreen(),
      const SettingsScreen(),
    ];

    return SafeArea(
      child: Scaffold(
        body: screens[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          backgroundColor: Colors.amberAccent,
          onTap: (value) {
            setState(() {
              _currentIndex = value;
            });
          },
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.dashboard,
                ),
                label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.sports_esports,
                ),
                label: "Party"),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.emoji_events,
                ),
                label: "Badges"),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.settings,
                ),
                label: "Settings"),
          ],
        ),
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
      'desc': 'Complete 10 missions without hints',
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
      'desc': 'Complete 5 missions in one day',
      'icon': Icons.speed,
      'color': Colors.purple,
      'unlocked': false
    },
    {
      'name': 'Architect',
      'desc': 'Complete 10 ordering tasks',
      'icon': Icons.architecture,
      'color': Colors.red,
      'unlocked': false
    },
    {
      'name': 'Clean Coder',
      'desc': 'complete 10 missions with fewer than 30 failures.',
      'icon': Icons.cleaning_services,
      'color': Colors.teal,
      'unlocked': false
    },
    {
      'name': 'Team Player',
      'desc': 'Complete at least 10 single-choice and 10 multiple-choice challenges',
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
                            child: Icon(icon, color: color),
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
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => DashboardHomeState();
}

class DashboardHomeState extends State<DashboardHome> {
  late List<Mission> missions;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataProvider>(context);
    missions = dataService.progress.missions;
    final user = dataService.progress;
    final String userImage = dataService.progress.imageId;
    NetworkImage dataBaseImage = NetworkImage(
        'https://fra.cloud.appwrite.io/v1/storage/buckets/69891b1d0012c9a7e862/files/$userImage/view?project=697295e70021593c3438&mode=admin');

    return SafeArea(
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: () async {
            try {
              await dataService.getUserInfo();
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("No Internet connection !")));
            }
          },
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
                                  style:
                                      Theme.of(context).textTheme.bodyMedium),
                              Text( Provider.of<AuthProvider>(context).currentUser!.name.split(' ').first,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ProfileScreen()),
                              );
                            },
                            child: CircleAvatar(
                              radius: 25,
                              backgroundColor: AppTheme.primaryColor,
                              backgroundImage:
                                  userImage.isEmpty ? null : dataBaseImage,
                              child: userImage.isEmpty
                                  ? const Icon(Icons.person,
                                      color: Colors.white)
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
         checkMissionsAv()
            ],
          ),
        ),
      ),
    );
  }

  Widget checkMissionsAv() {
    switch (missions.isEmpty) {
      case true:
        return SliverToBoxAdapter(
            child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                padding: const EdgeInsets.all(16),
                child: const Text("There are no missions at the moment !")),
          ],
        ));

      case false:
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => MissionTile(mission: missions[index]),
            childCount: missions.length,
          ),
        );
    }
  }
}
