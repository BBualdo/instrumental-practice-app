import 'package:flutter/material.dart';
import 'package:instrumental/providers/practice_provider.dart';
import 'package:provider/provider.dart';

class RoutineExerciseSelectionScreen extends StatelessWidget {
  final String routineId;

  const RoutineExerciseSelectionScreen({super.key, required this.routineId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PracticeProvider>();
    final routine = provider.getRoutineById(routineId);

    final availableExercises = provider.getAvailableExercisesForInstrument(
      routine.instrument,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Select Exercises')),
      body: availableExercises.isEmpty
          ? const Center(
              child: Text('No exercises available for this instrument.'),
            )
          : ListView.builder(
              itemCount: availableExercises.length,
              itemBuilder: (context, index) {
                final exercise = availableExercises[index];
                final isSelected = routine.exerciseIds.contains(exercise.id);

                return CheckboxListTile(
                  title: Text(exercise.title),
                  subtitle: Text('${exercise.durationMinutes} min'),
                  value: isSelected,
                  onChanged: (bool? newValue) {
                    context.read<PracticeProvider>().toggleExerciseInRoutine(routineId, exercise.id);
                  },
                );
              },
            ),
    );
  }
}
