/// App-wide constants.
abstract final class AppConstants {
  /// App name.
  static const String appName = 'Cultainer';

  /// App version.
  static const String appVersion = '0.1.0';

  /// Default animation duration.
  static const Duration animationDuration = Duration(milliseconds: 300);

  /// Default page padding.
  static const double pagePadding = 20;

  /// Card border radius.
  static const double cardBorderRadius = 16;

  /// Large card border radius.
  static const double cardBorderRadiusLarge = 20;

  /// Button border radius.
  static const double buttonBorderRadius = 12;

  /// Chip border radius.
  static const double chipBorderRadius = 20;

  /// Maximum rating value (10-point scale).
  static const double maxRating = 10;

  /// Rating step (0.5 increments).
  static const double ratingStep = 0.5;

  /// Maximum file lines per file.
  static const int maxLinesPerFile = 300;
}

/// Firebase collection paths.
abstract final class FirebasePaths {
  static const String users = 'users';
  static const String profile = 'profile';
  static const String entries = 'entries';
  static const String tags = 'tags';
  static const String excerpts = 'excerpts';
}

/// External API base URLs.
abstract final class ApiUrls {
  static const String googleBooks = 'https://www.googleapis.com/books/v1';
  static const String tmdb = 'https://api.themoviedb.org/3';
  static const String tmdbImage = 'https://image.tmdb.org/t/p';
  static const String spotify = 'https://api.spotify.com/v1';
}
