import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/ai_recommendation.dart';
import '../utils/app_colors.dart';

class RecommendationDetailScreen extends StatefulWidget {
  final String type;
  final AiRecommendation recommendation;

  const RecommendationDetailScreen({
    super.key,
    required this.type,
    required this.recommendation,
  });

  @override
  State<RecommendationDetailScreen> createState() =>
      _RecommendationDetailScreenState();
}

class _RecommendationDetailScreenState
    extends State<RecommendationDetailScreen> {
  late VideoPlayerController _videoController;
  final Set<int> _completedIndexes = {};
  bool _videoReady = false;

  @override
  void initState() {
    super.initState();

    _videoController = VideoPlayerController.asset(_videoPath())
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {
          _videoReady = true;
        });
        _videoController
          ..setLooping(true)
          ..setVolume(0)
          ..play();
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  String _videoPath() {
    if (widget.type == 'exercise') return 'assets/videos/fitness.mp4';
    if (widget.type == 'nutrition') return 'assets/videos/nutrition.mp4';
    return 'assets/videos/yoga.mp4';
  }

  String _title() {
    if (widget.type == 'exercise') return widget.recommendation.exerciseTitle;
    if (widget.type == 'nutrition') return widget.recommendation.nutritionTitle;
    return widget.recommendation.yogaTitle;
  }

  String _summary() {
    if (widget.type == 'exercise') return widget.recommendation.exerciseSummary;
    if (widget.type == 'nutrition') {
      return widget.recommendation.nutritionSummary;
    }
    return widget.recommendation.yogaSummary;
  }

  IconData _icon() {
    if (widget.type == 'exercise') return Icons.fitness_center;
    if (widget.type == 'nutrition') return Icons.restaurant;
    return Icons.self_improvement;
  }

  Color _color() {
    if (widget.type == 'exercise') return AppColors.coral;
    if (widget.type == 'nutrition') return AppColors.neon;
    return AppColors.rose;
  }

  List<String> _items() {
    if (widget.type == 'exercise') return widget.recommendation.exercises;
    if (widget.type == 'nutrition') return widget.recommendation.meals;
    return widget.recommendation.yogaMoves;
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    final items = _items();

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(backgroundColor: AppColors.black, title: Text(_title())),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _videoHero(color),
          const SizedBox(height: 18),
          _summaryCard(color),
          const SizedBox(height: 18),
          ...List.generate(items.length, (index) {
            return _planCard(index: index, text: items[index], color: color);
          }),
        ],
      ),
    );
  }

  Widget _videoHero(Color color) {
    return Container(
      height: 330,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_videoReady)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoController.value.size.width,
                height: _videoController.value.size.height,
                child: VideoPlayer(_videoController),
              ),
            )
          else
            Center(child: CircularProgressIndicator(color: color)),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.55),
                  Colors.transparent,
                  Colors.black.withOpacity(0.75),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          Positioned(
            top: 18,
            left: 18,
            child: CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.5),
              child: Icon(_icon(), color: color),
            ),
          ),

          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _miniInfo(Icons.local_fire_department, 'AI Plan'),
                    const SizedBox(width: 10),
                    _miniInfo(Icons.timer, '20-35 dk'),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Start Plan',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 44,
                        height: 44,
                        margin: const EdgeInsets.only(right: 2),
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            _videoController.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: color,
                          ),
                          onPressed: () {
                            setState(() {
                              if (_videoController.value.isPlaying) {
                                _videoController.pause();
                              } else {
                                _videoController.play();
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniInfo(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 15),
          const SizedBox(width: 5),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _summaryCard(Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        _summary().isEmpty
            ? 'Profil bilgilerine göre kişisel plan oluşturuldu.'
            : _summary(),
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 15,
          height: 1.45,
        ),
      ),
    );
  }

  Widget _planCard({
    required int index,
    required String text,
    required Color color,
  }) {
    final completed = _completedIndexes.contains(index);

    return GestureDetector(
      onTap: () {
        setState(() {
          completed
              ? _completedIndexes.remove(index)
              : _completedIndexes.add(index);
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 13),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: completed ? color : Colors.white10),
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(_icon(), color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: completed ? Colors.white38 : Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  decoration: completed ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: completed ? color : Colors.transparent,
                border: Border.all(color: color, width: 2),
              ),
              child: completed
                  ? const Icon(Icons.check, size: 17, color: Colors.black)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
