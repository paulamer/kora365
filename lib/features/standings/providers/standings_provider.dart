import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../models/standing_model.dart';

class StandingsProvider extends ChangeNotifier {
  List<StandingModel> _standings = [];
  bool _loading = false;
  String? _error;
  int _leagueId = 39;
  int _season = 2024;

  List<StandingModel> get standings => _standings;
  bool get loading => _loading;
  String? get error => _error;
  int get leagueId => _leagueId;

  void setLeague(int id) {
    _leagueId = id;
    loadStandings();
  }

  Future<void> loadStandings() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final raw = await ApiClient.fetchStandings(
          leagueId: _leagueId, season: _season);
      _standings = raw
          .map((e) => StandingModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }
}
