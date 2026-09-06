import 'package:instrumental/models/instrument.dart';

class PracticeSession {
  final String id;
  final DateTime date;
  final int durationMinutes;
  final Instrument instrument;
  final String? routineId;

  PracticeSession({
    required this.id,
    required this.date,
    required this.durationMinutes,
    required this.instrument,
    this.routineId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'durationMinutes': durationMinutes,
    'instrument': instrument.name,
    'routineId': routineId,
  };

  factory PracticeSession.fromJson(Map<String, dynamic> json) {
    return PracticeSession(
      id: json['id'],
      date: json['date'],
      durationMinutes: json['durationMinutes'],
      instrument: Instrument.values.firstWhere(
        (value) => value.name == json['instrument'],
      ),
      routineId: json['routineId'],
    );
  }
}
