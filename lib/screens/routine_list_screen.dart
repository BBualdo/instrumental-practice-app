import 'package:flutter/material.dart';
import 'package:instrumental/screens/add_routine_screen.dart';
import 'package:instrumental/screens/routine_details_screen.dart';
import 'package:provider/provider.dart';
import 'package:instrumental/providers/practice_provider.dart';

class RoutineListScreen extends StatelessWidget {
  const RoutineListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Routines')),
      body: Consumer<PracticeProvider>(
        builder: (context, provider, _) {
          final routines = provider.routines;

          if (routines.isEmpty) {
            return const Center(
              child: Text('No routines yet. Build your first one!'),
            );
          }

          return ListView.builder(
            itemCount: routines.length,
            itemBuilder: (context, index) {
              final routine = routines[index];

              return ListTile(
                leading: const Icon(Icons.library_music),
                title: Text(routine.title),
                subtitle: Text(
                  'Instrument: ${routine.instrument.name} | Exercises: ${routine.exercises.length}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          RoutineDetailsScreen(routineId: routine.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddRoutineScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
