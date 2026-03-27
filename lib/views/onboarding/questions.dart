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
                'student_objective'), // Skips milestone since high school is assumed
        OnboardingOption(
            id: 'uni_student',
            label: "University / College Student",
            nextQuestionId: 'student_milestone'),
        OnboardingOption(
            id: 'professional',
            label: "Working Professional",
            nextQuestionId: 'pro_objective'),
        OnboardingOption(
            id: 'explorer',
            label: "Self-Taught Explorer",
            nextQuestionId: 'explorer_objective'),
      ],
    ),


    OnboardingQuestion(
      id: 'student_milestone',
      question: "What milestone are you currently working towards?",
      options: [
        OnboardingOption(
            id: 'undergrad',
            label: "Undergraduate Degree (Bachelor's/Licence)",
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
            id: 'homework',
            label: "Homework & Assignments",
            nextQuestionId: 'student_major'),
        OnboardingOption(
            id: 'getting_ahead',
            label: "Getting Ahead (Learning outside class)",
            nextQuestionId: 'student_major'),
      ],
    ),
        OnboardingQuestion(
      id: 'exam_range',
      question: "Do you want to select your exams period ?",
      options: [
        OnboardingOption(
            id: 'select',
            label: "Select range",
            nextQuestionId:
                'student_major'), // Skips milestone since high school is assumed
        OnboardingOption(
            id: 'no',
            label: "skip",
            nextQuestionId: 'student_major'),
    
      ],
    ),
    OnboardingQuestion(
      id: 'student_major',
      question: "What is your primary field of study?",
      options: [
        OnboardingOption(
            id: 'cs',
            label: "Computer Science / Software Engineering",
            nextQuestionId: 'learning_style'),
        OnboardingOption(
            id: 'stem',
            label: "Math / Sciences",
            nextQuestionId: 'learning_style'),
        OnboardingOption(
            id: 'non_tech',
            label: "Other / Non-Technical",
            nextQuestionId: 'learning_style'),
      ],
    ),

  
    OnboardingQuestion(
      id: 'pro_objective',
      question: "What are you looking to conquer next?",
      options: [
        OnboardingOption(
            id: 'new_stack',
            label: "Learn a completely new language or stack",
            nextQuestionId: 'learning_style'),
        OnboardingOption(
            id: 'interviews',
            label: "Prepare for technical interviews",
            nextQuestionId: 'learning_style'),
        OnboardingOption(
            id: 'deepen_knowledge',
            label: "Deepen knowledge in my current stack",
            nextQuestionId: 'learning_style'),
      ],
    ),


    OnboardingQuestion(
      id: 'explorer_objective',
      question: "What is your ultimate goal?",
      options: [
        OnboardingOption(
            id: 'build_apps',
            label: "Build my own apps or websites",
            nextQuestionId: 'learning_style'),
        OnboardingOption(
            id: 'start_career',
            label: "Start a career in tech",
            nextQuestionId: 'learning_style'),
        OnboardingOption(
            id: 'just_fun',
            label: "Just exploring for fun",
            nextQuestionId: 'learning_style'),
      ],
    ),


    OnboardingQuestion(
      id: 'learning_style',
      question: "How do you prefer to tackle a new concept?",
      options: [
        OnboardingOption(
            id: 'theory_first',
            label: "Theory first, then practice",
            nextQuestionId: 'commitment'),
        OnboardingOption(
            id: 'step_by_step',
            label: "Step-by-step guided tutorials",
            nextQuestionId: 'commitment'),
        OnboardingOption(
            id: 'trial_error',
            label: "Trial and error (Hands-on first)",
            nextQuestionId: 'commitment'),
      ],
    ),

    // --- FINAL: COMMITMENT (Universal) ---
    OnboardingQuestion(
      id: 'commitment',
      question: "How much time can you dedicate daily?",
      options: [
        OnboardingOption(id: 'casual', label: "☕ 15-30 min (Casual)"),
        OnboardingOption(id: 'consistent', label: "⚡ 1-2 hours (Consistent)"),
        OnboardingOption(id: 'intensive', label: "🔥 3+ hours (Bootcamp)"),
      ],
    ),
  ];