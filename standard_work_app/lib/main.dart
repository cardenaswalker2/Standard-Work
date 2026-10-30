import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/services/standard_work_provider.dart';
import 'features/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar barra de estado transparente y estilo de iconos claro
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => StandardWorkProvider()..init(),
        ),
      ],
      child: const StandardWorkApp(),
    ),
  );
}

class StandardWorkApp extends StatelessWidget {
  const StandardWorkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Standard Work · Darnel Group',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
