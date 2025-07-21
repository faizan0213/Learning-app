import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning_app/blocs/course/course_event.dart';
import 'package:learning_app/widgets/coourse_card.dart';
import '../../blocs/course/course_bloc.dart';
import '../../blocs/course/course_state.dart';

class CourseListScreen extends StatelessWidget {
  const CourseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<CourseBloc>().add(LoadCourses()); // 🔥 Event dispatch

    return Scaffold(
      appBar: AppBar(title: const Text('Courses')),
      
      body: BlocBuilder<CourseBloc, CourseState>(
        builder: (context, state) {
          if (state is CourseLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CourseLoaded) {
            return ListView.builder(
              itemCount: state.courses.length,
              itemBuilder: (context, index) {
                final course = state.courses[index];
                return CourseCard(course: course);
              },
            );
          } else if (state is CourseError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('No courses found.'));
        },
      ),
    );
  }
}
