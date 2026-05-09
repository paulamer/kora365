import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_strings.dart';

class ApiClient {
  static const _headers = {
    'X-RapidAPI-Key': AppStrings.rapidApiKey,
    'X-RapidAPI-Host': AppStrings.rapidApiHost,
  };

  static bool get _hasApiKey =>
      AppStrings.rapidApiKey != 'YOUR_RAPIDAPI_KEY_HERE' &&
      AppStrings.rapidApiKey.isNotEmpty;

  /// Fetch fixtures for a given date (format: 'yyyy-MM-dd')
  static Future<List<dynamic>> fetchFixturesByDate(String date,
      {int leagueId = AppStrings.premierLeagueId, int season = 2024}) async {
    if (!_hasApiKey) return _mockFixtures();
    try {
      final uri = Uri.parse(
        '${AppStrings.apiFootballBaseUrl}/fixtures?date=$date&league=$leagueId&season=$season',
      );
      final response = await http.get(uri, headers: _headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] as List<dynamic>;
      }
    } catch (_) {}
    return _mockFixtures();
  }

  /// Fetch live fixtures
  static Future<List<dynamic>> fetchLiveFixtures() async {
    if (!_hasApiKey) return _mockLiveFixtures();
    try {
      final uri = Uri.parse(
          '${AppStrings.apiFootballBaseUrl}/fixtures?live=all');
      final response = await http.get(uri, headers: _headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] as List<dynamic>;
      }
    } catch (_) {}
    return _mockLiveFixtures();
  }

  /// Fetch fixture details + statistics
  static Future<Map<String, dynamic>?> fetchFixtureById(int id) async {
    if (!_hasApiKey) return _mockFixtureDetail(id);
    try {
      final uri =
          Uri.parse('${AppStrings.apiFootballBaseUrl}/fixtures?id=$id');
      final response = await http.get(uri, headers: _headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = data['response'] as List<dynamic>;
        return list.isNotEmpty ? list[0] as Map<String, dynamic> : null;
      }
    } catch (_) {}
    return _mockFixtureDetail(id);
  }

  /// Fetch standings for a league & season
  static Future<List<dynamic>> fetchStandings(
      {int leagueId = AppStrings.premierLeagueId, int season = 2024}) async {
    if (!_hasApiKey) return _mockStandings();
    try {
      final uri = Uri.parse(
          '${AppStrings.apiFootballBaseUrl}/standings?league=$leagueId&season=$season');
      final response = await http.get(uri, headers: _headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final resp = data['response'] as List<dynamic>;
        if (resp.isNotEmpty) {
          return resp[0]['league']['standings'][0] as List<dynamic>;
        }
      }
    } catch (_) {}
    return _mockStandings();
  }

  // ─── Mock data used when no API key is set ───────────────────────────────

  static List<dynamic> _mockFixtures() => [
        ..._mockLiveFixtures(),
        _buildFixture(
          id: 101,
          home: 'Manchester City', homeLogo: 'https://media.api-sports.io/football/teams/50.png',
          away: 'Chelsea', awayLogo: 'https://media.api-sports.io/football/teams/49.png',
          homeGoals: null,
          awayGoals: null,
          elapsed: null,
          status: 'NS',
          leagueName: 'Premier League',
          timestamp: DateTime.now().add(const Duration(hours: 3)).millisecondsSinceEpoch ~/ 1000,
        ),
        _buildFixture(
          id: 102,
          home: 'Real Madrid', homeLogo: 'https://media.api-sports.io/football/teams/541.png',
          away: 'Barcelona', awayLogo: 'https://media.api-sports.io/football/teams/529.png',
          homeGoals: null,
          awayGoals: null,
          elapsed: null,
          status: 'NS',
          leagueName: 'La Liga',
          timestamp: DateTime.now().add(const Duration(hours: 5)).millisecondsSinceEpoch ~/ 1000,
        ),
        _buildFixture(
          id: 103,
          home: 'PSG', homeLogo: 'https://media.api-sports.io/football/teams/85.png',
          away: 'Marseille', awayLogo: 'https://media.api-sports.io/football/teams/81.png',
          homeGoals: 2,
          awayGoals: 1,
          elapsed: null,
          status: 'FT',
          leagueName: 'Ligue 1',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)).millisecondsSinceEpoch ~/ 1000,
        ),
        _buildFixture(
          id: 104,
          home: 'Bayern Munich', homeLogo: 'https://media.api-sports.io/football/teams/157.png',
          away: 'Dortmund', awayLogo: 'https://media.api-sports.io/football/teams/165.png',
          homeGoals: 3,
          awayGoals: 0,
          elapsed: null,
          status: 'FT',
          leagueName: 'Bundesliga',
          timestamp: DateTime.now().subtract(const Duration(hours: 4)).millisecondsSinceEpoch ~/ 1000,
        ),
      ];

  static List<dynamic> _mockLiveFixtures() => [
        _buildFixture(
          id: 201,
          home: 'Liverpool', homeLogo: 'https://media.api-sports.io/football/teams/40.png',
          away: 'Arsenal', awayLogo: 'https://media.api-sports.io/football/teams/42.png',
          homeGoals: 2,
          awayGoals: 1,
          elapsed: 67,
          status: '2H',
          leagueName: 'Premier League',
          timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        ),
        _buildFixture(
          id: 202,
          home: 'AC Milan', homeLogo: 'https://media.api-sports.io/football/teams/489.png',
          away: 'Juventus', awayLogo: 'https://media.api-sports.io/football/teams/496.png',
          homeGoals: 1,
          awayGoals: 1,
          elapsed: 45,
          status: 'HT',
          leagueName: 'Serie A',
          timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        ),
      ];

  static Map<String, dynamic> _buildFixture({
    required int id,
    required String home,
    required String homeLogo,
    required String away,
    required String awayLogo,
    required int? homeGoals,
    required int? awayGoals,
    required int? elapsed,
    required String status,
    required String leagueName,
    required int timestamp,
  }) =>
      {
        'fixture': {
          'id': id,
          'timestamp': timestamp,
          'status': {'short': status, 'elapsed': elapsed}
        },
        'league': {
          'id': AppStrings.premierLeagueId,
          'name': leagueName,
          'country': 'England',
          'logo': 'https://media.api-sports.io/football/leagues/39.png',
          'flag': 'https://media.api-sports.io/flags/gb.svg',
          'round': 'Regular Season - 30',
        },
        'teams': {
          'home': {
            'id': id * 10,
            'name': home,
            'logo': homeLogo,
          },
          'away': {
            'id': id * 10 + 1,
            'name': away,
            'logo': awayLogo,
          },
        },
        'goals': {'home': homeGoals, 'away': awayGoals},
        'score': {
          'halftime': {'home': homeGoals, 'away': awayGoals},
          'fulltime': {'home': homeGoals, 'away': awayGoals},
        },
        'events': _mockEvents(home, away),
        'statistics': _mockStatistics(home, away),
      };

  static List<dynamic> _mockEvents(String home, String away) => [
        {
          'time': {'elapsed': 15, 'extra': null},
          'type': 'Goal',
          'detail': 'Normal Goal',
          'team': {'name': home},
          'player': {'name': 'M. Salah'},
          'assist': {'name': 'A. Robertson'},
        },
        {
          'time': {'elapsed': 33, 'extra': null},
          'type': 'Card',
          'detail': 'Yellow Card',
          'team': {'name': away},
          'player': {'name': 'T. Partey'},
          'assist': null,
        },
        {
          'time': {'elapsed': 56, 'extra': null},
          'type': 'Goal',
          'detail': 'Normal Goal',
          'team': {'name': home},
          'player': {'name': 'D. Núñez'},
          'assist': {'name': 'M. Salah'},
        },
        {
          'time': {'elapsed': 62, 'extra': null},
          'type': 'Goal',
          'detail': 'Normal Goal',
          'team': {'name': away},
          'player': {'name': 'B. Saka'},
          'assist': {'name': 'M. Ødegaard'},
        },
      ];

  static List<dynamic> _mockStatistics(String home, String away) => [
        {
          'team': {'name': home},
          'statistics': [
            {'type': 'Ball Possession', 'value': '54%'},
            {'type': 'Total Shots', 'value': 12},
            {'type': 'Shots on Goal', 'value': 5},
            {'type': 'Corner Kicks', 'value': 6},
            {'type': 'Fouls', 'value': 9},
            {'type': 'Yellow Cards', 'value': 1},
            {'type': 'Red Cards', 'value': 0},
            {'type': 'Offsides', 'value': 2},
          ],
        },
        {
          'team': {'name': away},
          'statistics': [
            {'type': 'Ball Possession', 'value': '46%'},
            {'type': 'Total Shots', 'value': 9},
            {'type': 'Shots on Goal', 'value': 3},
            {'type': 'Corner Kicks', 'value': 4},
            {'type': 'Fouls', 'value': 14},
            {'type': 'Yellow Cards', 'value': 2},
            {'type': 'Red Cards', 'value': 0},
            {'type': 'Offsides', 'value': 1},
          ],
        },
      ];

  static Map<String, dynamic>? _mockFixtureDetail(int id) {
    final fixtures = _mockFixtures();
    try {
      return fixtures.firstWhere(
        (f) => f['fixture']['id'] == id,
        orElse: () => null,
      ) as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  static List<dynamic> _mockStandings() => [
        _buildStanding(1, 'Liverpool', 40, 30, 22, 5, 3, 71, 32, 71, 'UCL'),
        _buildStanding(2, 'Arsenal', 42, 30, 21, 5, 4, 65, 30, 68, 'UCL'),
        _buildStanding(3, 'Manchester City', 50, 30, 20, 6, 4, 68, 38, 66, 'UCL'),
        _buildStanding(4, 'Chelsea', 49, 30, 18, 5, 7, 60, 42, 59, 'UCL'),
        _buildStanding(5, 'Aston Villa', 66, 30, 17, 6, 7, 58, 45, 57, 'UEL'),
        _buildStanding(6, 'Newcastle', 34, 30, 16, 7, 7, 55, 40, 55, 'UEL'),
        _buildStanding(7, 'Manchester United', 33, 30, 13, 8, 9, 44, 46, 47, ''),
        _buildStanding(8, 'Tottenham', 47, 30, 13, 6, 11, 50, 52, 45, ''),
        _buildStanding(9, 'Brighton', 51, 30, 12, 9, 9, 55, 50, 45, ''),
        _buildStanding(10, 'West Ham', 48, 30, 12, 6, 12, 44, 52, 42, ''),
        _buildStanding(11, 'Fulham', 36, 30, 11, 7, 12, 40, 46, 40, ''),
        _buildStanding(12, 'Brentford', 55, 30, 10, 9, 11, 45, 50, 39, ''),
        _buildStanding(13, 'Crystal Palace', 52, 30, 9, 10, 11, 38, 45, 37, ''),
        _buildStanding(14, 'Wolves', 39, 30, 9, 7, 14, 35, 52, 34, ''),
        _buildStanding(15, 'Everton', 45, 30, 8, 9, 13, 30, 45, 33, ''),
        _buildStanding(16, 'Nottm Forest', 65, 30, 7, 10, 13, 32, 48, 31, ''),
        _buildStanding(17, 'Bournemouth', 35, 30, 7, 9, 14, 35, 55, 30, ''),
        _buildStanding(18, 'Luton', 1359, 30, 6, 6, 18, 28, 65, 24, 'REL'),
        _buildStanding(19, 'Burnley', 44, 30, 4, 9, 17, 25, 68, 21, 'REL'),
        _buildStanding(20, 'Sheffield Utd', 62, 30, 3, 6, 21, 20, 80, 15, 'REL'),
      ];

  static Map<String, dynamic> _buildStanding(
    int rank,
    String teamName,
    int teamId,
    int played,
    int won,
    int drawn,
    int lost,
    int goalsFor,
    int goalsAgainst,
    int points,
    String description,
  ) =>
      {
        'rank': rank,
        'team': {
          'id': teamId,
          'name': teamName,
          'logo': 'https://media.api-sports.io/football/teams/$teamId.png',
        },
        'all': {
          'played': played,
          'win': won,
          'draw': drawn,
          'lose': lost,
          'goals': {'for': goalsFor, 'against': goalsAgainst},
        },
        'goalsDiff': goalsFor - goalsAgainst,
        'points': points,
        'description': description,
      };
}
