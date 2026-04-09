import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'core/di/injection_container.dart' as di;
import 'features/auth/logic/auth_cubit.dart';
import 'features/auth/presentation/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (only on supported platforms)
  try {
    // Firebase only works on Android, iOS, Web, macOS
    if (kIsWeb || Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
      await Firebase.initializeApp();
    } else {
      // On Linux/Windows Desktop: Skip Firebase (use Dev Mode instead)
      debugPrint('⚠️ Firebase not initialized on ${Platform.operatingSystem}. Using Dev Mode.');
    }
  } catch (e) {
    debugPrint('⚠️ Firebase initialization failed: $e');
  }

  // Initialize dependencies
  await di.initDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<AuthCubit>(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Libya Medical',
        theme: lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
