class SermonFlowStep {
  final String time;
  final String type; // 'topic', 'scripture', 'pending'
  final String title;
  final String description;

  SermonFlowStep({
    required this.time,
    required this.type,
    required this.title,
    required this.description,
  });
}
