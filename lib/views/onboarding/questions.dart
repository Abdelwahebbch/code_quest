import 'package:pfe_test/models/onboarding_model.dart';

final List<OnboardingQuestion> questions = [
  OnboardingQuestion(
    id: 'journey',
    question: "What best describes your current journey?",
    options: [
      OnboardingOption(
          id: 'hs_student',
          label: "High School Student",
          nextQuestionId:
              'section'), // Skips milestone since high school is assumed
      OnboardingOption(
          id: 'uni_student',
          label: "University / College Student",
          nextQuestionId: 'student_milestone'),
      OnboardingOption(
          id: 'explorer',
          label: "Self-Taught Explorer",
          nextQuestionId: 'explorer_objective'),
    ],
  ),







  
  OnboardingQuestion(
    id: 'section',
    question: "What is your study section?",
    options: [
      OnboardingOption(
          id: 'sc_student',
          label: "Science Section",
          nextQuestionId:
              'student_objective'), // Skips milestone since high school is assumed
      OnboardingOption(
          id: 'lettre_student',
          label: "Literature Section",
          nextQuestionId: 'student_objective'),
    ],
  ),








  OnboardingQuestion(
    id: 'student_milestone',
    question: "What milestone are you currently working towards?",
    options: [
      OnboardingOption(
          id: 'undergrad',
          label: "Undergraduate Degree (Bachelor's / Licence)",
          nextQuestionId: 'student_objective'),
      OnboardingOption(
          id: 'graduate',
          label: "Graduate Degree / Engineering Diploma",
          nextQuestionId: 'student_objective'),
    ],
  ),






  OnboardingQuestion(
    id: 'student_objective',
    question: "What is your main objective right now?",
    options: [
      OnboardingOption(
          id: 'exam_prep',
          label: "Exam Prep (Acing upcoming tests)",
          nextQuestionId: 'exam_range'),
      OnboardingOption(
          id: 'basics',
          label: "Learn the basics",
          nextQuestionId: 'commitment'),
      OnboardingOption(
          id: 'getting_ahead',
          label: "Learn outside of class",
          nextQuestionId: 'commitment'),
    ],
  ),





  OnboardingQuestion(
    id: 'exam_range',
    question: "Do you want to select your exam period?",
    options: [
      OnboardingOption(
          id: 'select',
          label: "Select range",
          nextQuestionId:
              'commitment'), // Skips milestone since high school is assumed
      OnboardingOption(id: 'no', label: "Skip", nextQuestionId: 'commitment'),
    ],
  ),






  OnboardingQuestion(
    id: 'explorer_objective',
    question: "What is your ultimate goal?",
    options: [
      OnboardingOption(
          id: 'build_apps',
          label: "Build my own apps or websites",
          nextQuestionId: 'learning_goal'),
      OnboardingOption(
          id: 'start_career',
          label: "Start a career in tech",
          nextQuestionId: 'learning_goal'),
      OnboardingOption(
          id: 'just_fun',
          label: "Just exploring for fun",
          nextQuestionId: 'learning_goal'),
    ],
  ),





  OnboardingQuestion(
    id: 'learning_goal',
    question: "What's your goal?",
    options: [
      OnboardingOption(
          id: 'basics',
          label: "Learn the basics",
          nextQuestionId: 'commitment'),
      OnboardingOption(
          id: 'master_lang',
          label: "Master a programming language",
          nextQuestionId: 'commitment'),
      OnboardingOption(
          id: 'exam_prep',
          label: "Prepare for exams",
          nextQuestionId: 'commitment'),
    ],
  ),






  OnboardingQuestion(
    id: 'commitment',
    question: "How much time can you dedicate daily?",
    options: [
      OnboardingOption(id: 'casual', label: "☕ 15-30 min"),
      OnboardingOption(id: 'consistent', label: "⚡ 1-2 hours"),
      OnboardingOption(id: 'intensive', label: "🔥 3+ hours"),
    ],
  ),
];
