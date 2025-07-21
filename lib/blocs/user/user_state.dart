import 'package:equatable/equatable.dart';

abstract class UserState extends Equatable {
  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final Map<String, dynamic> userData;
  UserLoaded({required this.userData});

  @override
  List<Object?> get props => [userData];
}

class UserError extends UserState {
  final String message;
  UserError({required this.message});

  @override
  List<Object?> get props => [message];
}
