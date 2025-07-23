abstract class CallState {}

class CallInitial extends CallState {}

class CallLoading extends CallState {}

class CallLoaded extends CallState {
  final String token;
  final String userId;
  final String callId;

  CallLoaded({required this.token, required this.userId, required this.callId});
}

class CallInvitationSent extends CallState {
  final String callId;
  final String receiverId;

  CallInvitationSent({required this.callId, required this.receiverId});
}

class CallError extends CallState {
  final String message;
  CallError(this.message);
}

// Add these new states
class IncomingCall extends CallState {
  final String callId;
  final String callerId;
  final String callerName;

  IncomingCall({
    required this.callId,
    required this.callerId,
    required this.callerName,
  });
}

class CallAccepted extends CallState {
  final String callId;
  CallAccepted({required this.callId});
}

class CallRejected extends CallState {}

class ListeningForCalls extends CallState {}