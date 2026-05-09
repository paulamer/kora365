import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/date_formatter.dart';
import '../models/match_model.dart';

enum MatchFilter { all, live, upcoming, finished }

class MatchesProvider extends ChangeNotifier {
  List<MatchModel> _matches = [];
  MatchModel? _selectedMatch;
  bool _loading = false;
  bool _detailLoading = false;
  String? _error;
  MatchFilter _filter = MatchFilter.all;
  int _leagueId = 39; // Premier League default

  List<MatchModel> get matches => _matches;
  MatchModel? get selectedMatch => _selectedMatch;
  bool get loading => _loading;
  bool get detailLoading => _detailLoading;
  String? get error => _error;
  MatchFilter get filter => _filter;
  int get leagueId => _leagueId;

  List<MatchModel> get filteredMatches {
    switch (_filter) {
      case MatchFilter.live:
        return _matches.where((m) => m.isLive).toList();
      case MatchFilter.upcoming:
        return _matches.where((m) => m.isScheduled).toList();
      case MatchFilter.finished:
        return _matches.where((m) => m.isFinished).toList();
      case MatchFilter.all:
        return _matches;
    }
  }

  List<MatchModel> get liveMatches =>
      _matches.where((m) => m.isLive).toList();

  void setFilter(MatchFilter f) {
    _filter = f;
    notifyListeners();
  }

  void setLeague(int id) {
    _leagueId = id;
    loadTodayMatches();
  }

  Future<void> loadTodayMatches() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final today = DateFormatter.todayForApi();
      final raw = await ApiClient.fetchFixturesByDate(today, leagueId: _leagueId);
      _matches = raw
          .map((e) => MatchModel.fromJson(e as Map<String, dynamic>))
          .toList();
      // Sort: live first, then upcoming, then finished
      _matches.sort((a, b) {
        int priority(MatchModel m) {
          if (m.isLive) return 0;
          if (m.isScheduled) return 1;
          return 2;
        }
        return priority(a).compareTo(priority(b));
      });
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> loadMatchDetail(int id) async {
    _detailLoading = true;
    _selectedMatch = null;
    notifyListeners();
    try {
      final raw = await ApiClient.fetchFixtureById(id);
      if (raw != null) {
        _selectedMatch = MatchModel.fromJson(raw);
      }
    } catch (_) {}
    _detailLoading = false;
    notifyListeners();
  }

  void clearSelection() {
    _selectedMatch = null;
    notifyListeners();
  }
}
