import 'instrument.dart';

class Routine {
  final String id;
  final String title;
  final Instrument instrument;
  final List<String> exerciseIds;
  bool isActive;

  Routine({
    required this.id,
    required this.title,
    required this.instrument,
    required this.exerciseIds,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'instrument': instrument.name,
    'exerciseIds': exerciseIds,
    'isActive': isActive,
  };

  factory Routine.fromJson(Map<String, dynamic> json) {
    return Routine(
      id: json['id'],
      title: json['title'],
      instrument: Instrument.values.firstWhere((e) => e.name == json['instrument']),
      exerciseIds: List<String>.from(json['exerciseIds'] ?? []),
      isActive: json['isActive'] ?? true,
    );
  }
}