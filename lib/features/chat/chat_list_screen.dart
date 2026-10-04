import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../models/chat.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/network_photo.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: const Text('Messages',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: user == null
          ? EmptyState(
              icon: Icons.lock_outline_rounded,
              title: 'Sign in to view messages',
              action: ElevatedButton(
                  onPressed: () => context.push('/auth'),
                  child: const Text('Sign in')),
            )
          : _ChatList(uid: user.id),
    );
  }
}

class _ChatList extends ConsumerWidget {
  const _ChatList({required this.uid});
  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chats = ref.watch(myChatsProvider);
    return chats.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) =>
          EmptyState(icon: Icons.error_outline, title: 'Error', message: '$e'),
      data: (list) {
        if (list.isEmpty) {
          return const EmptyState(
            icon: Icons.forum_outlined,
            title: 'No conversations yet',
            message:
                'Message an agent from a listing to start chatting here.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: list.length,
          separatorBuilder: (_, __) =>
              const Divider(height: 1, indent: 80),
          itemBuilder: (_, i) => _ChatTile(chat: list[i], uid: uid),
        );
      },
    );
  }
}

class _ChatTile extends StatelessWidget {
  const _ChatTile({required this.chat, required this.uid});
  final Chat chat;
  final String uid;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
            width: 52, height: 52, child: NetworkPhoto(chat.propertyImage)),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(chat.otherName(uid),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          Text(timeAgo(chat.updatedAt),
              style: const TextStyle(color: AppColors.slate, fontSize: 11)),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(chat.propertyTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: AppColors.green)),
          Text(
            chat.lastMessage.isEmpty
                ? 'No messages yet'
                : '${chat.lastSenderId == uid ? "You: " : ""}${chat.lastMessage}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.slate, fontSize: 13),
          ),
        ],
      ),
      onTap: () =>
          context.push('/chat/${chat.id}', extra: chat),
    );
  }
}
