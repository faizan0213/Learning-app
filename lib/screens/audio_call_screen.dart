import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning_app/blocs/call/call_bloc.dart';
import 'package:learning_app/blocs/call/call_event.dart';
import 'package:learning_app/blocs/call/call_state.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class AudioCallScreen extends StatelessWidget {
  const AudioCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CallBloc()..add(FetchCallData()),
      child: Scaffold(
        appBar: AppBar(title: const Text("Audio Call")),
        body: BlocBuilder<CallBloc, CallState>(
          builder: (context, state) {
            if (state is CallLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CallError) {
              return Center(child: Text("Error: ${state.message}"));
            } else if (state is CallLoaded) {
              return ZegoUIKitPrebuiltCall(
                appID: 1585869921,
                appSign:
                    'ca2f5a9d329267093d7fd40b3a7186bf6ca738c4f77763da4f6c892b1ab26f13',
                userID: state.userId,
                userName: 'User_${state.userId}',
                callID: state.callId,
                config: ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall(),
              );
            } else {
              return const Center(child: Text("Initializing call..."));
            }
          },
        ),
      ),
    );
  }
}
