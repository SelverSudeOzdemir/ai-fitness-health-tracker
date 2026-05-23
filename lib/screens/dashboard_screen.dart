import 'package:flutter/material.dart';
import '../models/ai_recommendation.dart';
import '../services/ai_service.dart';
import '../utils/app_colors.dart';
import 'profile_screen.dart';
import 'recommendation_detail_screen.dart';
import 'map_screen.dart';
import '../services/notification_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  bool _loading = false;
  AiRecommendation? _recommendation;

  @override
  void initState() {
    super.initState();
    _loadAiRecommendation();
  }

  Future<void> _loadAiRecommendation() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final data = await AiService.getRecommendation();
      if (!mounted) return;
      setState(() {
        _recommendation = data;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _recommendation = null;
        _loading = false;
      });
    }
  }

  void _openDetail(String type) {
    final r = _recommendation;
    if (r == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            RecommendationDetailScreen(type: type, recommendation: r),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        elevation: 0,
        title: const Text('AI Fitness Tracker'),
        actions: [
          // 🔔 YENİ: Anlık Bildirim Test Butonu
          IconButton(
            icon: const Icon(
              Icons.notifications_active_outlined,
              color: AppColors.neon,
            ),
            onPressed: () async {
              await NotificationService.showInstantNotification(
                id: 100,
                title: "Harika Gidiyorsun! 🔥",
                body:
                    "Bugünkü AI planına göz atmayı unutma, antrenman seni bekler!",
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.location_on_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MapScreen()),
            ),
          ),
        ],
      ),
      body: _selectedIndex == 0 ? _buildHome() : _buildProfile(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: const Color(0xFF1A1A1A),
        selectedItemColor: AppColors.neon,
        unselectedItemColor: Colors.grey,
        onTap: (i) {
          setState(() => _selectedIndex = i);
          if (i == 0) _loadAiRecommendation();
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildHome() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadAiRecommendation,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _heroCard(),
              const SizedBox(height: 18),
              _statsRow(),
              const SizedBox(height: 18),
              _mapPreviewCard(),
              const SizedBox(height: 22),
              // ESKİ HALİ: const Text('AI Destekli Planın', ...)
              // YENİ HALİ: Row yapısı ile yanına buton ekliyoruz
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'AI Destekli Planın',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      // Test amaçlı şimdiki zamandan 10 saniye sonrasına kuruyoruz
                      final reminderTime = DateTime.now().add(
                        const Duration(minutes: 30),
                      );

                      await NotificationService.scheduleNotification(
                        id: 200,
                        title: "Su İçmeyi Unutma! 💧",
                        body:
                            "Vücudunun hidrasyon seviyesini korumak için kocaman bir bardak su içmeye ne dersin?",
                        scheduledTime: reminderTime,
                      );

                      // Kullanıcıya bilgi vermek için küçük bir pop-up (SnackBar)
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Yarım saat sonra su içme hatırlatıcısı gönderilecek! 💧",
                            ),
                            backgroundColor: AppColors.purple,
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                    icon: const Icon(
                      Icons.alarm_add_rounded,
                      size: 18,
                      color: Colors.blue,
                    ),
                    label: const Text('Hatırlatıcısı Kur'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const SizedBox(height: 12),
              if (_loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_recommendation == null)
                _profileRequiredCard()
              else
                Column(
                  children: [
                    _planCard(
                      title: _recommendation!.exerciseTitle,
                      subtitle: _recommendation!.exerciseSummary,
                      icon: Icons.fitness_center_rounded,
                      color: AppColors.coral,
                      badge: 'Video alanı hazır',
                      onTap: () => _openDetail('exercise'),
                    ),
                    const SizedBox(height: 14),
                    _planCard(
                      title: _recommendation!.nutritionTitle,
                      subtitle: _recommendation!.nutritionSummary,
                      icon: Icons.restaurant_rounded,
                      color: AppColors.neon,
                      badge: '3 öğün plan',
                      onTap: () => _openDetail('nutrition'),
                    ),
                    const SizedBox(height: 14),
                    _planCard(
                      title: _recommendation!.yogaTitle,
                      subtitle: _recommendation!.yogaSummary,
                      icon: Icons.self_improvement_rounded,
                      color: AppColors.rose,
                      badge: 'Nefes + akış',
                      onTap: () => _openDetail('yoga'),
                    ),
                  ],
                ),
              const SizedBox(height: 24),
              _dailyChallengeCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.neon,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bugünün planı hazır',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'AI modelin profil verilerine göre egzersiz, beslenme ve yoga önerisi oluşturur.',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsRow() {
    return Row(
      children: [
        _miniStat('Adım', '8.2K', Icons.directions_walk_rounded),
        const SizedBox(width: 10),
        _miniStat('Kalori', '450', Icons.local_fire_department_rounded),
        const SizedBox(width: 10),
        _miniStat('Süre', '45 dk', Icons.timer_rounded),
      ],
    );
  }

  Widget _miniStat(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.neon),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mapPreviewCard() {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MapScreen()),
      ),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.neon.withOpacity(0.35)),
        ),
        child: Row(
          children: const [
            Icon(Icons.map_rounded, color: AppColors.neon, size: 38),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Yakındaki Spor Salonları',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Harita, favori salonlar ve rota alanı hazır.',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.neon,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileRequiredCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.redAccent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AI önerisi için profil gerekli',
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Yaş, cinsiyet, sağlık sorunu ve hedefini kaydet.',
            style: TextStyle(color: Colors.grey, fontSize: 15),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neon,
              foregroundColor: Colors.black,
            ),
            onPressed: () => setState(() => _selectedIndex = 1),
            child: const Text('Profile Git'),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _planCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String badge,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: color.withOpacity(0.55)),
        ),
        child: Row(
          children: [
            Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(icon, color: color, size: 34),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle.isEmpty
                        ? 'Profil bilgilerine göre öneri hazırlandı.'
                        : subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 9),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white54,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _dailyChallengeCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.purple.withOpacity(0.45),
            AppColors.rose.withOpacity(0.25),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: const Row(
        children: [
          Icon(Icons.emoji_events_rounded, color: AppColors.neon, size: 34),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'Günün hedefi: Planındaki ilk egzersizi tamamla ve 2 litre su iç.',
              style: TextStyle(color: Colors.white, fontSize: 15, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfile() {
    return ProfileScreen(
      onProfileSaved: () async {
        setState(() => _selectedIndex = 0);
        await _loadAiRecommendation();
      },
    );
  }
}
