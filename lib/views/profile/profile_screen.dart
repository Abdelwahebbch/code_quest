import 'package:flutter/material.dart';
import 'package:pfe_test/services/Auth/auth_provider.dart';
import 'package:pfe_test/services/Data/data_provider.dart';
import 'package:pfe_test/theme/app_theme.dart';
import 'package:pfe_test/views/auth/login_screen.dart';
import 'package:provider/provider.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late int rank;
  bool isReady = false;

  Future<void> getRank() async {
    final authService = Provider.of<DataProvider>(context, listen: false);
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
    final authService = Provider.of<DataProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = authService.authProvider.currentUser;
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
                await auth.signOut();
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
              const SizedBox(height: 16),
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
    final authService = Provider.of<DataProvider>(context);
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

  
}
