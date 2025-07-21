import 'package:learning_app/models/course_model.dart';
import 'package:flutter/material.dart';
import 'package:learning_app/screens/course_detail_screen.dart';

class CourseCard extends StatelessWidget {
  final CourseModel course;

  const CourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: course.thumbnail.isNotEmpty
            ? SizedBox(
                width: 60,
                height: 60,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    course.thumbnail,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            : const Icon(Icons.school, size: 40),
        title: Text(
          course.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          course.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CourseDetailScreen(course: course),
            ),
          );
        },
      ),
    );
  }
}
