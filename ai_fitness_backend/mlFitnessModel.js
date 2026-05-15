const trainingData = [
  {
    age: 18,
    gender: "Kadın",
    goal: "Zayıflamak istiyorum",
    health: "yok",
    label: "lose_weight",
  },
  {
    age: 25,
    gender: "Erkek",
    goal: "Zayıflamak istiyorum",
    health: "diz",
    label: "lose_weight_low_impact",
  },
  {
    age: 30,
    gender: "Kadın",
    goal: "Fit devam edeceğim",
    health: "yok",
    label: "stay_fit",
  },
  {
    age: 35,
    gender: "Erkek",
    goal: "Fit devam edeceğim",
    health: "bel",
    label: "stay_fit_mobility",
  },
  {
    age: 22,
    gender: "Kadın",
    goal: "Kilo almak istiyorum",
    health: "yok",
    label: "gain_weight",
  },
  {
    age: 28,
    gender: "Erkek",
    goal: "Kilo almak istiyorum",
    health: "sırt",
    label: "gain_weight_safe",
  },
];

function distance(user, sample) {
  let score = Math.abs(Number(user.age) - sample.age) / 10;
  if (user.gender !== sample.gender) score += 1;
  if (user.goal !== sample.goal) score += 5;

  const userHealth = (user.healthProblems || "").toLowerCase();
  if (sample.health !== "yok" && userHealth.includes(sample.health)) score -= 1;
  return score;
}

function predictLabel(user) {
  let best = trainingData[0];
  let bestDistance = distance(user, best);

  for (const sample of trainingData) {
    const d = distance(user, sample);
    if (d < bestDistance) {
      best = sample;
      bestDistance = d;
    }
  }
  return best.label;
}

