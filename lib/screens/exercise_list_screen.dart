import 'package:flutter/material.dart';
import 'package:instrumental/screens/add_exercise_screen.dart';
import 'package:provider/provider.dart';
import 'package:instrumental/providers/practice_provider.dart';

class ExerciseListScreen extends StatelessWidget {
  const ExerciseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PracticeProvider>();
    final exercises = provider.activeExercises;

    return Scaffold(
      appBar: AppBar(title: const Text('My Exercises')),
      body: exercises.isEmpty
          ? Center(child: Text('No exercises yet. Add your first!'))
          : ListView.builder(
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final exercise = exercises[index];

                return Dismissible(
                  key: ValueKey(exercise.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red.withValues(alpha: 0.2),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.archive, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    context.read<PracticeProvider>().archiveExercise(
                      exercise.id,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${exercise.title} has been archived.'),
                      ),
                    );
                  },
                  child: ListTile(
                    leading: Icon(
                      exercise.instrument.name == 'piano'
                          ? Icons.piano
                          : Icons.music_note,
                    ),
                    title: Text(exercise.title),
                    subtitle: Text(
                      '${exercise.durationMinutes} min | Instrument: ${exercise.instrument.name}',
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddExerciseScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
