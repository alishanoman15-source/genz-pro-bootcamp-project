import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Status bar styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  await Hive.initFlutter();
  await Hive.openBox('authBox');
  
  runApp(const GenZProApp());
}

class GenZProApp extends StatelessWidget {
  const GenZProApp({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('authBox');
    final userId = box.get('user_id');
    
    return MaterialApp(
      title: 'GenZ Pro – NTIRC',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: userId != null ? const DashboardScreen() : const HomeScreen(),
    );
  }
}
