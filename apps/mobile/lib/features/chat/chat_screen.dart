import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app/providers.dart';
import '../../core/database/models.dart';
import '../../shared/theme/mesh_theme.dart';
import '../../shared/widgets/glass_panel.dart';
import '../../shared/widgets/premium_scaffold.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.conversationId});

  final String conversationId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatControllerProvider(widget.conversationId));
    final emergency = widget.conversationId == 'emergency';
    return PremiumScaffold(
      title: emergency ? 'Emergency Broadcast' : 'Field Operations',
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Column(
        children: [
          Expanded(
            child: messages.when(
              data: (items) => ListView.builder(
                reverse: false,
                itemCount: items.length,
                itemBuilder: (context, index) =>
                    _MessageBubble(message: items[index]),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text(error.toString())),
            ),
          ),
          const SizedBox(height: 10),
          GlassPanel(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(
                  emergency ? Icons.priority_high_rounded : Icons.lock_rounded,
                  color: emergency ? MeshColors.red : MeshColors.cyan,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Encrypted mesh message',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _send(emergency),
                  ),
                ),
                IconButton(
                  tooltip: 'Send',
                  onPressed: () => _send(emergency),
                  icon: const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _send(bool emergency) async {
    final body = _controller.text.trim();
    if (body.isEmpty) return;
    _controller.clear();
    await ref
        .read(chatControllerProvider(widget.conversationId).notifier)
        .send(body, emergency: emergency);
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final StoredMessage message;

  @override
  Widget build(BuildContext context) {
    final mine = message.senderId == localNodeId;
    final color =
        message.priority == 'emergency' ? MeshColors.red : MeshColors.cyan;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:
                mine ? color.withOpacity(0.18) : Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(mine ? 0.30 : 0.12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message.body, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 7),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_stateIcon(message.state), size: 14, color: color),
                  const SizedBox(width: 4),
                  Text(
                    '${message.state.name.toUpperCase()}  HOPS ${message.hopCount}',
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge?.copyWith(fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _stateIcon(MessageState state) {
    return switch (state) {
      MessageState.queued => Icons.schedule_rounded,
      MessageState.sent => Icons.near_me_rounded,
      MessageState.relayed => Icons.alt_route_rounded,
      MessageState.delivered => Icons.done_all_rounded,
      MessageState.failed => Icons.error_outline_rounded,
    };
  }
}
