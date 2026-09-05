import 'package:flutter/material.dart';
import 'package:instrumental/screens/add_exercise_screen.dart';
import 'package:provider/provider.dart';
import 'package:instrumental/providers/practice_provider.dart';

class ExerciseListScreen extends StatelessWidget {
  const ExerciseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Exercises'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Archived'),
            ],
          ),
        ),
        body: TabBarView(
          children: [_ActiveExercisesTab(), _ArchivedExercisesTab()],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddExerciseScreen()),
          ),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _ActiveExercisesTab extends StatelessWidget {
  const _ActiveExercisesTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PracticeProvider>();
    final exercises = provider.activeExercises;

    if (exercises.isEmpty) {
      return Center(child: Text('No exercises yet. Add your first!'));
    }

    return ListView.builder(
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
            context.read<PracticeProvider>().archiveExercise(exercise.id);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${exercise.title} has been archived.')),
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
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    AddExerciseScreen(exerciseToEdit: exercise),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ArchivedExercisesTab extends StatelessWidget {
  const _ArchivedExercisesTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PracticeProvider>();
    final exercises = provider.archivedExercises;

    if (exercises.isEmpty) {
      return Center(child: Text('No archived exercises'));
    }

    return ListView.builder(
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        return ListTile(
          title: Text(
            exercise.title,
            style: const TextStyle(color: Colors.grey),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.restore, color: Colors.green),
                onPressed: () {
                  context.read<PracticeProvider>().restoreExercise(exercise.id);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${exercise.title} has been restored.'),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                onPressed: () =>
                    _showDeleteDialog(context, exercise.id, exercise.title),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    String exerciseId,
    String exerciseTitle,
  ) {
    return showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Permanent Delete'),
        content: Text(
          'Are you sure you want to delete $exerciseTitle? It cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<PracticeProvider>().deleteExercisePermanently(
                exerciseId,
              );
              
              ScaffoldMessenger.of(dialogContext).showSnackBar(
                SnackBar(content: Text('$exerciseTitle has been deleted.'))
              );
              Navigator.pop(dialogContext);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
