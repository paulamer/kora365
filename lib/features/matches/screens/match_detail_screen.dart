import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:match_tracker/core/constants/app_colors.dart';
import 'package:match_tracker/core/utils/date_formatter.dart';
import 'package:match_tracker/features/matches/models/match_model.dart';
import 'package:match_tracker/features/matches/providers/matches_provider.dart';
import 'package:match_tracker/features/favorites/providers/favorites_provider.dart';
import 'package:match_tracker/features/matches/widgets/live_badge.dart';

class MatchDetailScreen extends StatefulWidget {
  final int matchId;
  final MatchModel match;
  const MatchDetailScreen({super.key, required this.matchId, required this.match});

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<MatchesProvider>(
        builder: (_, mp, __) {
          final match = mp.selectedMatch ?? widget.match;
          return CustomScrollView(
            slivers: [
              _buildHeader(match),
              SliverToBoxAdapter(
                child: TabBar(
                  controller: _tabController,
                  tabs: const [Tab(text: 'Details'), Tab(text: 'Stats'), Tab(text: 'Timeline')],
                ),
              ),
              SliverFillRemaining(
                child: mp.detailLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _DetailsTab(match: match),
                          _StatsTab(match: match),
                          _TimelineTab(match: match),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(MatchModel match) {
    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.surfaceVariant, AppColors.background],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
                    ),
                    Expanded(
                      child: Text(match.leagueName,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          textAlign: TextAlign.center),
                    ),
                    Consumer<FavoritesProvider>(
                      builder: (_, fav, __) => IconButton(
                        onPressed: () => fav.toggleFavorite(match),
                        icon: Icon(
                          fav.isFavorite(match.id) ? Icons.favorite : Icons.favorite_border,
                          color: fav.isFavorite(match.id) ? AppColors.live : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _TeamColumn(name: match.homeTeam.name, logo: match.homeTeam.logo),
                    Column(
                      children: [
                        Row(
                          children: [
                            Text('${match.homeGoals ?? "-"}',
                                style: TextStyle(
                                    color: (match.homeGoals != null && match.awayGoals != null && match.homeGoals! > match.awayGoals!) ? AppColors.accent : AppColors.textPrimary,
                                    fontSize: 44, fontWeight: FontWeight.w900)),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text(':', style: TextStyle(color: AppColors.textSecondary, fontSize: 40, fontWeight: FontWeight.w300)),
                            ),
                            Text('${match.awayGoals ?? "-"}',
                                style: TextStyle(
                                    color: (match.homeGoals != null && match.awayGoals != null && match.awayGoals! > match.homeGoals!) ? AppColors.accent : AppColors.textPrimary,
                                    fontSize: 44, fontWeight: FontWeight.w900)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        if (match.isLive)
                          Row(mainAxisSize: MainAxisSize.min, children: [
                            const LiveBadge(large: true),
                            if (match.elapsed != null) ...[
                              const SizedBox(width: 8),
                              Text("${match.elapsed}'", style: const TextStyle(color: AppColors.live, fontSize: 14, fontWeight: FontWeight.w700)),
                            ]
                          ])
                        else
                          Text(
                            match.isScheduled ? DateFormatter.matchTime(match.dateTime) : match.displayStatus,
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                      ],
                    ),
                    _TeamColumn(name: match.awayTeam.name, logo: match.awayTeam.logo),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TeamColumn extends StatelessWidget {
  final String name;
  final String logo;
  const _TeamColumn({required this.name, required this.logo});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      child: Column(
        children: [
          CachedNetworkImage(
            imageUrl: logo, width: 60, height: 60,
            errorWidget: (_, __, ___) => const Icon(Icons.sports_soccer, color: AppColors.textMuted, size: 50),
          ),
          const SizedBox(height: 8),
          Text(name,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _DetailsTab extends StatelessWidget {
  final MatchModel match;
  const _DetailsTab({required this.match});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border, width: 0.5)),
          child: Column(children: [
            _row('Competition', match.leagueName),
            const Divider(height: 0),
            _row('Round', match.round),
            const Divider(height: 0),
            _row('Date', DateFormatter.formatDate(match.dateTime)),
            const Divider(height: 0),
            _row('Kick-off', DateFormatter.matchTime(match.dateTime)),
            const Divider(height: 0),
            _row('Status', match.displayStatus.isEmpty ? 'Not started' : match.displayStatus),
          ]),
        ),
      ],
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
    ]),
  );
}

class _StatsTab extends StatelessWidget {
  final MatchModel match;
  const _StatsTab({required this.match});

  static const _keys = ['Ball Possession', 'Total Shots', 'Shots on Goal', 'Corner Kicks', 'Fouls', 'Yellow Cards', 'Red Cards', 'Offsides'];

  @override
  Widget build(BuildContext context) {
    if (match.statistics.isEmpty) return const Center(child: Text('No stats available', style: TextStyle(color: AppColors.textSecondary)));
    final home = match.statistics[0];
    final away = match.statistics.length > 1 ? match.statistics[1] : null;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: _keys.map((k) => _StatBar(label: k, homeValue: home.getStat(k) ?? '-', awayValue: away?.getStat(k) ?? '-')).toList(),
    );
  }
}

class _StatBar extends StatelessWidget {
  final String label;
  final String homeValue;
  final String awayValue;
  const _StatBar({required this.label, required this.homeValue, required this.awayValue});

  bool get _isPercent => homeValue.contains('%') || awayValue.contains('%');
  double _parse(String v) => double.tryParse(v.replaceAll('%', '').trim()) ?? 0;

  @override
  Widget build(BuildContext context) {
    final h = _parse(homeValue);
    final a = _parse(awayValue);
    final total = _isPercent ? 100.0 : (h + a == 0 ? 1 : h + a);
    final hRatio = (h / total).clamp(0.01, 0.99);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(homeValue, style: const TextStyle(color: AppColors.accent, fontSize: 14, fontWeight: FontWeight.w700)),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          Text(awayValue, style: const TextStyle(color: AppColors.live, fontSize: 14, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Row(children: [
            Flexible(flex: (hRatio * 100).round(), child: Container(height: 4, color: AppColors.accent)),
            Flexible(flex: ((1 - hRatio) * 100).round(), child: Container(height: 4, color: AppColors.live)),
          ]),
        ),
      ]),
    );
  }
}

class _TimelineTab extends StatelessWidget {
  final MatchModel match;
  const _TimelineTab({required this.match});

  @override
  Widget build(BuildContext context) {
    if (match.events.isEmpty) return const Center(child: Text('No events yet', style: TextStyle(color: AppColors.textSecondary)));
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: match.events.length,
      itemBuilder: (_, i) {
        final e = match.events[i];
        final isHome = e.teamName == match.homeTeam.name;
        final minute = e.elapsedExtra != null ? "${e.elapsed}+${e.elapsedExtra}'" : "${e.elapsed}'";
        IconData icon;
        Color color;
        switch (e.type) {
          case 'Goal': icon = Icons.sports_soccer; color = AppColors.accent; break;
          case 'Card': icon = e.detail.contains('Red') ? Icons.rectangle : Icons.rectangle_outlined; color = e.detail.contains('Red') ? AppColors.live : AppColors.draw; break;
          default: icon = Icons.swap_horiz; color = AppColors.textSecondary;
        }
        final badge = Container(
          width: 48,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8)),
          child: Text(minute, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
        );
        final info = Column(
          crossAxisAlignment: isHome ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(e.playerName, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
            if (e.assistName != null) Text('Assist: ${e.assistName}', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
          ],
        );
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(children: isHome
              ? [Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [info, const SizedBox(width: 8), Icon(icon, color: color, size: 20)])), badge, const SizedBox(width: 32)]
              : [const SizedBox(width: 32), badge, Expanded(child: Row(children: [const SizedBox(width: 8), Icon(icon, color: color, size: 20), const SizedBox(width: 8), info]))]),
        );
      },
    );
  }
}
