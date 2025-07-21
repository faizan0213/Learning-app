import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'call_event.dart';
import 'call_state.dart';

class CallBloc extends Bloc<CallEvent, CallState> {
  CallBloc() : super(CallInitial()) {
    on<FetchCallData>((event, emit) async {
      emit(CallLoading());
      try {
        final doc = await FirebaseFirestore.instance
            .collection('call_tokens')
            .doc('dummy_audio')
            .get();
        final data = doc.data();
        if (data != null) {
          emit(CallLoaded(
            token: data['token'],
            userId: data['user_id'],
            callId: data['call_id'],
          ));
        } else {
          emit(CallError("No token found."));
        }
      } catch (e) {
        emit(CallError(e.toString()));
      }
    });
  }
}
