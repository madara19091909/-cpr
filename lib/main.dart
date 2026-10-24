import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/farm_screen.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://bkwohueqglpgsdnznpgq.supabase.co',
    publishableKey: 'sb_publishable_mi0TItQF9bEphuN5lVr-ug_KNWPYoGf',
  );
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
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF2F7D46), foregroundColor: Colors.white, centerTitle: true),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) return const FarmScreen();
        return const LoginScreen();
      },
    );
  }
}
