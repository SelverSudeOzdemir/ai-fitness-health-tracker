import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../utils/app_colors.dart';
import '../providers/gym_location_provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GymLocationProvider _gymProvider;
  bool _isLocationPermissionDenied = false;
  Position? _currentPosition;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _gymProvider = context.read<GymLocationProvider>();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
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

        // Mevcut konuma harita kamerasını kaydır
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
        );

        // Salonları API'den çek
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
                Set<Marker> markers = gymProvider.nearbyGyms.map((gym) {
                  return Marker(
                    markerId: MarkerId(gym.id.toString()),
                    position: LatLng(gym.latitude, gym.longitude),
                    infoWindow: InfoWindow(
                      title: gym.name,
                      snippet: gym.address,
                    ),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed,
                    ),
                  );
                }).toSet();

                Set<Circle> circles = {
                  Circle(
                    circleId: const CircleId("search_area"),
                    center: LatLng(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                    ),
                    radius: gymProvider.searchRadius * 1000,
                    fillColor: AppColors.neon.withOpacity(0.1),
                    strokeColor: AppColors.neon,
                    strokeWidth: 2,
                  ),
                };

                return Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.4,
                      child: GoogleMap(
                        onMapCreated: (controller) =>
                            _mapController = controller,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            _currentPosition!.latitude,
                            _currentPosition!.longitude,
                          ),
                          zoom: 12.0,
                        ),
                        markers: markers,
                        circles: circles,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                      ),
                    ),

                    Expanded(
                      child: ListView(
                        children: [
                          _buildRadiusSlider(),

                          if (gymProvider.isLoading)
                            const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.neon,
                              ),
                            )
                          else if (gymProvider.error != null)
                            _buildErrorCard(gymProvider.error!)
                          else if (gymProvider.nearbyGyms.isEmpty)
                            _buildEmptyState()
                          else
                            _buildGymList(gymProvider),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  // Yardımcı Küçük Widget Tasarımları (Kod karmaşasını önlemek için aşağıya topladım)
  Widget _buildErrorCard(String error) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        color: AppColors.coral.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Hata: $error',
            style: const TextStyle(
              color: AppColors.coral,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.location_off, size: 64, color: AppColors.purple),
          SizedBox(height: 16),
          Text(
            'Yakın çevrede spor salonu bulunamadı',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildGymList(GymLocationProvider gymProvider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${gymProvider.nearbyGyms.length} Spor Salonu Bulundu',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: gymProvider.nearbyGyms.length,
            itemBuilder: (context, index) {
              final gym = gymProvider.nearbyGyms[index];
              final distance = gymProvider.calculateDistance(gym);
              return _buildGymCard(
                gym,
                distance,
                gymProvider.isGymFavorited(gym.id),
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GymDetailsScreen(gym: gym),
                    ),
                  );
                },
              );
            },
          ),
        ],
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGymCard(
    dynamic gym,
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
                    onPressed: () {},
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
            ],
          ),
        ),
      ),
    );
  }
}

class GymDetailsScreen extends StatelessWidget {
  final dynamic gym;
  const GymDetailsScreen({super.key, required this.gym});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(gym.name),
        backgroundColor: AppColors.neon,
        foregroundColor: AppColors.black,
      ),
      body: Center(child: Text('${gym.name} detay sayfası hazır.')),
    );
  }
}
