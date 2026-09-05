import 'package:instrumental/models/instrument.dart';

class Exercise {
  final String id;
  final String title;
  final String? description;
  final int durationMinutes;
  final String? relatedLink;
  final String? statisticName;
  final Instrument instrument;
  bool isActive;
  bool isCompleted;
  int? lastStatistic;
  int? highestStatistic;

  Exercise({
    required this.id,
    required this.title,
    this.description,
    required this.durationMinutes,
    this.relatedLink,
    this.statisticName,
    required this.instrument,
    this.isActive = true,
    this.isCompleted = false,
    this.lastStatistic,
    this.highestStatistic
  });

  int get durationSeconds => durationMinutes * 60;
}