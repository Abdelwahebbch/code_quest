import 'package:flutter/material.dart';
import 'package:pfe_test/views/auth/login_screen.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/appwrite_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late int rank;
  bool isReady = false;

  Future<void> getRank() async {
    final authService = Provider.of<AppwriteService>(context, listen: false);
    rank = await authService.getRank();
    setState(() {
      isReady = true;
    });
  }

  @override
  void initState() {
    super.initState();
    getRank();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AppwriteService>(context, listen: false);
    final user = authService.user;
    final String userImage = authService.progress.imageId;
    List<String> images=["iron1","iron2","iron3","bronze1","bronze2","bronze3","silver1","silver2","silver3","gold1","gold2","gold3"];
    List<String> elos=["Iron 1","Iron 2","Iron 3","Bronze 1","Bronze 2","Bronze 3","Silver 1","Silver 2","Silver 3","Gold 1","Gold 2","Gold 3"];
    int elo=authService.progress.elo;
    int index=0;
    if(elo<2300) index=elo ~/ 100;
    else index=22;
    String image="assets/icon/${images[index]}.png";

    NetworkImage dataBaseImage = NetworkImage(
        'https://fra.cloud.appwrite.io/v1/storage/buckets/69891b1d0012c9a7e862/files/$userImage/view?project=697295e70021593c3438&mode=admin');
    if (!isReady) {
      return const SafeArea(
          child: Scaffold(
        body: Center(
            child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ))),
      ));
    }
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Profile"),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                      (route) => false);
                }
                await authService.logout();
              },
            )
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: AppTheme.primaryColor,
                backgroundImage: userImage.isEmpty ? null : dataBaseImage,
                child: userImage.isEmpty
                    ? const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 50,
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                user?.name ?? "Guest",
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                user?.email ?? "",
                style: const TextStyle(color: Colors.grey),
              ),
              Text(
                authService.progress.bio,
                style: const TextStyle(color: AppTheme.accentColor),
              ),
              const SizedBox(height: 32),
              _buildStatRow(context),
              const SizedBox(height: 32),
              _buildSectionTitle(context, "Elo Rank"),
              Center(child: Image.asset(image,height: 100,)),
              Center(child: Text(elos[index],style: const TextStyle(fontSize: 30,color: Colors.white),)),
              const SizedBox(height: 20,),
              ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (elo%100)/100,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 10,
              ),
            ),
             Padding(
               padding:  const EdgeInsets.only(left: 10.0,right: 10,top: 5),
               child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Elo Progress",style: TextStyle(color: Colors.white),),
                  Text("${elo%100}/100",style: const TextStyle(color: Colors.white)),
                ],
               ),
             )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(context) {
    final authService = Provider.of<AppwriteService>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem("Missions", "${authService.progress.nbMissions}"),
        _buildStatItem("Points", "${authService.progress.totalPoints}"),
        _buildStatItem("Rank", "#$rank"),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  Widget _buildBadgeGrid(context) {
    final authService = Provider.of<AppwriteService>(context, listen: false);
    List<String> earnBadges = authService.progress.earnedBadges;
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
    List<Map<String, dynamic>> badges = [];
    for (int i = 0; i < allBadges.length; i++) {
      if (earnBadges.contains(allBadges[i]['name'])) {
        badges.add(allBadges[i]);
      }
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (badges[index]['color'] as Color).withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                    color: (badges[index]['color'] as Color)
                        .withValues(alpha: 0.5)),
              ),
              child: Icon(badges[index]['icon'] as IconData,
                  color: badges[index]['color'] as Color, size: 24),
            ),
            const SizedBox(height: 4),
            Text(badges[index]['name'] as String,
                style: const TextStyle(fontSize: 8),
                textAlign: TextAlign.center),
          ],
        );
      },
    );
  }


}
