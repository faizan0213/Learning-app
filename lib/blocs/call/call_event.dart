abstract class CallEvent {}

class FetchCallData extends CallEvent {
  final String userId;
  FetchCallData({required this.userId});
}

class CreateCallInvitation extends CallEvent {
  final String callerId;
  final String receiverId;
  final String callId;

  CreateCallInvitation({
    required this.callerId,
    required this.receiverId,
    required this.callId,
  });
}

// Add these new events
class ListenForIncomingCalls extends CallEvent {
  final String userId;
  ListenForIncomingCalls({required this.userId});
}

class AcceptCall extends CallEvent {
  final String callId;
  AcceptCall({required this.callId});
}

class RejectCall extends CallEvent {
  final String callId;
  RejectCall({required this.callId});
}

class StopListeningForCalls extends CallEvent {}