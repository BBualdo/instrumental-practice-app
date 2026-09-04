import 'package:flutter/material.dart';
import 'package:instrumental/models/exercise.dart';
import 'package:instrumental/models/instrument.dart';
import 'package:instrumental/models/routine.dart';

class PracticeProvider extends ChangeNotifier {
  final List<Exercise> _exercises = [];
  final List<Routine> _routines = [];

  PracticeProvider() {
    _seedExampleData();
  }

  List<Exercise> get exercises => _exercises;

  List<Exercise> get activeExercises => _exercises.where((exercise) => exercise.isActive).toList();

  List<Routine> get routines => _routines;

  void addExercise(String title, String description, int durationMinutes, String? relatedLink, String? statisticName) {
    final newExercise = Exercise(
      id: DateTime.now().toString(),
      title: title,
      description: description,
      durationMinutes: durationMinutes,
      relatedLink: relatedLink,
      statisticName: statisticName,
    );
  
    _exercises.add(newExercise);
    notifyListeners();
  }

  void archiveExercise(String id) {
    final index = _exercises.indexWhere((exercise) => exercise.id == id);
    if (index != -1) {
      _exercises[index].isActive = false;
      notifyListeners();
    }
  }

  void addRoutine(String title, Instrument instrument, List<Exercise> exercises) {
    final newRoutine = Routine(
      id: DateTime.now().toString(), 
      title: title, 
      instrument: instrument,
      exercises: exercises,
      );

    _routines.add(newRoutine);
    notifyListeners();
  }

  void addExerciseToRoutine({
    required String routineId,
    required String title,
    required int duration,
    String? description,
    String? relatedLink,
    String? statisticName,
  }) {
    final newExercise = Exercise(
      id: DateTime.now().toString(),
      title: title,
      description: description?.isEmpty == true ? null : description,
      durationMinutes: duration,
      relatedLink: relatedLink?.isEmpty == true ? null : relatedLink,
      statisticName: statisticName?.isEmpty == true ? null : statisticName,
    );

    _exercises.add(newExercise);

    final routine = _routines.firstWhere((routine) => routine.id == routineId);
    routine.exercises.add(newExercise);

    notifyListeners();
  }
 
  void _seedExampleData() {
    _exercises.addAll([
      Exercise(
        id: 'e1',
        title: 'One Minute Changes: Am - D',  
        description: 'Play them as fast as you can in one minute.',
        durationMinutes: 1,
        statisticName: 'Chord Changes'
      ),
      Exercise(
        id: 'e2',
        title: 'One Minute Changes: C - G',
        description: 'Play them as fast as you can in one minute.',
        durationMinutes: 1,
        statisticName: 'Chord Changes'
      ),
      Exercise(
        id: 'e3',
        title: 'Eb Minor Scale',
        description: 'Play the Eb minor scale - chords in left, melody in right.',
        durationMinutes: 5,
        statisticName: 'BPM'
      ),
    ]);

    _routines.add(Routine(
      id: 'r1', 
      title: 'Beginner Module 4', 
      instrument: Instrument.guitar, 
      exercises: _exercises
    ));
  }
}