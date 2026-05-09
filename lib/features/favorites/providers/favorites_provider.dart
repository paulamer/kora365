import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../matches/models/match_model.dart';

class FavoritesProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Set<int> _favoriteIds = {};
  List<MatchModel> _favoriteMatches = [];
  bool _loading = false;

  Set<int> get favoriteIds => _favoriteIds;
  List<MatchModel> get favoriteMatches => _favoriteMatches;
  bool get loading => _loading;

  String? get _uid => _auth.currentUser?.uid;

  bool isFavorite(int matchId) => _favoriteIds.contains(matchId);

  Future<void> loadFavorites() async {
    if (_uid == null) return;
    _loading = true;
    notifyListeners();
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('favorites')
          .get();

      _favoriteIds = snapshot.docs.map((d) => d['matchId'] as int).toSet();
      _favoriteMatches = snapshot.docs.map((d) {
        final data = d.data();
        return MatchModel(
          id: data['matchId'] as int,
          dateTime:
              (data['dateTime'] as Timestamp).toDate(),
          statusShort: data['statusShort'] as String? ?? 'FT',
          homeTeam: TeamInfo(
            id: data['homeId'] as int,
            name: data['homeName'] as String,
            logo: data['homeLogo'] as String,
          ),
          awayTeam: TeamInfo(
            id: data['awayId'] as int,
            name: data['awayName'] as String,
            logo: data['awayLogo'] as String,
          ),
          homeGoals: data['homeGoals'] as int?,
          awayGoals: data['awayGoals'] as int?,
          leagueName: data['leagueName'] as String? ?? '',
          leagueLogo: data['leagueLogo'] as String? ?? '',
          round: data['round'] as String? ?? '',
        );
      }).toList();
    } catch (_) {}
    _loading = false;
    notifyListeners();
  }

  Future<void> toggleFavorite(MatchModel match) async {
    if (_uid == null) return;
    final docRef = _firestore
        .collection('users')
        .doc(_uid)
        .collection('favorites')
        .doc(match.id.toString());

    if (_favoriteIds.contains(match.id)) {
      await docRef.delete();
      _favoriteIds.remove(match.id);
      _favoriteMatches.removeWhere((m) => m.id == match.id);
    } else {
      await docRef.set({
        'matchId': match.id,
        'dateTime': Timestamp.fromDate(match.dateTime),
        'statusShort': match.statusShort,
        'homeId': match.homeTeam.id,
        'homeName': match.homeTeam.name,
        'homeLogo': match.homeTeam.logo,
        'awayId': match.awayTeam.id,
        'awayName': match.awayTeam.name,
        'awayLogo': match.awayTeam.logo,
        'homeGoals': match.homeGoals,
        'awayGoals': match.awayGoals,
        'leagueName': match.leagueName,
        'leagueLogo': match.leagueLogo,
        'round': match.round,
        'savedAt': Timestamp.now(),
      });
      _favoriteIds.add(match.id);
      _favoriteMatches.insert(0, match);
    }
    notifyListeners();
  }

  void clearFavorites() {
    _favoriteIds = {};
    _favoriteMatches = [];
    notifyListeners();
  }
}
