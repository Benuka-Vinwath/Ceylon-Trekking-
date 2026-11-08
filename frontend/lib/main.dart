import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'features/auth/auth_screens.dart';

void main() => runApp(const CeylonTrekkingApp());

class CeylonTrekkingApp extends StatelessWidget {
  const CeylonTrekkingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ceylon Trekking',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashScreen(),
    );
  }
}
