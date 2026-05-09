import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:match_tracker/core/constants/app_colors.dart';
import 'package:match_tracker/features/standings/models/standing_model.dart';
import 'package:match_tracker/features/standings/providers/standings_provider.dart';

class StandingsScreen extends StatefulWidget {
  const StandingsScreen({super.key});

  @override
  State<StandingsScreen> createState() => _StandingsScreenState();
}

class _StandingsScreenState extends State<StandingsScreen> {
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
      context.read<StandingsProvider>().loadStandings();
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
            _buildLeaguePicker(),
            const SizedBox(height: 8),
            _buildTableHeader(),
            const Divider(height: 1),
            Expanded(child: _buildTable()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          const Text('Standings',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w800)),
          const Spacer(),
          Consumer<StandingsProvider>(
            builder: (_, sp, __) => IconButton(
              onPressed: sp.loading ? null : () => sp.loadStandings(),
              icon: sp.loading
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent))
                  : const Icon(Icons.refresh_rounded, color: AppColors.textSecondary, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaguePicker() {
    return Consumer<StandingsProvider>(
      builder: (_, sp, __) => SizedBox(
        height: 42,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _leagues.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final id = _leagues.keys.elementAt(i);
            final name = _leagues[id]!;
            final selected = sp.leagueId == id;
            return GestureDetector(
              onTap: () => sp.setLeague(id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? AppColors.accent : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: selected ? AppColors.accent : AppColors.border, width: 0.5),
                ),
                child: Text(name,
                    style: TextStyle(
                        color: selected ? Colors.black : AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const SizedBox(width: 28),
          const SizedBox(width: 8),
          const Expanded(child: Text('Team', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600))),
          ...['MP', 'W', 'D', 'L', 'GD', 'Pts'].map((h) => SizedBox(
                width: 28,
                child: Text(h,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center),
              )),
        ],
      ),
    );
  }

  Widget _buildTable() {
    return Consumer<StandingsProvider>(
      builder: (_, sp, __) {
        if (sp.loading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.accent));
        }
        if (sp.error != null) {
          return Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.wifi_off_rounded, color: AppColors.textMuted, size: 48),
              const SizedBox(height: 12),
              TextButton(onPressed: sp.loadStandings, child: const Text('Retry', style: TextStyle(color: AppColors.accent))),
            ]),
          );
        }
        if (sp.standings.isEmpty) {
          return const Center(child: Text('No standings available', style: TextStyle(color: AppColors.textSecondary)));
        }
        return ListView.builder(
          itemCount: sp.standings.length,
          itemBuilder: (_, i) => _StandingRow(standing: sp.standings[i]),
        );
      },
    );
  }
}

class _StandingRow extends StatelessWidget {
  final StandingModel standing;
  const _StandingRow({required this.standing});

  Color get _rankColor {
    switch (standing.description) {
      case 'UCL': return AppColors.championsLeague;
      case 'UEL': return AppColors.europaLeague;
      case 'REL': return AppColors.relegation;
      default: return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: _rankColor, width: 3)),
        color: standing.rank <= 4 ? AppColors.championsLeague.withOpacity(0.04)
            : standing.rank <= 6 ? AppColors.europaLeague.withOpacity(0.04)
            : standing.rank >= 18 ? AppColors.relegation.withOpacity(0.06)
            : Colors.transparent,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 22,
              child: Text('${standing.rank}',
                  style: TextStyle(
                      color: _rankColor == Colors.transparent ? AppColors.textSecondary : _rankColor,
                      fontSize: 12, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center),
            ),
            const SizedBox(width: 8),
            CachedNetworkImage(
              imageUrl: standing.teamLogo, width: 22, height: 22,
              errorWidget: (_, __, ___) => const Icon(Icons.shield, color: AppColors.textMuted, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(standing.teamName,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis),
            ),
            ...[
              standing.played, standing.won, standing.drawn, standing.lost,
              standing.goalDiff, standing.points,
            ].map((v) => SizedBox(
                  width: 28,
                  child: Text(
                    v >= 0 ? '$v' : '$v',
                    style: TextStyle(
                        color: v == standing.points ? AppColors.accent : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: v == standing.points ? FontWeight.w700 : FontWeight.w400),
                    textAlign: TextAlign.center,
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
