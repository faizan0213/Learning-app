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
  final String appSign =
      'ca2f5a9d329267093d7fd40b3a7186bf6ca738c4f77763da4f6c892b1ab26f13';

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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Your User ID:",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    SelectableText(
                      FirebaseAuth.instance.currentUser?.uid ?? 'Not logged in',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _receiverIdController,
                decoration: const InputDecoration(
                  labelText: 'Enter Receiver User ID',
                  border: OutlineInputBorder(),
                  helperText: 'Paste the User ID of the person you want to call',
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

                    // First check if receiver exists and has call token
                    context.read<CallBloc>().add(
                      FetchCallData(userId: receiverId),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Please enter a different valid receiver ID",
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.call),
                label: const Text("Start Call"),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: BlocListener<CallBloc, CallState>(
                  listener: (context, state) {
                    print("Bloc State Changed: $state");

                    if (state is CallLoaded && !_callStarted) {
                      // Receiver exists, now create call invitation
                      final receiverId = _receiverIdController.text.trim();
                      final callerId = FirebaseAuth.instance.currentUser?.uid ?? '';

                      print("Receiver found, creating call invitation...");
                      print("Receiver Data - ID: ${state.userId}, Token: ${state.token}");

                      // Note: The bloc now generates its own unique call ID
                      // So we don't need to pass state.callId anymore
                      context.read<CallBloc>().add(
                        CreateCallInvitation(
                          callerId: callerId,
                          receiverId: receiverId,
                          callId: '', // This parameter is not used in the new bloc implementation
                        ),
                      );
                    } else if (state is CallInvitationSent && !_callStarted) {
                      _callStarted = true;

                      final callerId = FirebaseAuth.instance.currentUser?.uid ?? '';

                      print("Call invitation sent successfully!");
                      print("Call ID: ${state.callId}");
                      print("Receiver ID: ${state.receiverId}");

                      // Start the call interface with the unique call ID generated by the bloc
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ZegoUIKitPrebuiltCall(
                            appID: appID,
                            appSign: appSign,
                            userID: callerId,
                            userName: 'User_$callerId',
                            callID: state.callId, // Use the unique call ID from the bloc
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
                        return const Center(child: Text("Creating call invitation..."));
                      } else if (state is CallInvitationSent) {
                        return const Center(child: Text("Connecting to call..."));
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

  @override
  void dispose() {
    _receiverIdController.dispose();
    super.dispose();
  }
}