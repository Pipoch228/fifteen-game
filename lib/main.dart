import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/storage_service.dart';
import 'services/game_state.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  final storage = StorageService();
  await storage.init();

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: storage),
        ChangeNotifierProvider(create: (_) => GameState(storage)),
      ],
      child: const FifteenGameApp(),
    ),
  );
}

class FifteenGameApp extends StatelessWidget {
  const FifteenGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Пятнашки',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2196F3)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
