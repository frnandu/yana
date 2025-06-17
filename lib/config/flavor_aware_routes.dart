// lib/config/flavor_aware_routes.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_features.dart'; // Import the AppFeatures
import '../utils/router_path.dart'
    as AppRoutes; // Use alias to avoid confusion if any local RouterPath existed

// Define your screen widgets here (placeholders for now)
// Example:
// import '../ui/screens/home_screen.dart';
// import '../ui/screens/wallet_screen.dart';
// import '../ui/screens/social_feed_screen.dart';
// import '../ui/screens/dm_screen.dart';
// import '../ui/screens/search_screen.dart';
// import '../ui/screens/settings_screen.dart';
// import '../ui/screens/notice_screen.dart'; // For the NOTICE route

// Placeholder screens
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Home Screen')));
}

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Wallet Screen')));
}

class SocialFeedScreen extends StatelessWidget {
  const SocialFeedScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Social Feed Screen')));
}

class CommunitiesScreen extends StatelessWidget {
  const CommunitiesScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Communities Screen')));
}

class DMScreen extends StatelessWidget {
  const DMScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('DM Screen')));
}

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Search Screen')));
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Settings Screen')));
}

class NoticeScreen extends StatelessWidget {
  // Added for NOTICE
  const NoticeScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Notice Screen')));
}

// Removed enum RouterPath, will use AppRoutes from import '../utils/router_path.dart'

List<GoRoute> getFlavorAwareRoutes() {
  final List<GoRoute> routes = [
    GoRoute(
      path: AppRoutes.RouterPath.INDEX, // Assuming this is home
      builder: (context, state) => const HomeScreen(),
    ),
    // Example: Add a placeholder for login if not handled by INDEX
    // GoRoute(
    //   path: AppRoutes.RouterPath.LOGIN,
    //   builder: (context, state) => const LoginScreen(), // You'd need to create LoginScreen
    // ),
  ];

  if (AppFeatures.enableWallet) {
    routes.add(GoRoute(
      path: AppRoutes.RouterPath.WALLET,
      builder: (context, state) => const WalletScreen(),
    ));
    // Add other wallet-specific sub-routes if necessary
    // e.g., AppRoutes.RouterPath.WALLET_TRANSACTIONS, AppRoutes.RouterPath.SETTINGS_WALLET
    routes.add(GoRoute(
      path: AppRoutes.RouterPath.WALLET_TRANSACTIONS,
      builder: (context, state) =>
          const WalletScreen(), // Placeholder, replace with actual TransactionsScreen
    ));
    routes.add(GoRoute(
      path: AppRoutes.RouterPath.SETTINGS_WALLET,
      builder: (context, state) =>
          const SettingsScreen(), // Placeholder, replace with actual WalletSettingsScreen
    ));
  }

  if (AppFeatures.enableSocial) {
    // Assuming AppRoutes.RouterPath.INDEX covers the main social feed or you have a specific one
    // Add routes like USER, EVENT_DETAIL, THREAD_DETAIL etc.
    routes.add(GoRoute(
      path: AppRoutes
          .RouterPath.USER, // Example, adjust if USER has params like /user/:id
      builder: (context, state) => const SocialFeedScreen(), // Placeholder
    ));
    routes.add(GoRoute(
      path: AppRoutes.RouterPath.EVENT_DETAIL, // Example
      builder: (context, state) => const SocialFeedScreen(), // Placeholder
    ));
    routes.add(GoRoute(
      path: AppRoutes.RouterPath.PROFILE_EDITOR,
      builder: (context, state) =>
          const SettingsScreen(), // Placeholder, replace
    ));
  }

  if (AppFeatures.enableCommunities) {
    routes.add(GoRoute(
      path: AppRoutes.RouterPath.COMMUNITY_DETAIL, // Example
      builder: (context, state) => const CommunitiesScreen(),
    ));
    routes.add(GoRoute(
      path: AppRoutes.RouterPath.FOLLOWED_COMMUNITIES,
      builder: (context, state) => const CommunitiesScreen(), // Placeholder
    ));
  }

  if (AppFeatures.enableDm) {
    routes.add(GoRoute(
      path: AppRoutes.RouterPath.DM_DETAIL, // Example
      builder: (context, state) => const DMScreen(),
    ));
  }

  if (AppFeatures.enableSearch) {
    routes.add(GoRoute(
      path: AppRoutes.RouterPath.SEARCH,
      builder: (context, state) => const SearchScreen(),
    ));
  }

  // Adding the NOTICE route from AppRoutes
  routes.add(GoRoute(
    path: AppRoutes.RouterPath.NOTICES,
    builder: (context, state) => const NoticeScreen(),
  ));

  // It's important that all routes defined in AppRoutes.RouterPath that are *always* available
  // are added here unconditionally.
  // For example, if KEY_BACKUP is always available:
  routes.add(GoRoute(
    path: AppRoutes.RouterPath.KEY_BACKUP,
    builder: (context, state) =>
        const SettingsScreen(), // Placeholder, replace with KeyBackupScreen
  ));
  // Add other always-available routes like RELAYS, QRSCANNER etc.
  routes.add(GoRoute(
    path: AppRoutes.RouterPath.RELAYS,
    builder: (context, state) => const SettingsScreen(), // Placeholder
  ));
  routes.add(GoRoute(
    path: AppRoutes.RouterPath.QRSCANNER,
    builder: (context, state) => const SettingsScreen(), // Placeholder
  ));

  return routes;
}

// Example GoRouter setup (you would integrate this into your main app setup)
// final GoRouter router = GoRouter(
//   initialLocation: RouterPath.home.path,
//   routes: getFlavorAwareRoutes(),
// );
