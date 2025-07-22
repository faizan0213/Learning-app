import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:learning_app/blocs/call/call_bloc.dart';
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
            return Column(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      "Welcome, ${user['name']}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.menu_book),
                          label: const Text("Courses"),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CourseListScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.call),
                          label: const Text("Call"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider(
                                  create: (_) => CallBloc(),
                                  child: const AudioCallScreen(),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
