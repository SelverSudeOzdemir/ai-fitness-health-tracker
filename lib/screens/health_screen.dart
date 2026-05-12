import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final moods = ["Enerjik", "Normal", "Yorgun", "Stresli"];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "HEALTH TRACK",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            "Günlük Sağlık Girişi",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),

          const SizedBox(height: 18),

          const TextField(
            decoration: InputDecoration(
              labelText: "Bugün kaç litre su içtin?",
              prefixIcon: Icon(Icons.water_drop),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),

          const SizedBox(height: 14),

          const TextField(
            decoration: InputDecoration(
              labelText: "Kaç saat uyudun?",
              prefixIcon: Icon(Icons.bedtime),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),

          const SizedBox(height: 20),

          const Text(
            "Ruh halin nasıl?",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: moods.map((mood) {
              return Chip(
                avatar: const Icon(Icons.mood, size: 18),
                label: Text(mood),
                backgroundColor: AppColors.neon.withOpacity(0.18),
                side: const BorderSide(color: AppColors.neon),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: const [
                  Icon(Icons.psychology, color: AppColors.neon, size: 34),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "AI Analizi: Uyku ve su tüketimine göre yarın daha hafif bir spor planı önerilebilir.",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neon,
              foregroundColor: AppColors.black,
              padding: const EdgeInsets.all(17),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            child: const Text("Kaydet"),
          ),
        ],
      ),
    );
  }
}
