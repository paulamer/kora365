class AppStrings {
  AppStrings._();

  // App
  static const String appName = 'MatchTracker';
  static const String appTagline = 'Live Scores & Standings';

  // API — Replace with your RapidAPI key from:
  // https://rapidapi.com/api-sports/api/api-football
  static const String rapidApiKey = 'YOUR_RAPIDAPI_KEY_HERE';
  static const String apiFootballBaseUrl = 'https://api-football-v1.p.rapidapi.com/v3';
  static const String rapidApiHost = 'api-football-v1.p.rapidapi.com';

  // Default leagues (IDs from API-Football)
  static const int premierLeagueId = 39;
  static const int laLigaId = 140;
  static const int serieAId = 135;
  static const int bundesligaId = 78;
  static const int ligue1Id = 61;

  // Navigation
  static const String home = 'Home';
  static const String standings = 'Standings';
  static const String favorites = 'Favorites';
  static const String profile = 'Profile';

  // Auth
  static const String signIn = 'Sign In';
  static const String signUp = 'Sign Up';
  static const String signOut = 'Sign Out';
  static const String continueWithGoogle = 'Continue with Google';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String forgotPassword = 'Forgot Password?';
  static const String noAccount = "Don't have an account? ";
  static const String haveAccount = 'Already have an account? ';

  // Matches
  static const String liveNow = 'Live Now';
  static const String today = 'Today';
  static const String upcoming = 'Upcoming';
  static const String finished = 'Finished';
  static const String halfTime = 'HT';
  static const String fullTime = 'FT';
  static const String noMatches = 'No matches today';
  static const String noFavorites = 'No favorites yet';
  static const String addFavoriteHint = 'Tap ♥ on any match to save it here';

  // Match Detail Tabs
  static const String details = 'Details';
  static const String stats = 'Stats';
  static const String lineups = 'Lineups';
  static const String h2h = 'H2H';

  // Stats labels
  static const String possession = 'Possession';
  static const String shotsOnTarget = 'Shots on Target';
  static const String shots = 'Total Shots';
  static const String corners = 'Corners';
  static const String fouls = 'Fouls';
  static const String yellowCards = 'Yellow Cards';
  static const String redCards = 'Red Cards';
  static const String offsides = 'Offsides';

  // Standings
  static const String pos = 'P';
  static const String played = 'MP';
  static const String won = 'W';
  static const String drawn = 'D';
  static const String lost = 'L';
  static const String gd = 'GD';
  static const String points = 'Pts';

  // Errors
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'Check your internet connection.';
  static const String apiKeyMissing =
      'API key not set. Using demo data. Add your key in app_strings.dart';
}
