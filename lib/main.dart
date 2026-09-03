import 'package:flutter/material.dart';
import 'package:instrumental/providers/practice_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => PracticeProvider(),
      child: const InstrumentalApp()
    ));
}

class InstrumentalApp extends StatelessWidget {
  const InstrumentalApp({ super.key });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Instrumental',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark
          ),
          useMaterial3: true,
      ),
      home: const Placeholder()
    );
  }
}