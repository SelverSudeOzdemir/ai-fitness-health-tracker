class UserHealthProfile {
  final int age;
  final String gender;
  final String healthProblems;
  final String goal;

  const UserHealthProfile({
    required this.age,
    required this.gender,
    required this.healthProblems,
    required this.goal,
  });

  Map<String, dynamic> toJson() {
    return {
      'age': age,
      'gender': gender,
      'healthProblems': healthProblems,
      'goal': goal,
    };
  }

  factory UserHealthProfile.fromJson(Map<String, dynamic> json) {
    return UserHealthProfile(
      age: int.tryParse(json['age'].toString()) ?? 18,
      gender: json['gender']?.toString() ?? 'Kadın',
      healthProblems: json['healthProblems']?.toString() ?? '',
      goal: json['goal']?.toString() ?? 'Fit devam edeceğim',
    );
  }
}
