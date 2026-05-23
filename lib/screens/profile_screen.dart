import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ai_service.dart';
import '../utils/app_colors.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onProfileSaved;
  const ProfileScreen({super.key, this.onProfileSaved});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _healthController = TextEditingController();

  final List<String> _genders = const [
    'Kadın',
    'Erkek',
    'Belirtmek istemiyorum',
  ];
  final List<String> _goals = const [
    'Zayıflamak istiyorum',
    'Fit devam edeceğim',
    'Kilo almak istiyorum',
  ];

  String _selectedGender = 'Kadın';
  String _selectedGoal = 'Fit devam edeceğim';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final profile = AiService.lastProfile;
    if (profile != null) {
      _ageController.text = profile.age.toString();
      _healthController.text = profile.healthProblems;
      _selectedGender = _genders.contains(profile.gender)
          ? profile.gender
          : 'Kadın';
      _selectedGoal = _goals.contains(profile.goal)
          ? profile.goal
          : 'Fit devam edeceğim';
    }
  }

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _healthController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      await AiService.saveProfile(
        age: int.parse(_ageController.text.trim()),
        gender: _selectedGender,
        healthProblems: _healthController.text.trim(),
        goal: _selectedGoal,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil kaydedildi. AI önerileri güncellendi.'),
        ),
      );
      widget.onProfileSaved?.call();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profil kaydedilirken hata oluştu: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _profileHeader(),
              const SizedBox(height: 18),
              _sectionCard(
                title: 'Kişisel Bilgiler',
                icon: Icons.person_rounded,
                children: [
                  _label('Yaş'),
                  _numberField(_ageController, 'Örn: 22', requiredField: true),
                  const SizedBox(height: 14),
                  _label('Boy / Kilo'),
                  Row(
                    children: [
                      Expanded(
                        child: _numberField(_heightController, 'Boy cm'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _numberField(_weightController, 'Kilo kg'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _label('Cinsiyet'),
                  _dropdown(
                    _selectedGender,
                    _genders,
                        (v) => setState(() => _selectedGender = v),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _sectionCard(
                title: 'Sağlık ve Hedef',
                icon: Icons.health_and_safety_rounded,
                children: [
                  _label('Sağlık Sorunları'),
                  TextFormField(
                    controller: _healthController,
                    minLines: 3,
                    maxLines: 5,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration(
                      'Diz ağrısı, bel fıtığı, astım... Yoksa boş bırak.',
                    ),
                  ),
                  const SizedBox(height: 14),
                  _label('Hedef'),
                  _dropdown(
                    _selectedGoal,
                    _goals,
                        (v) => setState(() => _selectedGoal = v),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _goalPreview(),
              const SizedBox(height: 18),

              // 1. BUTON: PROFİLİ KAYDET
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neon,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: _isSaving ? null : _saveProfile,
                  icon: _isSaving
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                      : const Icon(Icons.auto_awesome_rounded),
                  label: Text(
                    _isSaving
                        ? 'AI modeli güncelleniyor...'
                        : 'Profili Kaydet ve AI Modelini Güncelle',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),

              // ENTEGRE EDİLEN KISIM: ÇIKIŞ YAP BUTONU
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () async {
                    await context.read<AuthProvider>().logout();

                    if (!mounted) return;

                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                          (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text(
                    'Çıkış Yap',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ... Diğer alt widget fonksiyonları (_profileHeader, _sectionCard, _inputDecoration vb.) aynen kalıyor.
  Widget _profileHeader() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.neon,
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: Colors.black,
            child: Icon(Icons.person_rounded, color: Colors.white, size: 38),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              'Profilini doldur, AI modelin sana özel egzersiz, beslenme ve yoga planı oluştursun.',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                height: 1.35,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.neon),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _goalPreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.purple.withOpacity(0.45),
            AppColors.rose.withOpacity(0.25),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.neon.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.flag_rounded, color: AppColors.neon, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Seçilen hedef: $_selectedGoal',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _numberField(
      TextEditingController controller,
      String hint, {
        bool requiredField = false,
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(hint),
      validator: requiredField
          ? (value) {
        final number = int.tryParse(value ?? '');
        if (number == null || number < 10 || number > 100) {
          return 'Geçerli değer gir.';
        }
        return null;
      }
          : null,
    );
  }

  Widget _dropdown(
      String value,
      List<String> items,
      ValueChanged<String> onChanged,
      ) {
    return DropdownButtonFormField<String>(
      value: items.contains(value) ? value : items.first,
      dropdownColor: const Color(0xFF1A1A1A),
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration('Seç'),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(value: item, child: Text(item)),
      )
          .toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38),
      filled: true,
      fillColor: Colors.black.withOpacity(0.35),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.purple.withOpacity(0.35)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.neon),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }
}