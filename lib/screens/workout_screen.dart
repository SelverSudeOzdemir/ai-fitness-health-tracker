import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workouts = [
      [
        "Full Body Power",
        "Squat • Push-up • Plank",
        "35 dk",
        Icons.fitness_center,
        AppColors.neon,
      ],
      [
        "HIIT Cardio",
        "Koşu • Jumping Jack • Sprint",
        "25 dk",
        Icons.flash_on,
        AppColors.coral,
      ],
      [
        "Core Burn",
        "Crunch • Leg Raise • Mountain Climber",
        "18 dk",
        Icons.whatshot,
        AppColors.rose,
      ],
      [
        "Stretch & Mobility",
        "Yoga • Esneme • Nefes",
        "12 dk",
        Icons.self_improvement,
        AppColors.purple,
      ],
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "WORKOUT PLAN",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.darkGreen,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: AppColors.neon),
            ),
            child: const Row(
              children: [
                Icon(Icons.sports_gymnastics, color: AppColors.neon, size: 42),
                SizedBox(width: 14),
                Expanded(
                  child: Text(
                    "Bugün güçlü hisset. Antrenmanını seç ve başla.",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          ...workouts.map((item) {
            final color = item[4] as Color;

            return Card(
              margin: const EdgeInsets.only(bottom: 14),
              child: ListTile(
                contentPadding: const EdgeInsets.all(14),
                leading: CircleAvatar(
                  radius: 27,
                  backgroundColor: color.withOpacity(0.18),
                  child: Icon(item[3] as IconData, color: color),
                ),
                title: Text(
                  item[0] as String,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(item[1] as String),
                ),
                trailing: Text(
                  item[2] as String,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
              ),
            );
          }),

          const SizedBox(height: 12),

          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.play_arrow),
            label: const Text("Antrenmana Başla"),
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
          ),
        ],
      ),
    );
  }
}
