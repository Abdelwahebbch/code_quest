class OnboardingQuestion {
  final String id;
  final String question;
  final List<OnboardingOption> options;


  OnboardingQuestion({
    required this.id,
    required this.question,
    required this.options,
  });
}

class OnboardingOption {
  final String id;
  final String label;
  final String? nextQuestionId; 


  
  OnboardingOption({
    required this.id,
    required this.label,
    this.nextQuestionId,
  });
}


