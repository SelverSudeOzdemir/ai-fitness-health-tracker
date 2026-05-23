import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'providers/item_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/gym_location_provider.dart';
import 'utils/app_colors.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ItemProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => GymLocationProvider()),
      ],
      child: MaterialApp(
        title: 'AI Fitness Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppColors.darkCard,
          primaryColor: AppColors.neon,
          colorScheme: ColorScheme.dark(
            primary: AppColors.neon,
            secondary: AppColors.purple,
            tertiary: AppColors.rose,
            error: AppColors.coral,
            surface: const Color(0xFF1A1A1A),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.darkCard,
            foregroundColor: AppColors.neon,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              color: AppColors.neon,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          cardTheme: CardThemeData(
            color: const Color(0xFF1A1A1A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF2A2A2A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.purple),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.purple, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.neon, width: 2),
            ),
            labelStyle: const TextStyle(color: AppColors.purple),
            hintStyle: TextStyle(color: Colors.grey[500]),
            prefixIconColor: AppColors.purple,
            suffixIconColor: AppColors.purple,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neon,
              foregroundColor: AppColors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: AppColors.neon),
          ),
          textTheme: const TextTheme(
            headlineLarge: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            headlineMedium: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            titleLarge: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            bodyLarge: TextStyle(fontSize: 16, color: Colors.white),
            bodyMedium: TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ),
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            if (authProvider.isLoggedIn) {
              return const DashboardScreen();
            } else {
              return const LoginScreen();
            }
          },
        ),
      ),
    );
  }
}
