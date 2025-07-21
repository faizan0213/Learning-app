import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learning_app/models/course_model.dart';

class CourseRepository {
  final _firestore = FirebaseFirestore.instance;

Future<List<CourseModel>> getCourses() async {
  final snapshot = await _firestore.collection('courses').get();
  print("Courses fetched: ${snapshot.docs.length}");  
  return snapshot.docs
      .map((doc) => CourseModel.fromMap(doc.data(), doc.id))
      .toList();
}
}