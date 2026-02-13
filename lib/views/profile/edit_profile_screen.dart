import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../services/appwrite_service.dart';
import '../../theme/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late String userName = "";
  late String email = "";
  late String bio = "";
  FileImage? image;
  ImageProvider? backgroundImage;
  Icon? icon;
  String pickedPath = "";
  String dataBasePickedPath="";
  List<String> profile = [];
  NetworkImage? dataBaseImage;
  bool isPickedPath=true;
  bool isDataBasePickedPath=true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  void _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        pickedPath = picked.path;
      });
    }
  }
  @override
  void initState(){
    super.initState();
    final authService = Provider.of<AppwriteService>(context, listen: false);
    dataBasePickedPath = authService.progress.imageId;
    _userNameController.text = authService.progress.username;
    _emailController.text = authService.progress.email;
    _bioController.text = authService.progress.bio;
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AppwriteService>(context, listen: false);
    if (pickedPath.isNotEmpty) {
      backgroundImage = FileImage(File(pickedPath));
      icon = null;
      isPickedPath=true;
      isDataBasePickedPath=false;
    } else if (dataBasePickedPath.isNotEmpty){
      dataBaseImage=NetworkImage('https://fra.cloud.appwrite.io/v1/storage/buckets/69891b1d0012c9a7e862/files/$dataBasePickedPath/view?project=697295e70021593c3438&mode=admin');
      icon = null;
      isDataBasePickedPath=true;
      isPickedPath=false;
    }
    else {
      icon = const Icon(Icons.person, size: 50, color: Colors.white);
      isPickedPath=false;
      isDataBasePickedPath=false;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        actions: [
          TextButton(
            onPressed: () async {
              await authService.updateProfile(
                  pickedPath, _userNameController.text, _bioController.text);
              //it handle in appservice function to not make tow function
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
            },
            child: const Text("SAVE",
                style: TextStyle(
                    color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppTheme.primaryColor,
                  backgroundImage: isPickedPath ? backgroundImage :(isDataBasePickedPath ? dataBaseImage : null) ,
                  
                  child: (isDataBasePickedPath && isPickedPath )? null : icon,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 35,
                    height: 35,
                    padding: const EdgeInsets.all(0),
                    decoration: const BoxDecoration(
                        color: AppTheme.accentColor, shape: BoxShape.circle),
                    child: IconButton(
                        onPressed: () {
                          _pickImage();
                        },
                        icon: const Icon(Icons.camera_alt,
                            size: 20, color: Colors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildEditField(context, "Username", _userNameController, false),
            const SizedBox(height: 16),
            _buildEditField(context, "Email", _emailController, true),
            const SizedBox(height: 16),
            _buildEditField(context, "Bio", _bioController, false),
          ],
        ),
      ),
    );
  }

  Widget _buildEditField(BuildContext context, String label,
      TextEditingController userNameController, bool editable) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppTheme.accentColor,
                fontWeight: FontWeight.bold,
                fontSize: 12)),
        const SizedBox(height: 8),
        TextField(
          readOnly: editable,
          controller: userNameController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}
