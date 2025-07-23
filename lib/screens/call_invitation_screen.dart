import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class CallInvitationScreen extends StatefulWidget {
  const CallInvitationScreen({super.key});

  @override
  State<CallInvitationScreen> createState() => _CallInvitationScreenState();
}

class _CallInvitationScreenState extends State<CallInvitationScreen> {
  final int appID = 1585869921;
  final String appSign =
      'ca2f5a9d329267093d7fd40b3a7186bf6ca738c4f77763da4f6c892b1ab26f13';

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incoming Calls'),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('call_invitations')
            .where('receiver_id', isEqualTo: currentUserId)
            .where('status', isEqualTo: 'pending')
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final invitations = snapshot.data?.docs ?? [];

          if (invitations.isEmpty) {
            return const Center(
              child: Text(
                'No incoming calls',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: invitations.length,
            itemBuilder: (context, index) {
              final invitation = invitations[index];
              final data = invitation.data() as Map<String, dynamic>;
              final callerId = data['caller_id'] ?? '';
              final callId = data['call_id'] ?? '';

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.call, color: Colors.white),
                  ),
                  title: Text('Incoming call from User_$callerId'),
                  subtitle: Text('Call ID: $callId'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _acceptCall(callId, callerId, invitation.id),
                        icon: const Icon(Icons.call, color: Colors.green),
                        tooltip: 'Accept',
                      ),
                      IconButton(
                        onPressed: () => _rejectCall(invitation.id),
                        icon: const Icon(Icons.call_end, color: Colors.red),
                        tooltip: 'Reject',
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _acceptCall(String callId, String callerId, String invitationId) async {
    try {
      // Update invitation status
      await FirebaseFirestore.instance
          .collection('call_invitations')
          .doc(invitationId)
          .update({'status': 'accepted'});

      final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

      // Navigate to call screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ZegoUIKitPrebuiltCall(
              appID: appID,
              appSign: appSign,
              userID: currentUserId,
              userName: 'User_$currentUserId',
              callID: callId,
              config: ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall(),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error accepting call: $e')),
        );
      }
    }
  }

  void _rejectCall(String invitationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('call_invitations')
          .doc(invitationId)
          .update({'status': 'rejected'});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Call rejected')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error rejecting call: $e')),
        );
      }
    }
  }
}