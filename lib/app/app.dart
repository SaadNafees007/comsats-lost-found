import 'package:flutter/material.dart';

class ComsatsLostFoundApp extends StatelessWidget {
  const ComsatsLostFoundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'COMSATS Lost & Found',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const Scaffold(
        body: Center(
          child: Text(
            'COMSATS Lost & Found',
          ),
        ),
      ),
    );
  }
}