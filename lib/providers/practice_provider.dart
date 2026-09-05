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

  List<Exercise> get activeExercises =>
      _exercises.where((exercise) => exercise.isActive).toList();

  List<Exercise> get archivedExercises =>
      _exercises.where((exercise) => !exercise.isActive).toList();

  List<Routine> get routines => _routines;

  Routine getRoutineById(String id) {
    return _routines.firstWhere((routine) => routine.id == id);
  }

  Exercise getExerciseById(String id) {
    return _exercises.firstWhere((exercise) => exercise.id == id);
  }

  void addExercise({
    required String title,
    required int duration,
    required Instrument instrument,
    String? description,
    String? relatedLink,
    String? statisticName,
  }) {
    final newExercise = Exercise(
      id: DateTime.now().toString(),
      title: title,
      description: description,
      durationMinutes: duration,
      instrument: instrument,
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

  void restoreExercise(String id) {
    final index = _exercises.indexWhere((exercise) => exercise.id == id);
    if (index != -1) {
      _exercises[index].isActive = true;
      notifyListeners();
    }
  }

  void deleteExercisePermanently(String id) {
    for (var routine in _routines) {
      routine.exerciseIds.remove(id);
    }

    _exercises.removeWhere((exercise) => exercise.id == id);
    notifyListeners();
  }

  void updateExercise({
    required String id,
    required String title,
    required int duration,
    required Instrument instrument,
    String? description,
    String? relatedLink,
    String? statisticName,
  }) {
    final exercise = getExerciseById(id);

    final updatedExercise = Exercise(
      id: id,
      title: title,
      durationMinutes: duration,
      instrument: instrument,
      description: description,
      relatedLink: relatedLink,
      statisticName: statisticName,
      isActive: exercise.isActive,
      isCompleted: exercise.isCompleted,
      highestStatistic: exercise.highestStatistic,
      lastStatistic: exercise.lastStatistic
    );

    final index = _exercises.indexWhere((exercise) => exercise.id == id);
    _exercises[index] = updatedExercise;

    notifyListeners();
  }

  void addRoutine(
    String title,
    Instrument instrument,
    List<String> exerciseIds,
  ) {
    final newRoutine = Routine(
      id: DateTime.now().toString(),
      title: title,
      instrument: instrument,
      exerciseIds: exerciseIds,
    );

    _routines.add(newRoutine);
    notifyListeners();
  }

  List<Exercise> getExercisesForRoutine(String routineId) {
    final routine = getRoutineById(routineId);

    return routine.exerciseIds
        .map((exerciseId) => getExerciseById(exerciseId))
        .where((exercise) => exercise.isActive)
        .toList();
  }

  List<Exercise> getAvailableExercisesForInstrument(Instrument instrument) {
    return _exercises
        .where(
          (exercise) => exercise.isActive && exercise.instrument == instrument,
        )
        .toList();
  }

  void completeExercise(String exerciseId, {int? statValue}) {
    final exercise = getExerciseById(exerciseId);
    exercise.isCompleted = true;

    if (statValue != null) {
      exercise.lastStatistic = statValue;
      if (exercise.highestStatistic == null ||
          statValue > exercise.highestStatistic!) {
        exercise.highestStatistic = statValue;
      }
    }

    notifyListeners();
  }

  void reorderExercises(String routineId, int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;

    final routine = getRoutineById(routineId);
    final exercise = routine.exerciseIds.removeAt(oldIndex);
    routine.exerciseIds.insert(newIndex, exercise);

    notifyListeners();
  }

  void resetRoutineProgress(String routineId) {
    final routine = getRoutineById(routineId);

    for (var exerciseId in routine.exerciseIds) {
      final exercise = getExerciseById(exerciseId);
      exercise.isCompleted = false;
    }

    notifyListeners();
  }

  void toggleExerciseInRoutine(String routineId, String exerciseId) {
    final routine = getRoutineById(routineId);

    if (routine.exerciseIds.contains(exerciseId)) {
      routine.exerciseIds.remove(exerciseId);
    } else {
      routine.exerciseIds.add(exerciseId);
    }

    notifyListeners();
  }

  void _seedExampleData() {
    _exercises.addAll([
      Exercise(
        id: 'e1',
        title: 'One Minute Changes: Am - D',
        description: 'Play them as fast as you can in one minute.',
        durationMinutes: 1,
        statisticName: 'Chord Changes',
        instrument: Instrument.guitar,
      ),
      Exercise(
        id: 'e2',
        title: 'One Minute Changes: C - G',
        description: 'Play them as fast as you can in one minute.',
        durationMinutes: 1,
        statisticName: 'Chord Changes',
        instrument: Instrument.guitar,
      ),
      Exercise(
        id: 'e3',
        title: 'Eb Minor Scale',
        description:
            'Play the Eb minor scale - chords in left, melody in right.',
        durationMinutes: 5,
        statisticName: 'BPM',
        instrument: Instrument.piano,
      ),
    ]);

    _routines.add(
      Routine(
        id: 'r1',
        title: 'Beginner Module 4',
        instrument: Instrument.guitar,
        exerciseIds: _exercises
            .where((exercise) => exercise.instrument == Instrument.guitar)
            .map((exercise) => exercise.id)
            .toList(),
      ),
    );
  }
}
