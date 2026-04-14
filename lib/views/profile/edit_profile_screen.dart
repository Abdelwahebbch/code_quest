import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pfe_test/models/onboarding_model.dart';
import 'package:provider/provider.dart';
import '../../services/appwrite_service.dart';
import '../../theme/app_theme.dart';
import '../onboarding/questions.dart';

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
  String dataBasePickedPath = "";
  List<String> profile = [];
  NetworkImage? dataBaseImage;
  bool isPickedPath = true;
  bool isDataBasePickedPath = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  List<String> userGoalsKeys = [];
  List<String> userGoalsValues = [];
  List<String> newUserGoalsValues = [];
  List<String> newUserGoalsKeys = [];
  String? nextQestionQuestion;
  DateTime? startDate;
  DateTime? endDate;
  String? language;
  List<OnboardingOption>? nextQuestionOptions;
  void _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        pickedPath = picked.path;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AppwriteService>(context, listen: false);
    dataBasePickedPath = authService.progress.imageId;
    _userNameController.text = authService.progress.username;
    _emailController.text = authService.progress.email;
    _bioController.text = authService.progress.bio;
    for (var element in authService.userGoals.values) {
      userGoalsValues.add(element.toString());
    }
    userGoalsKeys = authService.userGoals.keys.toList();
    print(userGoalsValues);
  }

  void builAlert(context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
            child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print(nextQuestionOptions?.length);

    final authService = Provider.of<AppwriteService>(context, listen: false);
    if (pickedPath.isNotEmpty) {
      backgroundImage = FileImage(File(pickedPath));
      icon = null;
      isPickedPath = true;
      isDataBasePickedPath = false;
    } else if (dataBasePickedPath.isNotEmpty) {
      dataBaseImage = NetworkImage(
          'https://fra.cloud.appwrite.io/v1/storage/buckets/69891b1d0012c9a7e862/files/$dataBasePickedPath/view?project=697295e70021593c3438&mode=admin');
      icon = null;
      isDataBasePickedPath = true;
      isPickedPath = false;
    } else {
      icon = const Icon(Icons.person, size: 50, color: Colors.white);
      isPickedPath = false;
      isDataBasePickedPath = false;
    }
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Edit Profile"),
          actions: [
            TextButton(
              onPressed: () async {
                if (newUserGoalsKeys.isNotEmpty &&
                    !newUserGoalsKeys.contains("commitment")) {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Incomplete Changes"),
                          content: const Text(
                              "Please complete all questions before saving your changes."),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("OK"),
                            ),
                          ],
                        );
                      });
                } else if (newUserGoalsKeys.isNotEmpty) {
                  builAlert(context);
                  Map<String, String> data = {};
                  for (int i = 0; i < newUserGoalsKeys.length; i++) {
                    data.addAll({newUserGoalsKeys[i]: newUserGoalsValues[i]});
                  }
                  await authService.updateUserGoals(data);
                  await authService.fixEducationTime(startDate, endDate);
                  await authService.updateProfile(pickedPath,
                      _userNameController.text, _bioController.text);
                  if (language != null) {
                    await authService.updateLanguageSelected("JavaScript");
                  }
                  //it handle in appservice function to not make tow function
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                } else if (newUserGoalsKeys.isEmpty) {
                  builAlert(context);
                  await authService.updateProfile(pickedPath,
                      _userNameController.text, _bioController.text);
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                  //it handle in appservice function to not make tow function
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                }
              },
              child: const Text("SAVE",
                  style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold)),
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
                    backgroundImage: isPickedPath
                        ? backgroundImage
                        : (isDataBasePickedPath ? dataBaseImage : null),
                    child: (isDataBasePickedPath && isPickedPath) ? null : icon,
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
              _buildEditField(context, "Username", _userNameController, true),
              const SizedBox(height: 16),
              _buildEditField(context, "Email", _emailController, true),
              const SizedBox(height: 16),
              _buildEditField(context, "Bio", _bioController, false),
              const SizedBox(height: 16),
              ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: newUserGoalsValues.isEmpty
                      ? userGoalsValues.length
                      : newUserGoalsValues.length,
                  itemBuilder: (context, index) {
                    var items = [];
                    String question = "";
                    if (newUserGoalsValues.isEmpty) {
                      var condition = questions.firstWhere(
                          (onboardingQuestions) => onboardingQuestions.options
                              .any((labels) =>
                                  labels.label == userGoalsValues[index]));
                      items = condition.options;
                      question = condition.question;
                    } else {
                      for (int i = 0; i < questions.length; i++) {
                        for (int j = 0; j < questions[i].options.length; j++) {
                          if (newUserGoalsValues[index] ==
                              questions[i].options[j].label) {
                            items = questions[i].options;
                            question = questions[i].question;
                          }
                        }
                      }
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(question,
                            style: const TextStyle(
                                color: AppTheme.accentColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                        const SizedBox(height: 8),
                        DropdownButton2(
                          isExpanded: true,
                          underline: const SizedBox(),
                          hint: newUserGoalsValues.isEmpty
                              ? Text(
                                  userGoalsValues[index],
                                  style: const TextStyle(color: Colors.white),
                                )
                              : Text(
                                  newUserGoalsValues[index],
                                  style: const TextStyle(color: Colors.white),
                                ),
                          items: items.map((option) {
                            return DropdownMenuItem<String>(
                              value: option.label,
                              child: (newUserGoalsValues.isEmpty
                                      ? option.label == userGoalsValues[index]
                                      : option.label ==
                                          newUserGoalsValues[index])
                                  ? Text(
                                      option.label,
                                      style: const TextStyle(
                                          color: AppTheme.primaryColor),
                                    )
                                  : Text(option.label),
                            );
                          }).toList(),
                          onChanged: (value) async {
                            if (value == "Select range") {
                              final DateTimeRange? selectedRange =
                                  await showDateRangePicker(
                                context: context,
                                firstDate: DateTime(2025),
                                lastDate: DateTime(2027),
                              );
                              if (selectedRange == null) {
                                return;
                              }
                              startDate = selectedRange.start;
                              endDate = selectedRange.end;
                            }
                            if (value == "Build my own apps or websites") {
                              language = "JavaScript";
                            }
                            setState(() {
                              String? nextQuestionId;
                              print(value);
                              print("aaa&1");
                              if (newUserGoalsValues.isEmpty) {
                                String id = questions
                                    .firstWhere((onboardingQuestions) =>
                                        onboardingQuestions.options.any(
                                            (labels) => labels.label == value))
                                    .id;
                                int indexValue = userGoalsKeys.indexOf(id);
                                if (indexValue > 0) {
                                  newUserGoalsKeys.addAll(userGoalsKeys
                                      .getRange(0, indexValue + 1));
                                  newUserGoalsValues.addAll(
                                      userGoalsValues.getRange(0, indexValue));
                                  print(newUserGoalsKeys);
                                } else if (indexValue == 0) {
                                  newUserGoalsKeys.add(userGoalsKeys[0]);
                                  newUserGoalsValues = [];
                                }
                              } else {
                                String id = questions
                                    .firstWhere((onboardingQuestions) =>
                                        onboardingQuestions.options.any(
                                            (labels) => labels.label == value))
                                    .id;
                                print("id" + id);
                                int indexValue = newUserGoalsKeys.indexOf(id);
                                print("newUserGoalsKeys" +
                                    newUserGoalsKeys.toString());
                                print("indexValue" + indexValue.toString());
                                if (indexValue > 0) {
                                  int end = newUserGoalsKeys.length;
                                  newUserGoalsKeys.removeRange(
                                      indexValue + 1, end);
                                  newUserGoalsValues.removeRange(
                                      indexValue, end);
                                  print("newUserGoalsKeys" +
                                      newUserGoalsKeys.toString());
                                  print("newUserGoalsValues" +
                                      newUserGoalsValues.toString());
                                } else if (indexValue == 0) {
                                  newUserGoalsKeys = [];
                                  newUserGoalsKeys.add(userGoalsKeys[0]);
                                  newUserGoalsValues = [];
                                }
                              }
                              newUserGoalsValues.add(value!);
                              for (int i = 0; i < questions.length; i++) {
                                for (int j = 0;
                                    j < questions[i].options.length;
                                    j++) {
                                  if (value == questions[i].options[j].label) {
                                    nextQuestionId =
                                        questions[i].options[j].nextQuestionId;
                                    break;
                                  }
                                }
                                if (nextQuestionId != null) break;
                              }
                              if (nextQuestionId != null) {
                                for (int i = 0; i < questions.length; i++) {
                                  if (questions[i].id == nextQuestionId) {
                                    nextQuestionOptions = questions[i].options;
                                    nextQestionQuestion = questions[i].question;
                                    print(nextQuestionOptions?.length);
                                  }
                                }
                              } else {
                                nextQuestionOptions = null;
                              }
                            });
                          },
                        ),
                      ],
                    );
                  }),
              if (nextQuestionOptions != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nextQestionQuestion!,
                        style: const TextStyle(
                            color: AppTheme.accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                    const SizedBox(height: 8),
                    DropdownButton2(
                      isExpanded: true,
                      underline: const SizedBox(),
                      hint: const Text(
                        "Select Option",
                        style: TextStyle(color: Colors.white),
                      ),
                      items: nextQuestionOptions!.map((option) {
                        return DropdownMenuItem<String>(
                          value: option.label,
                          child: Text(
                            option.label,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) async {
                        if (value == "Select range") {
                          final DateTimeRange? selectedRange =
                              await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2025),
                            lastDate: DateTime(2027),
                          );
                          if (selectedRange == null) {
                            return;
                          }

                          startDate = selectedRange.start;
                          endDate = selectedRange.end;
                        }
                        if (value == "Build my own apps or websites") {
                          language = "JavaScript";
                        }
                        setState(() {
                          print("aaaaa2");
                          print(value);
                          String id = questions
                              .firstWhere((onboardingQuestions) =>
                                  onboardingQuestions.options
                                      .any((labels) => labels.label == value))
                              .id;
                          String? nextQuestionId;
                          newUserGoalsKeys.add(id);
                          print("newUserGoalsKeys2" +
                              newUserGoalsKeys.toString());
                          newUserGoalsValues.add(value!);
                          for (int i = 0; i < questions.length; i++) {
                            for (int j = 0;
                                j < questions[i].options.length;
                                j++) {
                              if (value == questions[i].options[j].label) {
                                nextQuestionId =
                                    questions[i].options[j].nextQuestionId;
                                break;
                              } else {
                                nextQuestionId = null;
                              }
                            }
                            if (nextQuestionId != null) break;
                          }
                          if (nextQuestionId != null) {
                            for (int i = 0; i < questions.length; i++) {
                              if (questions[i].id == nextQuestionId) {
                                nextQuestionOptions = questions[i].options;
                                nextQestionQuestion = questions[i].question;
                              }
                            }
                          } else {
                            nextQuestionOptions = null;
                          }
                        });
                      },
                    ),
                  ],
                ),
            ],
          ),
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