function recommendationFromLabel(label, user) {
  const health = (user.healthProblems || "").toLowerCase();
  const hasKnee = health.includes("diz");
  const hasBack = health.includes("bel") || health.includes("sırt");

  if (label.includes("lose_weight")) {
    return {
      exerciseTitle: "Yağ Yakım Odaklı Egzersiz Planı",
      exerciseSummary:
        "KNN modeli hedefini zayıflama olarak sınıflandırdı. Düşük-orta yoğunluk kardiyo ve temel kuvvet önerildi.",
      exercises: [
        hasKnee
          ? "Düşük tempolu yürüyüş: 25 dakika"
          : "Tempolu yürüyüş veya hafif koşu: 30 dakika",
        "Bodyweight squat: 3 set x 12 tekrar",
        hasBack
          ? "Duvar şınavı: 3 set x 10 tekrar"
          : "Şınav: 3 set x 8-12 tekrar",
        "Plank: 3 set x 20-40 saniye",
        "Bisiklet crunch: 3 set x 15 tekrar",
        "Soğuma esnemesi: 8 dakika",
      ],
      nutritionTitle: "Kalori Dengeli Beslenme Planı",
      nutritionSummary:
        "Protein yüksek, işlenmiş şeker düşük ve porsiyon kontrollü üç öğün önerildi.",
      meals: [
        "Kahvaltı: Yulaf, yoğurt, tarçın, elma dilimleri ve 1 haşlanmış yumurta",
        "Öğle: Izgara tavuk veya baklagil, bol salata, 4-5 kaşık bulgur",
        "Ara öğün: Kefir veya yoğurt + 10 badem",
        "Akşam: Sebze yemeği, yoğurt, yağsız protein kaynağı",
        "Su hedefi: Gün boyu 2-2.5 litre",
      ],
      yogaTitle: "Metabolizma Destekleyici Yoga",
      yogaSummary:
        "Stres azaltma ve hareket açıklığı için hafif akış önerildi.",
      yogaMoves: [
        "Cat-Cow: 2 dakika",
        hasBack ? "Child Pose: 3 dakika" : "Downward Dog: 3 set x 30 saniye",
        "Low Lunge: Her bacak 45 saniye",
        "Seated Twist: Her yön 45 saniye",
        "Savasana nefes çalışması: 5 dakika",
      ],
    };
  }

  if (label.includes("gain_weight")) {
    return {
      exerciseTitle: "Kas Kazanımı Odaklı Egzersiz Planı",
      exerciseSummary:
        "KNN modeli hedefini kilo/kas kazanımı olarak sınıflandırdı. Kuvvet antrenmanı ve progresif yüklenme önerildi.",
      exercises: [
        "Isınma: 8 dakika yürüyüş + eklem mobilitesi",
        hasKnee
          ? "Leg press hafif tempo: 3 set x 10 tekrar"
          : "Squat: 4 set x 8-10 tekrar",
        "Dumbbell row: 4 set x 10 tekrar",
        "Chest press veya şınav: 4 set x 8-12 tekrar",
        "Shoulder press: 3 set x 10 tekrar",
        "Dead bug core: 3 set x 12 tekrar",
      ],
      nutritionTitle: "Kalori Fazlası Beslenme Planı",
      nutritionSummary:
        "Kas gelişimi için protein, kompleks karbonhidrat ve sağlıklı yağ ağırlıklı plan önerildi.",
      meals: [
        "Kahvaltı: 2 yumurta, peynir, tam buğday ekmek, zeytin, muz",
        "Öğle: Pirinç/bulgur, tavuk veya kırmızı et, yoğurt, salata",
        "Ara öğün: Fıstık ezmeli tam tahıllı ekmek veya smoothie",
        "Akşam: Makarna veya patates, balık/tavuk, sebze",
        "Antrenman sonrası: Süt/yoğurt + muz + yulaf",
      ],
      yogaTitle: "Kas Toparlanma Yogası",
      yogaSummary:
        "Ağırlık antrenmanı sonrası esneklik ve toparlanma için önerildi.",
      yogaMoves: [
        "Deep breathing: 2 dakika",
        "Pigeon Pose: Her bacak 60 saniye",
        "Cobra Pose: 3 set x 25 saniye",
        "Hamstring stretch: Her bacak 60 saniye",
        "Legs Up The Wall: 5 dakika",
      ],
    };
  }

  return {
    exerciseTitle: "Fit Kalma ve Form Koruma Planı",
    exerciseSummary:
      "KNN modeli hedefini mevcut formu koruma olarak sınıflandırdı. Dengeli kardiyo, kuvvet ve mobilite önerildi.",
    exercises: [
      "Isınma: 7 dakika dinamik esneme",
      "Full body circuit: 4 tur",
      "Lunge veya step-up: 3 set x 12 tekrar",
      "Row hareketi: 3 set x 12 tekrar",
      "Mountain climber: 3 set x 30 saniye",
      "Plank + side plank: 3 tur",
    ],
    nutritionTitle: "Dengeli Beslenme Planı",
    nutritionSummary:
      "Enerji seviyesini koruyan dengeli üç öğün planı önerildi.",
    meals: [
      "Kahvaltı: Omlet, tam tahıllı ekmek, domates-salatalık",
      "Öğle: Protein kaynağı, salata, bulgur veya makarna",
      "Ara öğün: Meyve + yoğurt veya kuruyemiş",
      "Akşam: Sebze, protein ve yoğurt dengesi",
      "Haftalık hedef: 3 gün egzersiz, 2 gün aktif yürüyüş",
    ],
    yogaTitle: "Günlük Denge Yogası",
    yogaSummary:
      "Esneklik, nefes ve odaklanmayı artıran dengeli akış önerildi.",
    yogaMoves: [
      "Sun Salutation: 4 tur",
      "Warrior II: Her yön 45 saniye",
      "Tree Pose: Her bacak 45 saniye",
      "Seated Forward Fold: 60 saniye",
      "Box breathing: 4 dakika",
    ],
  };
}

function recommend(user) {
  const label = predictLabel(user);
  return recommendationFromLabel(label, user);
}

module.exports = { recommend, predictLabel };
