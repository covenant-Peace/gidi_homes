import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/account/account_screen.dart';
import '../features/agent/agent_dashboard_screen.dart';
import '../features/agent/post_listing_screen.dart';
import '../features/auth/auth_screen.dart';
import '../features/chat/chat_list_screen.dart';
import '../features/chat/chat_thread_screen.dart';
import '../features/dev/seed_screen.dart';
import '../features/home/home_screen.dart';
import '../features/inspection/inspections_screen.dart';
import '../models/chat.dart';
import '../features/property/property_detail_screen.dart';
import '../features/saved/saved_screen.dart';
import '../features/search/search_screen.dart';
import '../features/shell/main_shell.dart';

final _rootKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootKey,
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => MainShell(navigationShell: shell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/saved', builder: (_, __) => const SavedScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/account', builder: (_, __) => const AccountScreen()),
        ]),
      ],
    ),
    GoRoute(
      path: '/property/:id',
      parentNavigatorKey: _rootKey,
      builder: (_, state) =>
          PropertyDetailScreen(id: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/auth',
      parentNavigatorKey: _rootKey,
      builder: (_, __) => const AuthScreen(),
    ),
    GoRoute(
      path: '/agent',
      parentNavigatorKey: _rootKey,
      builder: (_, __) => const AgentDashboardScreen(),
    ),
    GoRoute(
      path: '/agent/post',
      parentNavigatorKey: _rootKey,
      builder: (_, state) =>
          PostListingScreen(editId: state.uri.queryParameters['id']),
    ),
    GoRoute(
      path: '/messages',
      parentNavigatorKey: _rootKey,
      builder: (_, __) => const ChatListScreen(),
    ),
    GoRoute(
      path: '/chat/:id',
      parentNavigatorKey: _rootKey,
      builder: (_, state) => ChatThreadScreen(
        chatId: state.pathParameters['id']!,
        chat: state.extra is Chat ? state.extra as Chat : null,
      ),
    ),
    GoRoute(
      path: '/inspections',
      parentNavigatorKey: _rootKey,
      builder: (_, __) => const InspectionsScreen(),
    ),
    GoRoute(
      path: '/dev/seed',
      parentNavigatorKey: _rootKey,
      builder: (_, __) => const SeedScreen(),
    ),
  ],
);
