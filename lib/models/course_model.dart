class CourseModel {
  final String id;
  final String title;
  final String description;
  final String thumbnail;
  final String duration;
  final String level;

  CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.duration,
    required this.level,
  });

  factory CourseModel.fromMap(Map<String, dynamic> data, String docId) {
    return CourseModel(
      id: docId,
      title: data['title'] ?? 'titile not available',
      description: data['description'] ?? 'description not available',
      thumbnail: data['thumbnail'] ?? '',
      duration: data['duration'] ?? '',
      level: data['level'] ?? '',
    );
  }
}
