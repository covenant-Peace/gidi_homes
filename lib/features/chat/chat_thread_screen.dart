import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/responsive.dart';
import '../../models/chat.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

/// Real-time 1:1 conversation. [chat] may be null on a deep link / refresh —
/// messages still load by [chatId].
class ChatThreadScreen extends ConsumerStatefulWidget {
  const ChatThreadScreen({super.key, required this.chatId, this.chat});
  final String chatId;
  final Chat? chat;

  @override
  ConsumerState<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends ConsumerState<ChatThreadScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  bool _sending = false;

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    final user = ref.read(authControllerProvider).valueOrNull;
    if (text.isEmpty || user == null) return;
    _input.clear();
    setState(() => _sending = true);
    final msg = ChatMessage(
      id: 'm${DateTime.now().microsecondsSinceEpoch}',
      senderId: user.id,
      text: text,
      createdAt: DateTime.now(),
    );
    try {
      await ref.read(chatRepoProvider).sendMessage(widget.chatId, msg);
    } finally {
      if (mounted) setState(() => _sending = false);
      _jumpToBottom();
    }
  }

  void _jumpToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(authControllerProvider).valueOrNull?.id;
    final messages = ref.watch(chatMessagesProvider(widget.chatId));
    final title = widget.chat?.otherName(uid ?? '') ?? 'Conversation';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/messages'),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 16)),
            if (widget.chat != null)
              Text(widget.chat!.propertyTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      const TextStyle(color: AppColors.slate, fontSize: 12)),
          ],
        ),
      ),
      body: Column(
        children: [
          if (widget.chat != null)
            InkWell(
              onTap: () => context.push('/property/${widget.chat!.propertyId}'),
              child: Container(
                width: double.infinity,
                color: AppColors.greenSoft,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.home_work_outlined,
                        size: 16, color: AppColors.greenDark),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('About: ${widget.chat!.propertyTitle}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: AppColors.greenDark,
                              fontWeight: FontWeight.w600,
                              fontSize: 12.5)),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        size: 18, color: AppColors.greenDark),
                  ],
                ),
              ),
            ),
          Expanded(
            child: messages.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => EmptyState(
                  icon: Icons.error_outline, title: 'Error', message: '$e'),
              data: (list) {
                if (list.isEmpty) {
                  return const EmptyState(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'Say hello 👋',
                    message: 'Send a message to start the conversation.',
                  );
                }
                _jumpToBottom();
                return ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final m = list[i];
                    return _Bubble(message: m, mine: m.senderId == uid);
                  },
                );
              },
            ),
          ),
          _Composer(controller: _input, sending: _sending, onSend: _send),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.mine});
  final ChatMessage message;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: context.width * 0.72),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: mine ? AppColors.green : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(mine ? 16 : 4),
            bottomRight: Radius.circular(mine ? 4 : 16),
          ),
          border: mine ? null : Border.all(color: AppColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message.text,
                style: TextStyle(
                    color: mine ? Colors.white : AppColors.ink,
                    fontSize: 14.5)),
            const SizedBox(height: 2),
            Text(DateFormat('h:mm a').format(message.createdAt),
                style: TextStyle(
                    color: mine
                        ? Colors.white.withValues(alpha: 0.8)
                        : AppColors.slate,
                    fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer(
      {required this.controller, required this.sending, required this.onSend});
  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      color: AppColors.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                  decoration: const InputDecoration(
                    hintText: 'Type a message…',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: AppColors.green,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: sending ? null : onSend,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: sending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.send_rounded,
                            color: Colors.white, size: 20),
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
