import 'package:flutter/material.dart';
import 'package:instrumental/providers/practice_provider.dart';
import 'package:instrumental/screens/add_exercise_screen.dart';
import 'package:instrumental/widgets/exercise_execution_sheet.dart';
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
                  tileColor: exercise.isCompleted
                      ? Colors.green.withValues(alpha: 0.2)
                      : null,
                  leading: const Icon(Icons.timer),
                  title: Text(exercise.title),
                  subtitle: Text('Duration: ${exercise.durationMinutes} min'),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (sheetContext) => ExerciseExecutionSheet(
                        exercise: exercise,
                        onComplete: () async {
                          Navigator.pop(sheetContext);

                          int? statValue;

                          if (exercise.statisticName != null) {
                            statValue = await _showStatisticPrompt(
                              context,
                              exercise.statisticName!,
                            );
                          }

                          if (context.mounted) {
                            context.read<PracticeProvider>().completeExercise(
                              routineId,
                              exercise.id,
                              statValue: statValue,
                            );
                          }
                        },
                      ),
                    );
                  },
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

  Future<int?> _showStatisticPrompt(BuildContext context, String statisticName) async {
    final controller = TextEditingController();

    return showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Enter $statisticName'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: 'Enter $statisticName'),
            autofocus: true
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Skip'),
            ),
            ElevatedButton(
              onPressed: () {
                final value = int.tryParse(controller.text);
                Navigator.pop(context, value);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}