import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'call_event.dart';
import 'call_state.dart';

class CallBloc extends Bloc<CallEvent, CallState> {
  StreamSubscription<QuerySnapshot>? _callSubscription;

  CallBloc() : super(CallInitial()) {
    on<FetchCallData>((event, emit) async {
      emit(CallLoading());
      try {
        final doc = await FirebaseFirestore.instance
            .collection('call_tokens')
            .doc(event.userId)
            .get();

        final data = doc.data();
        print("Fetched data: ${data}");

        if (data != null) {
          emit(
            CallLoaded(
              token: data['token'],
              userId: data['user_id'],
              callId: data['call_id'],
            ),
          );
        } else {
          emit(
            CallError(
              "No token found for this user ID. Make sure the user has signed up.",
            ),
          );
        }
      } catch (e) {
        emit(CallError("Failed to fetch call data: ${e.toString()}"));
      }
    });

    on<CreateCallInvitation>((event, emit) async {
      emit(CallLoading());
      try {
        // Generate a unique call ID for this specific call
        final uniqueCallId =
            "call_${event.callerId}_${event.receiverId}_${DateTime.now().millisecondsSinceEpoch}";

        // Create call invitation document
        await FirebaseFirestore.instance
            .collection('call_invitations')
            .doc(uniqueCallId)
            .set({
              'caller_id': event.callerId,
              'receiver_id': event.receiverId,
              'call_id': uniqueCallId,
              'status': 'pending',
              'created_at': FieldValue.serverTimestamp(),
            });

        print("Call invitation created: $uniqueCallId");
        emit(
          CallInvitationSent(
            callId: uniqueCallId,
            receiverId: event.receiverId,
          ),
        );
      } catch (e) {
        emit(CallError("Failed to create call invitation: ${e.toString()}"));
      }
    });

    // Listen for incoming calls
    on<ListenForIncomingCalls>((event, emit) async {
      emit(ListeningForCalls());

      _callSubscription = FirebaseFirestore.instance
          .collection('call_invitations')
          .where('receiver_id', isEqualTo: event.userId)
          .where('status', isEqualTo: 'pending')
          .snapshots()
          .listen((snapshot) {
            if (snapshot.docs.isNotEmpty) {
              final callDoc = snapshot.docs.first;
              final data = callDoc.data();

              emit(
                IncomingCall(
                  callId: data['call_id'],
                  callerId: data['caller_id'],
                  callerName:
                      'User_${data['caller_id']}', // You can fetch actual name from users collection
                ),
              );
            }
          });
    });

    // Accept call
    on<AcceptCall>((event, emit) async {
      try {
        // Update call status to accepted
        await FirebaseFirestore.instance
            .collection('call_invitations')
            .doc(event.callId)
            .update({'status': 'accepted'});

        emit(CallAccepted(callId: event.callId));
      } catch (e) {
        emit(CallError("Failed to accept call: ${e.toString()}"));
      }
    });

    // Reject call
    on<RejectCall>((event, emit) async {
      try {
        // Update call status to rejected
        await FirebaseFirestore.instance
            .collection('call_invitations')
            .doc(event.callId)
            .update({'status': 'rejected'});

        emit(CallRejected());
      } catch (e) {
        emit(CallError("Failed to reject call: ${e.toString()}"));
      }
    });

    // Stop listening for calls
    on<StopListeningForCalls>((event, emit) async {
      _callSubscription?.cancel();
      _callSubscription = null;
      emit(CallInitial());
    });
  }

  @override
  Future<void> close() {
    _callSubscription?.cancel();
    return super.close();
  }
}
