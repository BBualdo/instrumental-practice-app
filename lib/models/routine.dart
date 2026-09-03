import 'instrument.dart';
import 'exercise.dart';

class Routine {
  final String id;
  final String title;
  final Instrument instrument;
  final List<Exercise> exercises;

  Routine({
    required this.id,
    required this.title,
    required this.instrument,
    required this.exercises,
  });
}