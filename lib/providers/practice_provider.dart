import 'package:flutter/material.dart';
import 'package:instrumental/models/exercise.dart';
import 'package:instrumental/models/instrument.dart';
import 'package:instrumental/models/practice_session.dart';
import 'package:instrumental/models/routine.dart';
import 'package:instrumental/models/stat_record.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';
import 'dart:async';

class PracticeProvider extends ChangeNotifier {
  final List<Exercise> _exercises = [];
  final List<Routine> _routines = [];
  final List<PracticeSession> _sessions = [];

  PracticeProvider() {
    loadFromStorage();
  }

  List<Exercise> get exercises => _exercises;

  List<Exercise> get activeExercises =>
      _exercises.where((exercise) => exercise.isActive).toList();

  List<Exercise> get archivedExercises =>
      _exercises.where((exercise) => !exercise.isActive).toList();

  List<Routine> get routines => _routines;

  List<Routine> get activeRoutines =>
      _routines.where((routine) => routine.isActive).toList();

  List<Routine> get archivedRoutines =>
      _routines.where((routine) => !routine.isActive).toList();

  List<PracticeSession> get sessions => _sessions;

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
    unawaited(saveToStorage());
  }

  void archiveExercise(String id) {
    final index = _exercises.indexWhere((exercise) => exercise.id == id);
    if (index != -1) {
      _exercises[index].isActive = false;

      notifyListeners();
      unawaited(saveToStorage());
    }
  }

  void restoreExercise(String id) {
    final index = _exercises.indexWhere((exercise) => exercise.id == id);
    if (index != -1) {
      _exercises[index].isActive = true;

      notifyListeners();
      unawaited(saveToStorage());
    }
  }

  void deleteExercisePermanently(String id) {
    for (var routine in _routines) {
      routine.exerciseIds.remove(id);
    }

    _exercises.removeWhere((exercise) => exercise.id == id);

    notifyListeners();
    unawaited(saveToStorage());
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
      lastStatistic: exercise.lastStatistic,
      statHistory: exercise.statHistory,
    );

    final index = _exercises.indexWhere((exercise) => exercise.id == id);
    _exercises[index] = updatedExercise;

    notifyListeners();
    unawaited(saveToStorage());
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
      isActive: true,
    );

    _routines.add(newRoutine);

    notifyListeners();
    unawaited(saveToStorage());
  }

  void archiveRoutine(String routineId) {
    final index = _routines.indexWhere((routine) => routine.id == routineId);
    _routines[index].isActive = false;

    notifyListeners();
    unawaited(saveToStorage());
  }

  void restoreRoutine(String routineId) {
    final index = _routines.indexWhere((routine) => routine.id == routineId);
    _routines[index].isActive = true;

    notifyListeners();
    unawaited(saveToStorage());
  }

  void deleteRoutinePermanently(String routineId) {
    final index = _routines.indexWhere((routine) => routine.id == routineId);
    _routines.removeAt(index);

    notifyListeners();
    unawaited(saveToStorage());
  }

  List<Exercise> getExercisesForRoutine(String routineId) {
    final routine = getRoutineById(routineId);

    return routine.exerciseIds
        .map((exerciseId) => getExerciseById(exerciseId))
        .where((exercise) => exercise.isActive)
        .toList();
  }

  int getTotalDurationForRoutine(String routineId) {
    final exercises = getExercisesForRoutine(routineId);

    return exercises.fold(0, (sum, exercise) => sum + exercise.durationMinutes);
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

      exercise.statHistory.add(
        StatRecord(date: DateTime.now(), value: statValue),
      );
    }

    notifyListeners();
    unawaited(saveToStorage());
  }

  void reorderExercises(String routineId, int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;

    final routine = getRoutineById(routineId);
    final exercise = routine.exerciseIds.removeAt(oldIndex);
    routine.exerciseIds.insert(newIndex, exercise);

    notifyListeners();
    unawaited(saveToStorage());
  }

  void resetRoutine(String routineId) {
    final exercises = getExercisesForRoutine(routineId);

    for (var exercise in exercises) {
      exercise.isCompleted = false;
    }

    notifyListeners();
    unawaited(saveToStorage());
  }

  void finishRoutine(String routineId) {
    final routine = getRoutineById(routineId);
    final exercises = getExercisesForRoutine(routineId);

    final totalMinutes = exercises
        .where((exercise) => exercise.isCompleted)
        .fold(0, (sum, exercise) => sum + exercise.durationMinutes);

    if (totalMinutes > 0) {
      final session = PracticeSession(
        id: DateTime.now().toString(),
        date: DateTime.now(),
        durationMinutes: totalMinutes,
        instrument: routine.instrument,
        routineId: routine.id,
      );

      _sessions.add(session);
    }

    for (var exercise in exercises) {
      exercise.isCompleted = false;
    }

    notifyListeners();
    unawaited(saveToStorage());
  }

  void toggleExerciseInRoutine(String routineId, String exerciseId) {
    final routine = getRoutineById(routineId);

    if (routine.exerciseIds.contains(exerciseId)) {
      routine.exerciseIds.remove(exerciseId);
    } else {
      routine.exerciseIds.add(exerciseId);
    }

    notifyListeners();
    unawaited(saveToStorage());
  }

  void addManualSession(DateTime date, int durationMinutes, Instrument instrument) {
    final session = PracticeSession(
      id: DateTime.now().toString(),
      date: date,
      durationMinutes: durationMinutes,
      instrument: instrument,
    );

    _sessions.add(session);
    notifyListeners();
    unawaited(saveToStorage());
  }

  Future<void> saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();

    final exercisesJson = jsonEncode(
      _exercises.map((exercise) => exercise.toJson()).toList(),
    );
    final routinesJson = jsonEncode(
      _routines.map((routine) => routine.toJson()).toList(),
    );
    final sessionsJson = jsonEncode(
      _sessions.map((session) => session.toJson()).toList(),
    );

    await prefs.setString('exercises_data', exercisesJson);
    await prefs.setString('routines_data', routinesJson);
    await prefs.setString('sessions_data', sessionsJson);
  }

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final exercisesString = prefs.getString('exercises_data');
    final routinesString = prefs.getString('routines_data');
    final sessionsString = prefs.getString('sessions_data');

    if (exercisesString != null) {
      _decodeAndUpdate(exercisesString, _exercises, Exercise.fromJson);
    }

    if (routinesString != null) {
      _decodeAndUpdate(routinesString, _routines, Routine.fromJson);
    }

    if (sessionsString != null) {
      _decodeAndUpdate(sessionsString, _sessions, PracticeSession.fromJson);
    }

    notifyListeners();
  }

  void _decodeAndUpdate<T>(
    String jsonString,
    List<T> collection,
    T Function(Map<String, dynamic>) fromJsonFactory,
  ) {
    final List decoded = jsonDecode(jsonString);
    collection.clear();
    collection.addAll(decoded.map((json) => fromJsonFactory(json)).toList());
  }
}
