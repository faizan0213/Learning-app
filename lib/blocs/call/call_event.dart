abstract class CallEvent {}

class FetchCallData extends CallEvent {
  final String userId;

  FetchCallData({required this.userId});
}
