import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/farm_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // بعد إعداد Supabase: أزل التعليق واستورد supabase_flutter و AppConfig.
  // await Supabase.initialize(url: AppConfig.supabaseUrl, anonKey: AppConfig.supabaseAnonKey);
  runApp(const MazraatiApp());
}

class MazraatiApp extends StatelessWidget {
  const MazraatiApp({super.key});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF2F7D46);
    return MaterialApp(
      title: 'مزرعتي',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: green, brightness: Brightness.light),
        scaffoldBackgroundColor: const Color(0xFFF4F7EA),
        textTheme: GoogleFonts.cairoTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2F7D46),
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: const FarmScreen(),
    );
  }
}
