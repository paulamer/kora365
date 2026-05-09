import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:match_tracker/core/constants/app_colors.dart';
import 'package:match_tracker/core/utils/date_formatter.dart';
import 'package:match_tracker/features/matches/models/match_model.dart';
import 'package:match_tracker/features/favorites/providers/favorites_provider.dart';
import 'package:match_tracker/features/matches/widgets/live_badge.dart';

class MatchCard extends StatelessWidget {
  final MatchModel match;
  final VoidCallback onTap;
  final bool compact;

  const MatchCard({
    super.key,
    required this.match,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: match.isLive
                ? AppColors.live.withOpacity(0.3)
                : AppColors.border,
            width: match.isLive ? 1.0 : 0.5,
          ),
          boxShadow: match.isLive
              ? [
                  BoxShadow(
                    color: AppColors.live.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // League row + favorite
              Row(
                children: [
                  _LeagueLogo(url: match.leagueLogo),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      match.leagueName,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (match.isLive) const LiveBadge(),
                  if (!match.isLive)
                    Text(
                      match.isFinished
                          ? match.displayStatus
                          : DateFormatter.matchTime(match.dateTime),
                      style: TextStyle(
                        color: match.isFinished
                            ? AppColors.textMuted
                            : AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const SizedBox(width: 8),
                  _FavoriteButton(match: match),
                ],
              ),
              const SizedBox(height: 14),
              // Score row
              Row(
                children: [
                  // Home team
                  Expanded(
                    child: _TeamRow(
                      name: match.homeTeam.name,
                      logo: match.homeTeam.logo,
                      isHome: true,
                    ),
                  ),
                  // Score / time
                  _ScoreDisplay(match: match),
                  // Away team
                  Expanded(
                    child: _TeamRow(
                      name: match.awayTeam.name,
                      logo: match.awayTeam.logo,
                      isHome: false,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeamRow extends StatelessWidget {
  final String name;
  final String logo;
  final bool isHome;

  const _TeamRow({required this.name, required this.logo, required this.isHome});

  @override
  Widget build(BuildContext context) {
    final content = [
      _TeamLogo(url: logo, size: 36),
      const SizedBox(width: 8),
      Flexible(
        child: Text(
          name,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: isHome ? TextAlign.start : TextAlign.end,
        ),
      ),
    ];

    return Row(
      mainAxisAlignment:
          isHome ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: isHome ? content : content.reversed.toList(),
    );
  }
}

class _ScoreDisplay extends StatelessWidget {
  final MatchModel match;
  const _ScoreDisplay({required this.match});

  @override
  Widget build(BuildContext context) {
    if (match.isScheduled) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          DateFormatter.matchTime(match.dateTime),
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    final homeColor = match.homeGoals != null &&
            match.awayGoals != null &&
            match.homeGoals! > match.awayGoals!
        ? AppColors.accent
        : AppColors.textPrimary;
    final awayColor = match.homeGoals != null &&
            match.awayGoals != null &&
            match.awayGoals! > match.homeGoals!
        ? AppColors.accent
        : AppColors.textPrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${match.homeGoals ?? "-"}',
                style: TextStyle(
                  color: homeColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  ':',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${match.awayGoals ?? "-"}',
                style: TextStyle(
                  color: awayColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          if (match.isLive && match.elapsed != null)
            Text(
              "${match.elapsed}'",
              style: const TextStyle(
                color: AppColors.live,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          if (match.isFinished)
            const Text(
              'FT',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  final MatchModel match;
  const _FavoriteButton({required this.match});

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesProvider>(
      builder: (_, fav, __) {
        final isFav = fav.isFavorite(match.id);
        return GestureDetector(
          onTap: () => fav.toggleFavorite(match),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              key: ValueKey(isFav),
              color: isFav ? AppColors.live : AppColors.textMuted,
              size: 18,
            ),
          ),
        );
      },
    );
  }
}

class _TeamLogo extends StatelessWidget {
  final String url;
  final double size;
  const _TeamLogo({required this.url, required this.size});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      width: size,
      height: size,
      placeholder: (_, __) => Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
        ),
      ),
      errorWidget: (_, __, ___) => Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.sports_soccer,
            color: AppColors.textMuted, size: 18),
      ),
    );
  }
}

class _LeagueLogo extends StatelessWidget {
  final String url;
  const _LeagueLogo({required this.url});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      width: 16,
      height: 16,
      errorWidget: (_, __, ___) => const Icon(
        Icons.emoji_events,
        color: AppColors.accent,
        size: 14,
      ),
    );
  }
}
