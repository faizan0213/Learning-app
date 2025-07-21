abstract class CallState {}

class CallInitial extends CallState {}

class CallLoading extends CallState {}

class CallLoaded extends CallState {
  final String token;
  final String userId;
  final String callId;

  CallLoaded({required this.token, required this.userId, required this.callId});
}

class CallError extends CallState {
  final String message;
  CallError(this.message);
}
