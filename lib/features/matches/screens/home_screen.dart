import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:match_tracker/core/constants/app_colors.dart';
import 'package:match_tracker/core/constants/app_strings.dart';
import 'package:match_tracker/features/matches/providers/matches_provider.dart';
import 'package:match_tracker/features/matches/widgets/match_card.dart';
import 'package:match_tracker/features/matches/widgets/live_badge.dart';
import 'match_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Map<int, String> _leagues = {
    39: 'Premier League',
    140: 'La Liga',
    135: 'Serie A',
    78: 'Bundesliga',
    61: 'Ligue 1',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MatchesProvider>().loadTodayMatches();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            _buildLeagueFilter(),
            _buildFilterChips(),
            _buildMatchesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Row(
          children: [
            // Logo / Title
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.sports_soccer,
                      color: Colors.black, size: 20),
                ),
                const SizedBox(width: 10),
                const Text(
                  AppStrings.appName,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Refresh button
            Consumer<MatchesProvider>(
              builder: (_, mp, __) => IconButton(
                onPressed: mp.loading ? null : () => mp.loadTodayMatches(),
                icon: mp.loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.accent,
                        ),
                      )
                    : const Icon(Icons.refresh_rounded,
                        color: AppColors.textSecondary, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeagueFilter() {
    return SliverToBoxAdapter(
      child: Consumer<MatchesProvider>(
        builder: (_, mp, __) => SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _leagues.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final id = _leagues.keys.elementAt(i);
              final name = _leagues[id]!;
              final selected = mp.leagueId == id;
              return GestureDetector(
                onTap: () => mp.setLeague(id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.accent : AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected ? AppColors.accent : AppColors.border,
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    name,
                    style: TextStyle(
                      color: selected ? Colors.black : AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    const filters = {
      MatchFilter.all: 'All',
      MatchFilter.live: 'Live',
      MatchFilter.upcoming: 'Upcoming',
      MatchFilter.finished: 'Finished',
    };

    return SliverToBoxAdapter(
      child: Consumer<MatchesProvider>(
        builder: (_, mp, __) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: filters.entries.map((e) {
              final selected = mp.filter == e.key;
              final isLive = e.key == MatchFilter.live;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => mp.setFilter(e.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected
                          ? (isLive
                              ? AppColors.live.withOpacity(0.15)
                              : AppColors.accentGlow)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? (isLive ? AppColors.live : AppColors.accent)
                            : AppColors.border,
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isLive && selected) ...[
                          const LiveBadge(),
                        ] else
                          Text(
                            e.value,
                            style: TextStyle(
                              color: selected
                                  ? (isLive ? AppColors.live : AppColors.accent)
                                  : AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildMatchesList() {
    return Consumer<MatchesProvider>(
      builder: (_, mp, __) {
        if (mp.loading) {
          return const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),
          );
        }

        if (mp.error != null) {
          return SliverFillRemaining(
            child: _ErrorState(onRetry: mp.loadTodayMatches),
          );
        }

        final matches = mp.filteredMatches;
        if (matches.isEmpty) {
          return SliverFillRemaining(
            child: _EmptyState(filter: mp.filter),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.only(top: 8, bottom: 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                final m = matches[i];
                return MatchCard(
                  match: m,
                  onTap: () => _openDetail(ctx, m),
                );
              },
              childCount: matches.length,
            ),
          ),
        );
      },
    );
  }

  void _openDetail(BuildContext context, match) {
    context.read<MatchesProvider>().loadMatchDetail(match.id);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MatchDetailScreen(matchId: match.id, match: match),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final MatchFilter filter;
  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    final message = filter == MatchFilter.live
        ? 'No live matches right now'
        : filter == MatchFilter.upcoming
            ? 'No upcoming matches today'
            : filter == MatchFilter.finished
                ? 'No finished matches today'
                : AppStrings.noMatches;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.sports_soccer,
              color: AppColors.textMuted, size: 60),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded,
              color: AppColors.textMuted, size: 60),
          const SizedBox(height: 16),
          const Text(
            AppStrings.networkError,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry',
                style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }
}
