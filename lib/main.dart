import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_colors.dart';
import 'features/auth/providers/auth_provider.dart' as ap;
import 'features/auth/screens/auth_screen.dart';
import 'features/matches/providers/matches_provider.dart';
import 'features/matches/screens/home_screen.dart';
import 'features/standings/providers/standings_provider.dart';
import 'features/standings/screens/standings_screen.dart';
import 'features/favorites/providers/favorites_provider.dart';
import 'features/favorites/screens/favorites_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    // Firebase not yet configured — app runs in demo mode
  }
  runApp(const MatchTrackerApp());
}

class MatchTrackerApp extends StatelessWidget {
  const MatchTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ap.AuthProvider()),
        ChangeNotifierProvider(create: (_) => MatchesProvider()),
        ChangeNotifierProvider(create: (_) => StandingsProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: MaterialApp(
        title: 'MatchTracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const AppShell(),
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeScreen(),
      const StandingsScreen(),
      const FavoritesScreen(),
      _ProfileScreen(
        onNavigate: (index) => setState(() => _currentIndex = index),
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bottomNavBg,
        border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
      ),
      child: NavigationBar(
        backgroundColor: AppColors.bottomNavBg,
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        indicatorColor: AppColors.accentGlow,
        surfaceTintColor: Colors.transparent,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: AppColors.accent),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events_rounded, color: AppColors.accent),
            label: 'Standings',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite_rounded, color: AppColors.accent),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person_rounded, color: AppColors.accent),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ─── Profile Screen (inline — simple) ────────────────────────────────────────
class _ProfileScreen extends StatelessWidget {
  final Function(int) onNavigate;
  const _ProfileScreen({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<ap.AuthProvider>(
          builder: (ctx, auth, __) => SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Avatar
                CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.surface,
                  backgroundImage: auth.user?.photoURL != null
                      ? NetworkImage(auth.user!.photoURL!)
                      : null,
                  child: auth.user?.photoURL == null
                      ? const Icon(Icons.person_rounded, color: AppColors.accent, size: 44)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  auth.user?.displayName ?? auth.user?.email ?? 'Guest',
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700),
                ),
                if (auth.user?.email != null)
                  Text(auth.user!.email!,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                const SizedBox(height: 32),
                if (!auth.isAuthenticated) ...[
                  ElevatedButton(
                    onPressed: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const AuthScreen())),
                    child: const Text('Sign In / Create Account'),
                  ),
                ] else ...[
                  _ProfileTile(
                    icon: Icons.favorite_rounded,
                    label: 'My Favorites',
                    onTap: () => onNavigate(2),
                    color: AppColors.live,
                  ),
                  _ProfileTile(
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    onTap: () {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(
                          content: const Text('Notifications coming soon!'),
                          backgroundColor: AppColors.accent,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                    color: AppColors.accent,
                  ),
                  _ProfileTile(
                    icon: Icons.info_outline,
                    label: 'About MatchTracker',
                    onTap: () {
                      showAboutDialog(
                        context: ctx,
                        applicationName: AppStrings.appName,
                        applicationVersion: '1.0.0',
                        applicationIcon: Container(
                          width: 50, height: 50,
                          decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.sports_soccer, color: Colors.black, size: 30),
                        ),
                        children: const [
                          Text('A 365Scores-inspired sports tracking application built with Flutter & Firebase.', style: TextStyle(color: AppColors.textPrimary)),
                        ],
                      );
                    },
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      auth.signOut();
                      context.read<FavoritesProvider>().clearFavorites();
                    },
                    icon: const Icon(Icons.logout_rounded, color: AppColors.live),
                    label: const Text('Sign Out', style: TextStyle(color: AppColors.live)),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.live)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _ProfileTile({required this.icon, required this.label, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: ListTile(
        leading: Container(
          width: 38, height: 38,
          decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
