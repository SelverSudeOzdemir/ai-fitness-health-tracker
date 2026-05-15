import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_health_profile.dart';
import '../models/ai_recommendation.dart';

class AiService {
  static UserHealthProfile? _lastProfile;
  static AiRecommendation? _lastRecommendation;

  static const String baseUrl = 'http://10.0.2.2:3000';

  static UserHealthProfile? get lastProfile => _lastProfile;
  static AiRecommendation? get lastRecommendation => _lastRecommendation;

  static Future<void> saveProfile({
    required int age,
    required String gender,
    required String healthProblems,
    required String goal,
  }) async {
    final profile = UserHealthProfile(
      age: age,
      gender: gender,
      healthProblems: healthProblems,
      goal: goal,
    );

    await saveProfileAndGetRecommendation(profile);
  }

  static Future<AiRecommendation> saveProfileAndGetRecommendation(
    UserHealthProfile profile,
  ) async {
    _lastProfile = profile;

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/ai/recommendation'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(profile.toJson()),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _lastRecommendation = AiRecommendation.fromJson(data);
        return _lastRecommendation!;
      }
    } catch (_) {}

    _lastRecommendation = _localRecommendation(profile);
    return _lastRecommendation!;
  }

  static Future<AiRecommendation?> getRecommendation() async {
    if (_lastRecommendation != null) return _lastRecommendation;
    if (_lastProfile == null) return null;
    return saveProfileAndGetRecommendation(_lastProfile!);
  }

  static AiRecommendation _localRecommendation(UserHealthProfile profile) {
    final goal = profile.goal;
    final health = profile.healthProblems.toLowerCase();
    final hasKnee = health.contains('diz');
    final hasBack = health.contains('bel') || health.contains('sırt');

    if (goal == 'Zayıflamak istiyorum') {
      return AiRecommendation(
        exerciseTitle: 'Yağ Yakım Odaklı Egzersiz Planı',
        exerciseSummary:
            'Model, hedefini zayıflama olarak sınıflandırdı. Kardiyo ve kontrollü kuvvet önerildi.',
        exercises: [
          hasKnee
              ? 'Düşük tempolu yürüyüş: 25 dakika'
              : 'Tempolu yürüyüş veya hafif koşu: 30 dakika',
          'Bodyweight squat: 3 set x 12 tekrar',
          hasBack
              ? 'Duvar şınavı: 3 set x 10 tekrar'
              : 'Şınav: 3 set x 8-12 tekrar',
          'Plank: 3 set x 20-40 saniye',
          'Bisiklet crunch: 3 set x 15 tekrar',
          'Soğuma esnemesi: 8 dakika',
        ],
        nutritionTitle: 'Kalori Dengeli Beslenme Planı',
        nutritionSummary:
            'Protein yüksek, işlenmiş şeker düşük, porsiyon kontrollü üç öğün önerildi.',
        meals: [
          'Kahvaltı: Yulaf, yoğurt, tarçın, elma ve 1 haşlanmış yumurta',
          'Öğle: Izgara tavuk veya baklagil, bol salata, 4-5 kaşık bulgur',
          'Ara öğün: Kefir veya yoğurt + 10 badem',
          'Akşam: Sebze yemeği, yoğurt, yağsız protein kaynağı',
          'Su hedefi: Gün boyu 2-2.5 litre',
        ],
        yogaTitle: 'Metabolizma Destekleyici Yoga',
        yogaSummary:
            'Stres azaltma ve hareket açıklığı için hafif akış önerildi.',
        yogaMoves: [
          'Cat-Cow: 2 dakika',
          hasBack ? 'Child Pose: 3 dakika' : 'Downward Dog: 3 set x 30 saniye',
          'Low Lunge: Her bacak 45 saniye',
          'Seated Twist: Her yön 45 saniye',
          'Savasana nefes çalışması: 5 dakika',
        ],
      );
    }

    if (goal == 'Kilo almak istiyorum') {
      return AiRecommendation(
        exerciseTitle: 'Kas Kazanımı Odaklı Egzersiz Planı',
        exerciseSummary:
            'Model, hedefini kilo/kas kazanımı olarak sınıflandırdı. Kuvvet antrenmanı önerildi.',
        exercises: [
          'Isınma: 8 dakika yürüyüş + eklem mobilitesi',
          hasKnee
              ? 'Leg press hafif tempo: 3 set x 10 tekrar'
              : 'Squat: 4 set x 8-10 tekrar',
          'Dumbbell row: 4 set x 10 tekrar',
          'Chest press veya şınav: 4 set x 8-12 tekrar',
          'Shoulder press: 3 set x 10 tekrar',
          'Dead bug core: 3 set x 12 tekrar',
        ],
        nutritionTitle: 'Kalori Fazlası Beslenme Planı',
        nutritionSummary:
            'Kas gelişimi için protein, kompleks karbonhidrat ve sağlıklı yağ ağırlıklı plan önerildi.',
        meals: [
          'Kahvaltı: 2 yumurta, peynir, tam buğday ekmek, zeytin, muz',
          'Öğle: Pirinç/bulgur, tavuk veya kırmızı et, yoğurt, salata',
          'Ara öğün: Fıstık ezmeli tam tahıllı ekmek veya smoothie',
          'Akşam: Makarna veya patates, balık/tavuk, sebze',
          'Antrenman sonrası: Süt/yoğurt + muz + yulaf',
        ],
        yogaTitle: 'Kas Toparlanma Yogası',
        yogaSummary:
            'Ağırlık antrenmanı sonrası esneklik ve toparlanma için önerildi.',
        yogaMoves: [
          'Deep breathing: 2 dakika',
          'Pigeon Pose: Her bacak 60 saniye',
          'Cobra Pose: 3 set x 25 saniye',
          'Hamstring stretch: Her bacak 60 saniye',
          'Legs Up The Wall: 5 dakika',
        ],
      );
    }

    return AiRecommendation(
      exerciseTitle: 'Fit Kalma ve Form Koruma Planı',
      exerciseSummary:
          'Model, hedefini mevcut formu koruma olarak sınıflandırdı. Dengeli kardiyo, kuvvet ve mobilite önerildi.',
      exercises: [
        'Isınma: 7 dakika dinamik esneme',
        'Full body circuit: 4 tur',
        'Lunge veya step-up: 3 set x 12 tekrar',
        'Row hareketi: 3 set x 12 tekrar',
        'Mountain climber: 3 set x 30 saniye',
        'Plank + side plank: 3 tur',
      ],
      nutritionTitle: 'Dengeli Beslenme Planı',
      nutritionSummary:
          'Enerji seviyesini koruyan dengeli üç öğün planı önerildi.',
      meals: [
        'Kahvaltı: Omlet, tam tahıllı ekmek, domates-salatalık',
        'Öğle: Protein kaynağı, salata, bulgur veya makarna',
        'Ara öğün: Meyve + yoğurt veya kuruyemiş',
        'Akşam: Sebze, protein ve yoğurt dengesi',
        'Haftalık hedef: 3 gün egzersiz, 2 gün aktif yürüyüş',
      ],
      yogaTitle: 'Günlük Denge Yogası',
      yogaSummary:
          'Esneklik, nefes ve odaklanmayı artıran dengeli akış önerildi.',
      yogaMoves: [
        'Sun Salutation: 4 tur',
        'Warrior II: Her yön 45 saniye',
        'Tree Pose: Her bacak 45 saniye',
        'Seated Forward Fold: 60 saniye',
        'Box breathing: 4 dakika',
      ],
    );
  }
}
