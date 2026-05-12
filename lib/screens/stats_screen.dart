import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "PROGRESS",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: const [
          Text(
            "Haftalık Performans",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 18),
          _ProgressItem(
            title: "Spor Hedefi",
            valueText: "4 / 5 gün",
            progress: 0.8,
            icon: Icons.fitness_center,
            color: AppColors.neon,
          ),
          _ProgressItem(
            title: "Kalori Yakımı",
            valueText: "1800 / 2500 kcal",
            progress: 0.72,
            icon: Icons.local_fire_department,
            color: AppColors.coral,
          ),
          _ProgressItem(
            title: "Su Tüketimi",
            valueText: "10 / 14 litre",
            progress: 0.7,
            icon: Icons.water_drop,
            color: AppColors.purple,
          ),
          _ProgressItem(
            title: "Uyku Düzeni",
            valueText: "6 / 7 gün",
            progress: 0.85,
            icon: Icons.bedtime,
            color: AppColors.rose,
          ),
        ],
      ),
    );
  }
}

class _ProgressItem extends StatelessWidget {
  final String title;
  final String valueText;
  final double progress;
  final IconData icon;
  final Color color;

  const _ProgressItem({
    required this.title,
    required this.valueText,
    required this.progress,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                Text(valueText),
              ],
            ),
            const SizedBox(height: 14),
            LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              backgroundColor: Colors.grey.withOpacity(0.2),
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
          ],
        ),
      ),
    );
  }
}
