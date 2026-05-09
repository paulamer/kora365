class MatchModel {
  final int id;
  final DateTime dateTime;
  final String statusShort;
  final int? elapsed;
  final int? elapsedExtra;
  final TeamInfo homeTeam;
  final TeamInfo awayTeam;
  final int? homeGoals;
  final int? awayGoals;
  final String leagueName;
  final String leagueLogo;
  final String round;
  final List<MatchEvent> events;
  final List<TeamStatistics> statistics;

  const MatchModel({
    required this.id,
    required this.dateTime,
    required this.statusShort,
    this.elapsed,
    this.elapsedExtra,
    required this.homeTeam,
    required this.awayTeam,
    this.homeGoals,
    this.awayGoals,
    required this.leagueName,
    required this.leagueLogo,
    required this.round,
    this.events = const [],
    this.statistics = const [],
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    final fixture = json['fixture'] as Map<String, dynamic>;
    final league = json['league'] as Map<String, dynamic>;
    final teams = json['teams'] as Map<String, dynamic>;
    final goals = json['goals'] as Map<String, dynamic>?;
    final status = fixture['status'] as Map<String, dynamic>;

    final rawEvents = json['events'] as List<dynamic>? ?? [];
    final rawStats = json['statistics'] as List<dynamic>? ?? [];

    return MatchModel(
      id: fixture['id'] as int,
      dateTime: DateTime.fromMillisecondsSinceEpoch(
          (fixture['timestamp'] as int) * 1000),
      statusShort: status['short'] as String? ?? 'NS',
      elapsed: status['elapsed'] as int?,
      elapsedExtra: status['extra'] as int?,
      homeTeam: TeamInfo.fromJson(teams['home'] as Map<String, dynamic>),
      awayTeam: TeamInfo.fromJson(teams['away'] as Map<String, dynamic>),
      homeGoals: goals?['home'] as int?,
      awayGoals: goals?['away'] as int?,
      leagueName: league['name'] as String? ?? '',
      leagueLogo: league['logo'] as String? ?? '',
      round: league['round'] as String? ?? '',
      events: rawEvents.map((e) => MatchEvent.fromJson(e as Map<String, dynamic>)).toList(),
      statistics: rawStats.map((s) => TeamStatistics.fromJson(s as Map<String, dynamic>)).toList(),
    );
  }

  bool get isLive =>
      statusShort == '1H' ||
      statusShort == '2H' ||
      statusShort == 'ET' ||
      statusShort == 'P' ||
      statusShort == 'HT';

  bool get isFinished =>
      statusShort == 'FT' ||
      statusShort == 'AET' ||
      statusShort == 'PEN';

  bool get isScheduled => statusShort == 'NS';

  String get displayStatus {
    switch (statusShort) {
      case 'NS':
        return '';
      case 'HT':
        return 'HT';
      case 'FT':
        return 'FT';
      case 'AET':
        return 'AET';
      case 'PEN':
        return 'PEN';
      default:
        return elapsed != null ? "$elapsed'" : statusShort;
    }
  }

  MatchModel copyWith({
    List<MatchEvent>? events,
    List<TeamStatistics>? statistics,
  }) =>
      MatchModel(
        id: id,
        dateTime: dateTime,
        statusShort: statusShort,
        elapsed: elapsed,
        elapsedExtra: elapsedExtra,
        homeTeam: homeTeam,
        awayTeam: awayTeam,
        homeGoals: homeGoals,
        awayGoals: awayGoals,
        leagueName: leagueName,
        leagueLogo: leagueLogo,
        round: round,
        events: events ?? this.events,
        statistics: statistics ?? this.statistics,
      );
}

class TeamInfo {
  final int id;
  final String name;
  final String logo;

  const TeamInfo({required this.id, required this.name, required this.logo});

  factory TeamInfo.fromJson(Map<String, dynamic> json) => TeamInfo(
        id: json['id'] as int,
        name: json['name'] as String,
        logo: json['logo'] as String? ?? '',
      );
}

class MatchEvent {
  final int elapsed;
  final int? elapsedExtra;
  final String type;       // Goal, Card, subst
  final String detail;     // Normal Goal, Yellow Card, etc.
  final String teamName;
  final String playerName;
  final String? assistName;

  const MatchEvent({
    required this.elapsed,
    this.elapsedExtra,
    required this.type,
    required this.detail,
    required this.teamName,
    required this.playerName,
    this.assistName,
  });

  factory MatchEvent.fromJson(Map<String, dynamic> json) {
    final time = json['time'] as Map<String, dynamic>;
    final team = json['team'] as Map<String, dynamic>?;
    final player = json['player'] as Map<String, dynamic>?;
    final assist = json['assist'] as Map<String, dynamic>?;
    return MatchEvent(
      elapsed: time['elapsed'] as int? ?? 0,
      elapsedExtra: time['extra'] as int?,
      type: json['type'] as String? ?? '',
      detail: json['detail'] as String? ?? '',
      teamName: team?['name'] as String? ?? '',
      playerName: player?['name'] as String? ?? '',
      assistName: assist?['name'] as String?,
    );
  }
}

class TeamStatistics {
  final String teamName;
  final Map<String, dynamic> stats;

  const TeamStatistics({required this.teamName, required this.stats});

  factory TeamStatistics.fromJson(Map<String, dynamic> json) {
    final team = json['team'] as Map<String, dynamic>;
    final rawStats = json['statistics'] as List<dynamic>? ?? [];
    final statsMap = <String, dynamic>{};
    for (final s in rawStats) {
      final entry = s as Map<String, dynamic>;
      statsMap[entry['type'] as String] = entry['value'];
    }
    return TeamStatistics(
      teamName: team['name'] as String,
      stats: statsMap,
    );
  }

  String? getStat(String key) => stats[key]?.toString();
}
