import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'config/app_config.dart';
import 'screens/home_screen.dart';

/// Entry point aplikasi.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Memuat konfigurasi dari file .env.
  await dotenv.load(fileName: '.env');

  // Memeriksa konfigurasi aplikasi.
  if (!AppConfig.isConfigured()) {
    print('Konfigurasi .env tidak lengkap.');
  }

  // Menjalankan aplikasi.
  runApp(const MyApp());
}

/// Widget utama aplikasi.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RPL & Keamanan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
