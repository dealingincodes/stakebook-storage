import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'services/storage_service.dart';
import 'state/stakebook_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final provider = StakebookProvider(StorageService());
  await provider.load(); // never throws; empty state if missing/corrupt
  runApp(ChangeNotifierProvider.value(
    value: provider,
    child: const StakebookApp(),
  ));
}

class StakebookApp extends StatelessWidget {
  const StakebookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stakebook',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const HomeScreen(),
    );
  }
}
