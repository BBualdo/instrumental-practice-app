class StatRecord {
  final DateTime date;
  final int value;

  StatRecord({required this.date, required this.value});

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'value': value,
  };

  factory StatRecord.fromJson(Map<String, dynamic> json) {
    return StatRecord(date: DateTime.parse(json['date']), value: json['value']);
  }
}
