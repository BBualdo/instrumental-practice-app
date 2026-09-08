import 'package:flutter/material.dart';
import 'package:instrumental/providers/practice_provider.dart';
import 'package:instrumental/screens/routine_exercise_selection_screen.dart';
import 'package:instrumental/widgets/exercise_execution_sheet.dart';
import 'package:provider/provider.dart';

class RoutineDetailsScreen extends StatelessWidget {
  final String routineId;

  const RoutineDetailsScreen({super.key, required this.routineId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PracticeProvider>();
    final routine = provider.getRoutineById(routineId);
    final exercises = provider.getExercisesForRoutine(routineId);

    final isRoutineCompleted =
        exercises.isNotEmpty &&
        exercises.every((exercise) => exercise.isCompleted);

    return Scaffold(
      appBar: AppBar(
        title: Text(routine.title),
        actions: [
          IconButton(
            onPressed: () {
              context.read<PracticeProvider>().resetRoutine(routineId);
            },
            icon: Icon(Icons.restart_alt),
            tooltip: 'Reset Progress',
          ),
        ],
      ),
      body: exercises.isEmpty
          ? const Center(child: Text('No exercises yet. Add your first!'))
          : ReorderableListView.builder(
              itemCount: exercises.length,
              onReorderItem: (oldIndex, newIndex) {
                context.read<PracticeProvider>().reorderExercises(
                  routineId,
                  oldIndex,
                  newIndex,
                );
              },
              itemBuilder: (context, index) {
                final exercise = exercises[index];

                return ListTile(
                  key: ValueKey(exercise.id),
                  tileColor: exercise.isCompleted
                      ? Colors.green.withValues(alpha: 0.2)
                      : null,
                  leading: const Icon(Icons.drag_handle),
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
                              exercise.id,
                              statValue: statValue,
                              routineId: routine.id,
                            );
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: isRoutineCompleted
          ? FloatingActionButton.extended(
              onPressed: () {
                context.read<PracticeProvider>().resetRoutine(routine.id);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Routine finished! Good job!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              backgroundColor: Colors.green,
              icon: const Icon(Icons.done_all),
              label: const Text('Finish Routine'),
            )
          : FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RoutineExerciseSelectionScreen(routineId: routineId),
                  ),
                );
              },
              child: const Icon(Icons.edit),
            ),
    );
  }

  Future<int?> _showStatisticPrompt(
    BuildContext context,
    String statisticName,
  ) async {
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
            autofocus: true,
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
