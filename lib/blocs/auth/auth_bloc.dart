import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning_app/repository/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    // Sign Up Handler
    on<SignUpRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await authRepository.signUpUser(
          name: event.name,
          email: event.email,
          password: event.password,
        );
        emit(AuthSuccess(user));  
      } catch (e) {
        emit(AuthFailure(e.toString()));  
      }
    });

    // Sign In Handler
    on<SignInRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await authRepository.signInUser(
          email: event.email,
          password: event.password,
        );
        emit(AuthSuccess(user));  
      } catch (e) {
        emit(AuthFailure(e.toString())); 
      }
    });

    // Sign Out Handler
    on<SignOutRequested>((event, emit) async {
      await authRepository.signOut();
      emit(AuthInitial());
    });
  }
}
