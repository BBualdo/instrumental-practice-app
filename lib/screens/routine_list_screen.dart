import 'package:flutter/material.dart';
import 'package:instrumental/screens/add_exercise_screen.dart';
import 'package:instrumental/screens/add_routine_screen.dart';
import 'package:instrumental/screens/exercise_list_screen.dart';
import 'package:instrumental/screens/routine_details_screen.dart';
import 'package:instrumental/utils/capitalize_string.dart';
import 'package:provider/provider.dart';
import 'package:instrumental/providers/practice_provider.dart';

class RoutineListScreen extends StatelessWidget {
  const RoutineListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Routines'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Archived'),
            ],
          ),
        ),
        body: TabBarView(
          children: [_ActiveRoutinesTab(), _ArchivedRoutinesTab()],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddRoutineScreen()),
          ),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _ActiveRoutinesTab extends StatelessWidget {
  const _ActiveRoutinesTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PracticeProvider>();
    final routines = provider.activeRoutines;

    if (routines.isEmpty) {
      return Center(child: Text('No routines yet. Add your first!'));
    }

    return ListView.builder(
      itemCount: routines.length,
      itemBuilder: (context, index) {
        final routine = routines[index];

        return Dismissible(
          key: ValueKey(routine.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red.withValues(alpha: 0.2),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.archive, color: Colors.white),
          ),
          onDismissed: (direction) {
            context.read<PracticeProvider>().archiveRoutine(routine.id);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${routine.title} has been archived.')),
            );
          },
          child: ListTile(
            leading: Icon(
              routine.instrument.name == 'piano'
                  ? Icons.piano
                  : Icons.music_note,
            ),
            title: Text(routine.title),
            subtitle: Text(
              'Duration: ${provider.getTotalDurationForRoutine(routine.id)} min\nExercises: ${routine.exerciseIds.length}\nInstrument: ${capitalizeString(routine.instrument.name)}',
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RoutineDetailsScreen(routineId: routine.id)),
            ),
          ),
        );
      },
    );
  }
}

class _ArchivedRoutinesTab extends StatelessWidget {
  const _ArchivedRoutinesTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PracticeProvider>();
    final routines = provider.archivedRoutines;

    if (routines.isEmpty) {
      return Center(child: Text('No archived routines'));
    }

    return ListView.builder(
      itemCount: routines.length,
      itemBuilder: (context, index) {
        final routine = routines[index];
        return ListTile(
          title: Text(
            routine.title,
            style: const TextStyle(color: Colors.grey),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.restore, color: Colors.green),
                onPressed: () {
                  context.read<PracticeProvider>().restoreRoutine(routine.id);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${routine.title} has been restored.'),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                onPressed: () =>
                    _showDeleteDialog(context, routine.id, routine.title),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    String routineId,
    String routineTitle,
  ) {
    return showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Permanent Delete'),
        content: Text(
          'Are you sure you want to delete $routineTitle? It cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<PracticeProvider>().deleteRoutinePermanently(
                routineId,
              );

              ScaffoldMessenger.of(dialogContext).showSnackBar(
                SnackBar(content: Text('$routineTitle has been deleted.')),
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
