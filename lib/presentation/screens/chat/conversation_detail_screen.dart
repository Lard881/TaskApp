import 'package:flutter/material.dart';

/// Conversation detail screen — full implementation in Wave 6.
class ConversationDetailScreen extends StatelessWidget {
  const ConversationDetailScreen({super.key, required this.conversationId});
  final String conversationId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conversation')),
      body: const Center(child: Text('Messages')),
    );
  }
}
