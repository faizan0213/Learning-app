import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadUserProfile extends UserEvent {
  final String uid;

  LoadUserProfile({required this.uid});
}
