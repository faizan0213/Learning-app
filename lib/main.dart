import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning_app/blocs/course/course_bloc.dart';
import 'package:learning_app/blocs/user/user_bloc.dart';
import 'package:learning_app/repository/course_repository.dart';
import 'package:learning_app/repository/user_repository.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'blocs/auth/auth_bloc.dart';
import 'repository/auth_repository.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository = AuthRepository();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(authRepository: AuthRepository())),
        BlocProvider(create: (_) => UserBloc(userRepository: UserRepository())),
        BlocProvider(
          create: (_) => CourseBloc(courseRepository: CourseRepository()),
        ),
      ],
      child: MaterialApp(
        title: 'Learning App',
        theme: ThemeData(primarySwatch: Colors.deepPurple),
        home: const LoginScreen(),
        
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
