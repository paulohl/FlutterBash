import 'package:easy_localization/easy_localization.dart';
import 'package:easy_nav/easy_nav.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:xueli/ui/splash_screen.dart';

import 'data/providers/shared_prefs_provider.dart';
import 'generated/codegen_loader.g.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Supabase.initialize(
    url: dotenv.env["DATABASE_URL"]!,
    anonKey: dotenv.env["API_KEY"]!,
  );
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  runApp(EasyLocalization(
    supportedLocales: const [Locale('en'), Locale('zh')],
    path: 'resources/langs',
    assetLoader: const CodegenLoader(),
    child: ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences)
      ],
      child: const MyApp(),
    ),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      title: 'Xueli',
      navigatorKey: EasyNav.navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        dialogBackgroundColor: Colors.white,
        useMaterial3: false,
      ),
      home: const SplashScreen(),
    );
  }
}
