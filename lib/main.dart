import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app/theme/app_theme.dart';
import 'data/repositories/api_repository.dart';
import 'features/auth/views/role_selection_screen.dart';
import 'features/dashboard/views/dashboard_screen.dart';
import 'features/splash/splash_screen.dart';

void main() async {
  // Ensure widget bindings are initialized before calling async methods
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Warning: Could not load .env file: $e");
  }

  runApp(
    ChangeNotifierProvider<ApiRepository>(
      create: (_) => ApiRepository(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emantran',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AppEntryPoint(),
    );
  }
}

class AppEntryPoint extends StatefulWidget {
  const AppEntryPoint({super.key});

  @override
  State<AppEntryPoint> createState() => _AppEntryPointState();
}

class _AppEntryPointState extends State<AppEntryPoint> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return SplashScreen(
        onFinished: () {
          if (mounted) {
            setState(() {
              _showSplash = false;
            });
          }
        },
      );
    }

    final repo = Provider.of<ApiRepository>(context);
    final hasSession = repo.token != null && repo.currentUser != null;

    if (hasSession) {
      return const DashboardScreen();
    }
    return const RoleSelectionScreen();
  }
}
