import 'package:flutter/material.dart';
import '../../models/course_model.dart';

class CourseDetailScreen extends StatelessWidget {
  final CourseModel course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(course.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            if (course.thumbnail.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(course.thumbnail),
              ),
            const SizedBox(height: 20),

            // Title
            Text(
              course.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Description
            Text(
              course.description,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 30),
            Text(
              course.duration.toString(),
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 30),

            // Placeholder for Video
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.play_circle_outline, size: 50),
              ),
            ),
            const SizedBox(height: 20),

            // Placeholder for PDF
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('PDF Placeholder', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
