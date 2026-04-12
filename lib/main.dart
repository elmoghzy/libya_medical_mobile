import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';
import 'core/di/injection_container.dart' as di;
import 'core/localization/app_localizations.dart';
import 'core/localization/locale_cubit.dart';
import 'features/auth/logic/auth_cubit.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/queue/logic/clinic_queue_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (only on supported platforms)
  try {
    // Firebase only works on Android, iOS, Web, macOS
    if (kIsWeb || Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
      await Firebase.initializeApp();
    } else {
      // On Linux/Windows Desktop: Skip Firebase (use Dev Mode instead)
      debugPrint(
        '⚠️ Firebase not initialized on ${Platform.operatingSystem}. Using Dev Mode.',
      );
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthCubit>()),
        BlocProvider(create: (_) => di.sl<LocaleCubit>()),
        BlocProvider.value(value: di.sl<ClinicQueueCubit>()),
      ],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            onGenerateTitle: (context) => context.l10n.tr('appName'),
            theme: lightTheme,
            locale: locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: (deviceLocale, supportedLocales) {
              if (deviceLocale == null) {
                return const Locale('en');
              }

              for (final supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == deviceLocale.languageCode) {
                  return supportedLocale;
                }
              }

              return const Locale('en');
            },
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
