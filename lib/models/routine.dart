import 'instrument.dart';

class Routine {
  final String id;
  final String title;
  final Instrument instrument;
  final List<String> exerciseIds;

  Routine({
    required this.id,
    required this.title,
    required this.instrument,
    required this.exerciseIds,
  });
}