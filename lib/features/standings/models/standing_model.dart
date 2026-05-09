class StandingModel {
  final int rank;
  final int teamId;
  final String teamName;
  final String teamLogo;
  final int played;
  final int won;
  final int drawn;
  final int lost;
  final int goalsFor;
  final int goalsAgainst;
  final int goalDiff;
  final int points;
  final String description; // 'UCL', 'UEL', 'REL', ''

  const StandingModel({
    required this.rank,
    required this.teamId,
    required this.teamName,
    required this.teamLogo,
    required this.played,
    required this.won,
    required this.drawn,
    required this.lost,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.goalDiff,
    required this.points,
    required this.description,
  });

  factory StandingModel.fromJson(Map<String, dynamic> json) {
    final team = json['team'] as Map<String, dynamic>;
    final all = json['all'] as Map<String, dynamic>;
    final goals = all['goals'] as Map<String, dynamic>;
    return StandingModel(
      rank: json['rank'] as int,
      teamId: team['id'] as int,
      teamName: team['name'] as String,
      teamLogo: team['logo'] as String? ?? '',
      played: all['played'] as int? ?? 0,
      won: all['win'] as int? ?? 0,
      drawn: all['draw'] as int? ?? 0,
      lost: all['lose'] as int? ?? 0,
      goalsFor: goals['for'] as int? ?? 0,
      goalsAgainst: goals['against'] as int? ?? 0,
      goalDiff: json['goalsDiff'] as int? ?? 0,
      points: json['points'] as int? ?? 0,
      description: json['description'] as String? ?? '',
    );
  }
}
