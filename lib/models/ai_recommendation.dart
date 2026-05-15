class AiRecommendation {
  final String exerciseTitle;
  final String exerciseSummary;
  final List<String> exercises;

  final String nutritionTitle;
  final String nutritionSummary;
  final List<String> meals;

  final String yogaTitle;
  final String yogaSummary;
  final List<String> yogaMoves;

  const AiRecommendation({
    required this.exerciseTitle,
    required this.exerciseSummary,
    required this.exercises,
    required this.nutritionTitle,
    required this.nutritionSummary,
    required this.meals,
    required this.yogaTitle,
    required this.yogaSummary,
    required this.yogaMoves,
  });

  factory AiRecommendation.fromJson(Map<String, dynamic> json) {
    List<String> listFrom(dynamic value) {
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      return <String>[];
    }

    return AiRecommendation(
      exerciseTitle:
          json['exerciseTitle']?.toString() ?? 'Kişisel Egzersiz Planı',
      exerciseSummary: json['exerciseSummary']?.toString() ?? '',
      exercises: listFrom(json['exercises']),

      nutritionTitle:
          json['nutritionTitle']?.toString() ?? 'Kişisel Beslenme Planı',
      nutritionSummary: json['nutritionSummary']?.toString() ?? '',
      meals: listFrom(json['meals']),

      yogaTitle: json['yogaTitle']?.toString() ?? 'Kişisel Yoga Planı',
      yogaSummary: json['yogaSummary']?.toString() ?? '',
      yogaMoves: listFrom(json['yogaMoves']),
    );
  }
}
