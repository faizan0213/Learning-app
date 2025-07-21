import 'package:flutter_bloc/flutter_bloc.dart';
import 'user_event.dart';
import 'user_state.dart';
import '../../../repository/user_repository.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository userRepository;

  UserBloc({required this.userRepository}) : super(UserInitial()) {
    on<LoadUserProfile>((event, emit) async {
      emit(UserLoading());
      try {
        final userData = await userRepository.getUser(event.uid);
        emit(UserLoaded(userData: userData));
      } catch (e) {
        emit(UserError(message: e.toString()));
      }
    });
  }
}
