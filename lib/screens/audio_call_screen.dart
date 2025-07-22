import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning_app/blocs/call/call_bloc.dart';
import 'package:learning_app/blocs/call/call_event.dart';
import 'package:learning_app/blocs/call/call_state.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AudioCallScreen extends StatefulWidget {
  const AudioCallScreen({super.key});

  @override
  State<AudioCallScreen> createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen> {
  final int appID = 1585869921;
  final String appSign = '';

  final TextEditingController _receiverIdController = TextEditingController();

  bool _callStarted = false;  

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CallBloc(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Audio Call")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _receiverIdController,
                decoration: const InputDecoration(
                  labelText: 'Enter Receiver User ID',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  final receiverId = _receiverIdController.text.trim();
                  final callerId = FirebaseAuth.instance.currentUser?.uid ?? '';

                  print(" Receiver ID Input: $receiverId");
                  print(" Firebase Current Caller ID: $callerId");

                  if (receiverId.isNotEmpty && callerId != receiverId) {
                    _callStarted = false;

                    context.read<CallBloc>().add(
                      FetchCallData(userId: callerId), // fetch caller's token
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please enter a different valid receiver ID"),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.call),
                label: const Text("Fetch & Call"),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: BlocListener<CallBloc, CallState>(
                  listener: (context, state) {
                    print("📣 Bloc State Changed: $state");

                    if (state is CallLoaded && !_callStarted) {
                      _callStarted = true;

                      final receiverId = _receiverIdController.text.trim();

                      print("Call Data Fetched:");
                      print("Caller ID: ${state.userId}");
                      print("Call ID: ${state.callId}");
                      print("Token: ${state.token}");
                      print("Receiver ID: $receiverId");

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ZegoUIKitPrebuiltCall(
                            appID: appID,
                            appSign: appSign,
                            userID: state.userId, // logged in user
                            userName: 'User_${state.userId}',
                            callID: state.callId,
                            config: ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall(),
                          ),
                        ),
                      );
                    } else if (state is CallError) {
                      print("Error: ${state.message}");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: ${state.message}")),
                      );
                    }
                  },
                  child: BlocBuilder<CallBloc, CallState>(
                    builder: (context, state) {
                      if (state is CallLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is CallLoaded) {
                        return const Center(child: Text("Connecting..."));
                      } else {
                        return const Center(
                          child: Text("Enter receiver ID to start a call"),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
