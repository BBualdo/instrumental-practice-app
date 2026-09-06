import 'package:instrumental/models/instrument.dart';
import 'package:instrumental/models/stat_record.dart';

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
  final List<StatRecord> statHistory;

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
    this.highestStatistic,
    List<StatRecord>? statHistory,
  }) : statHistory = statHistory ?? [];

  int get durationSeconds => durationMinutes * 60;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'durationMinutes': durationMinutes,
    'relatedLink': relatedLink,
    'statisticName': statisticName,
    'instrument': instrument.name,
    'isActive': isActive,
    'isCompleted': isCompleted,
    'lastStatistic': lastStatistic,
    'highestStatistic': highestStatistic,
    'statHistory': statHistory.map((stat) => stat.toJson()).toList(),
  };

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      durationMinutes: json['durationMinutes'],
      relatedLink: json['relatedLink'],
      statisticName: json['statisticName'],
      instrument: Instrument.values.firstWhere(
        (e) => e.name == json['instrument'],
      ),
      isActive: json['isActive'] ?? true,
      isCompleted: json['isCompleted'] ?? false,
      lastStatistic: json['lastStatistic'],
      highestStatistic: json['highestStatistic'],
      statHistory:
          (json['statHistory'] as List?)
              ?.map((el) => StatRecord.fromJson(el))
              .toList() ??
          [],
    );
  }
}
