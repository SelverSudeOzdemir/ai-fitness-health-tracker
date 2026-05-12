import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../utils/app_colors.dart';
import '../providers/gym_location_provider.dart';
import '../services/gym_location_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GymLocationProvider _gymProvider;
  bool _isLocationPermissionDenied = false;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _gymProvider = context.read<GymLocationProvider>();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLocationPermissionDenied = true;
        });
        return;
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
        );

        setState(() {
          _currentPosition = position;
        });

        // Fetch nearby gyms
        _gymProvider.fetchNearbyGyms(
          position.latitude,
          position.longitude,
          radius: _gymProvider.searchRadius,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Konum alınamadı: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'EN YAKIN SPOR SALONLARI',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0),
        ),
        backgroundColor: AppColors.neon,
        foregroundColor: AppColors.black,
        elevation: 0,
      ),
      body: _isLocationPermissionDenied
          ? _buildLocationPermissionDenied()
          : _currentPosition == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.neon),
            )
          : Consumer<GymLocationProvider>(
              builder: (context, gymProvider, _) {
                return ListView(
                  children: [
                    // Location Info Card
                    _buildLocationCard(),

                    // Search Radius Slider
                    _buildRadiusSlider(),

                    // Nearby Gyms List
                    if (gymProvider.isLoading)
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(color: AppColors.neon),
                      )
                    else if (gymProvider.error != null)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Card(
                          color: AppColors.coral.withOpacity(0.1),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'Hata: ${gymProvider.error}',
                              style: const TextStyle(
                                color: AppColors.coral,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      )
                    else if (gymProvider.nearbyGyms.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: const [
                            Icon(
                              Icons.location_off,
                              size: 64,
                              color: AppColors.purple,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Yakın çevrede spor salonu bulunamadı',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${gymProvider.nearbyGyms.length} Spor Salonu Bulundu',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: gymProvider.nearbyGyms.length,
                              itemBuilder: (context, index) {
                                final gym = gymProvider.nearbyGyms[index];
                                final distance = gymProvider.calculateDistance(
                                  gym,
                                );

                                return _buildGymCard(
                                  gym,
                                  distance,
                                  gymProvider.isGymFavorited(gym.id),
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            GymDetailsScreen(gym: gym),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildLocationPermissionDenied() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_off, size: 80, color: AppColors.coral),
          const SizedBox(height: 24),
          const Text(
            'Konum İzni Gerekli',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'En yakın spor salonlarını görmek için lütfen konum izni verin.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Geolocator.openLocationSettings(),
            icon: const Icon(Icons.settings),
            label: const Text('Ayarları Aç'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neon,
              foregroundColor: AppColors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [AppColors.purple, AppColors.rose],
          ),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.location_on, color: AppColors.white),
                SizedBox(width: 12),
                Text(
                  'Mevcut Konumunuz',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Lat: ${_currentPosition?.latitude.toStringAsFixed(4)}, Lng: ${_currentPosition?.longitude.toStringAsFixed(4)}',
              style: const TextStyle(color: AppColors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadiusSlider() {
    return Consumer<GymLocationProvider>(
      builder: (context, gymProvider, _) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Arama Yarıçapı',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.neon.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${gymProvider.searchRadius.toStringAsFixed(1)} km',
                        style: const TextStyle(
                          color: AppColors.neon,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Slider(
                  value: gymProvider.searchRadius,
                  min: 1,
                  max: 50,
                  divisions: 49,
                  activeColor: AppColors.neon,
                  inactiveColor: Colors.grey.withOpacity(0.3),
                  onChanged: (value) {
                    gymProvider.updateSearchRadius(value);
                    if (_currentPosition != null) {
                      gymProvider.fetchNearbyGyms(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                        radius: value,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGymCard(
    Gym gym,
    double? distance,
    bool isFavorited,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gym.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (gym.address != null)
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  gym.address!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isFavorited ? Icons.favorite : Icons.favorite_border,
                      color: isFavorited ? AppColors.coral : Colors.grey,
                    ),
                    onPressed: () {
                      // Handle favorite action
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (distance != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.neon.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${distance.toStringAsFixed(1)} km',
                        style: const TextStyle(
                          color: AppColors.neon,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  if (gym.rating != null)
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '${gym.rating}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          ' (${gym.reviewCount})',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              if (gym.amenities != null && gym.amenities!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: gym.amenities!.take(3).map((amenity) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          amenity,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.purple,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Gym Details Screen
class GymDetailsScreen extends StatelessWidget {
  final Gym gym;

  const GymDetailsScreen({super.key, required this.gym});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          gym.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.neon,
        foregroundColor: AppColors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Gym Image
          if (gym.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                gym.imageUrl!,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: AppColors.lightBg,
                    ),
                    child: const Icon(
                      Icons.fitness_center,
                      size: 80,
                      color: AppColors.neon,
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 24),

          // Rating
          if (gym.rating != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 32),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${gym.rating}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${gym.reviewCount} yorum',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),

          // Details
          if (gym.description != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Açıklama',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  gym.description!,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
              ],
            ),

          // Contact Info
          _buildInfoCard(
            icon: Icons.phone,
            title: 'Telefon',
            content: gym.phone ?? 'Bilgi Yok',
            color: AppColors.purple,
          ),
          const SizedBox(height: 12),

          _buildInfoCard(
            icon: Icons.location_on,
            title: 'Adres',
            content: gym.address ?? 'Bilgi Yok',
            color: AppColors.purple,
          ),
          const SizedBox(height: 12),

          _buildInfoCard(
            icon: Icons.access_time,
            title: 'Çalışma Saatleri',
            content: gym.openingHours ?? 'Bilgi Yok',
            color: AppColors.purple,
          ),
          const SizedBox(height: 24),

          // Amenities
          if (gym.amenities != null && gym.amenities!.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Olanaklar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: gym.amenities!.map((amenity) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.neon.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        amenity,
                        style: const TextStyle(
                          color: AppColors.neon,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
