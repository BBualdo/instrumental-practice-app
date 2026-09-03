class Exercise {
  final String id;
  final String title;
  final String? description;
  final int durationMinutes;
  final String? relatedLink;
  final String? statisticName;
  bool isActive;

  Exercise({
    required this.id,
    required this.title,
    this.description,
    required this.durationMinutes,
    this.relatedLink,
    this.statisticName,
    this.isActive = false,
  });
}