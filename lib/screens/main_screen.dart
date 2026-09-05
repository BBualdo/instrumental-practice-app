import 'package:flutter/material.dart';
import 'package:instrumental/screens/exercise_list_screen.dart';
import 'package:instrumental/screens/routine_list_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<StatefulWidget> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const RoutineListScreen(),
    const ExerciseListScreen(),
    const Center(child: Text('StatisticsScreen - TBD')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Routines'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Exercises'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
        ]
      )
    );
  }
}