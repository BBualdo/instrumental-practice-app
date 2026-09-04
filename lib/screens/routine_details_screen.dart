import 'package:flutter/material.dart';
import 'package:instrumental/providers/practice_provider.dart';
import 'package:instrumental/screens/add_exercise_screen.dart';
import 'package:provider/provider.dart';

class RoutineDetailsScreen extends StatelessWidget {
  final String routineId;

  const RoutineDetailsScreen({super.key, required this.routineId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PracticeProvider>();
    final routine = provider.routines.firstWhere(
      (routine) => routine.id == routineId,
    );

    return Scaffold(
      appBar: AppBar(title: Text(routine.title)),
      body: routine.exercises.isEmpty
          ? const Center(child: Text('No exercises yet. Add your first!'))
          : ListView.builder(
              itemCount: routine.exercises.length,
              itemBuilder: (context, index) {
                final exercise = routine.exercises[index];

                return ListTile(
                  leading: const Icon(Icons.timer),
                  title: Text(exercise.title),
                  subtitle: Text('Duration: ${exercise.durationMinutes} min'),
                  trailing: exercise.statisticName != null
                      ? const Icon(Icons.bar_chart, size: 16)
                      : const SizedBox.shrink(),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddExerciseScreen(routineId: routineId),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
