import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:match_tracker/core/constants/app_colors.dart';
import 'package:match_tracker/core/constants/app_strings.dart';
import 'package:match_tracker/features/favorites/providers/favorites_provider.dart';
import 'package:match_tracker/features/auth/providers/auth_provider.dart' as ap;
import 'package:match_tracker/features/matches/widgets/match_card.dart';
import 'package:match_tracker/features/matches/providers/matches_provider.dart';
import 'package:match_tracker/features/matches/screens/match_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<ap.AuthProvider>();
      if (auth.isAuthenticated) {
        context.read<FavoritesProvider>().loadFavorites();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: const [
          Text('Favorites',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<ap.AuthProvider>(
      builder: (_, auth, __) {
        if (!auth.isAuthenticated) {
          return _UnauthenticatedState();
        }
        return Consumer<FavoritesProvider>(
          builder: (_, fav, __) {
            if (fav.loading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.accent));
            }
            if (fav.favoriteMatches.isEmpty) {
              return _EmptyFavoritesState();
            }
            return RefreshIndicator(
              color: AppColors.accent,
              backgroundColor: AppColors.surface,
              onRefresh: () => fav.loadFavorites(),
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 24),
                itemCount: fav.favoriteMatches.length,
                itemBuilder: (ctx, i) {
                  final match = fav.favoriteMatches[i];
                  return MatchCard(
                    match: match,
                    onTap: () {
                      context.read<MatchesProvider>().loadMatchDetail(match.id);
                      Navigator.push(
                        ctx,
                        MaterialPageRoute(
                          builder: (_) => MatchDetailScreen(matchId: match.id, match: match),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _EmptyFavoritesState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(Icons.favorite_border, color: AppColors.textMuted, size: 36),
          ),
          const SizedBox(height: 20),
          const Text(AppStrings.noFavorites,
              style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text(AppStrings.addFavoriteHint,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _UnauthenticatedState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(40)),
              child: const Icon(Icons.lock_outline, color: AppColors.accent, size: 36),
            ),
            const SizedBox(height: 20),
            const Text('Sign in to view favorites',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('Create an account to save and sync your favorite matches across devices.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
