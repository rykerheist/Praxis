import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'router.dart';
import 'theme.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  runApp(const ProviderScope(child: PraxisApp()));
}

class PraxisApp extends ConsumerWidget {
  const PraxisApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Praxis',
      theme: PraxisTheme.themeData,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            // The "Grain" Overlay
            IgnorePointer(
              child: Opacity(
                opacity: 0.04, // Subtle
                child: Image.asset(
                  'assets/textures/noise_grain.png',
                  fit: BoxFit.cover,
                  repeat: ImageRepeat.repeat,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback so app doesn't crash without the asset
                    return const SizedBox.shrink(); 
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
