import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:learning_app/blocs/user/user_bloc.dart';
import 'package:learning_app/blocs/user/user_event.dart';
import 'package:learning_app/blocs/user/user_state.dart';
import 'package:learning_app/screens/audio_call_screen.dart';
import 'package:learning_app/screens/course_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      context.read<UserBloc>().add(LoadUserProfile(uid: uid));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UserLoaded) {
            final user = state.userData;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Welcome, ${user['name']}"),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CourseListScreen(),
                        ),
                      );
                    },
                    child: const Text('View Courses'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AudioCallScreen(),
                        ),
                      );
                    },
                    child: const Text('Call'),
                  ),
                ],
              ),
            );
          } else if (state is UserError) {
            return Center(child: Text("Error: ${state.message}"));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
