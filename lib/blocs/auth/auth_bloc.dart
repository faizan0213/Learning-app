import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learning_app/blocs/auth/auth_event.dart';
import 'package:learning_app/blocs/auth/auth_state.dart';
import 'package:learning_app/repository/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    
    on<SignInRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await _authRepository.signInUser(
          email: event.email,
          password: event.password,
        );
        
        // Create or update call token for the user
        await _createCallToken(user.uid);
        
        emit(AuthSuccess(user: user));
      } catch (e) {
        emit(AuthFailure(message: e.toString()));
      }
    });

    on<SignUpRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await _authRepository.signUpUser(
          name: event.name,
          email: event.email,
          password: event.password,
        );
        
        // Create call token for new user
        await _createCallToken(user.uid, userName: event.name);
        
        emit(AuthSuccess(user: user));
      } catch (e) {
        emit(AuthFailure(message: e.toString()));
      }
    });

    on<SignOutRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await _authRepository.signOut();
        emit(AuthUnauthenticated());
      } catch (e) {
        emit(AuthFailure(message: e.toString()));
      }
    });

    on<AuthCheckRequested>((event, emit) async {
      try {
        final user = await _authRepository.getCurrentUser();
        if (user != null) {
          // Ensure call token exists for existing user
          await _createCallToken(user.uid);
          emit(AuthSuccess(user: user));
        } else {
          emit(AuthUnauthenticated());
        }
      } catch (e) {
        emit(AuthUnauthenticated());
      }
    });
  }

  // Helper method to create call token in Firestore
  Future<void> _createCallToken(String userId, {String? userName}) async {
    try {
      final callTokenDoc = FirebaseFirestore.instance
          .collection('call_tokens')
          .doc(userId);
      
      // Check if document already exists
      final docSnapshot = await callTokenDoc.get();
      
      if (!docSnapshot.exists) {
        // Create new call token document
        await callTokenDoc.set({
          'user_id': userId,
          'token': _generateCallToken(userId), // Generate token if needed
          'call_id': userId, // Use userId as call_id for simplicity
          'user_name': userName ?? 'User_$userId',
          'created_at': FieldValue.serverTimestamp(),
          'is_online': true,
        });
        
        print("Call token created for user: $userId");
      } else {
        // Update existing document to mark user as online
        await callTokenDoc.update({
          'is_online': true,
          'last_seen': FieldValue.serverTimestamp(),
        });
        
        print("Call token updated for user: $userId");
      }
    } catch (e) {
      print("Error creating call token: $e");
      // Don't throw error here as it shouldn't block authentication
    }
  }

  // Generate a simple token (you can make this more sophisticated)
  String _generateCallToken(String userId) {
  
    return 'token_$userId${DateTime.now().millisecondsSinceEpoch}';
  }
}