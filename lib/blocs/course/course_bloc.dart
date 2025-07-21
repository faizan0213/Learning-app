import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning_app/blocs/course/course_event.dart';
import 'package:learning_app/blocs/course/course_state.dart';
import 'package:learning_app/repository/course_repository.dart';
 
class CourseBloc extends Bloc<CourseEvent, CourseState> {
  final CourseRepository _courseRepository;

  CourseBloc({required CourseRepository courseRepository})
      : _courseRepository = courseRepository,
        super(CourseInitial()) {
    on<LoadCourses>(_onLoadCourses);
  }

  Future<void> _onLoadCourses(LoadCourses event, Emitter<CourseState> emit) async {
    emit(CourseLoading());
    try {
      final courses = await _courseRepository.getCourses();
      emit(CourseLoaded(courses));
    } catch (e) {
      emit(CourseError('Failed to load courses: $e'));
    }
  }
}
