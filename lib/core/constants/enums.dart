/// Media types supported by Cultainer.
enum MediaType {
  book('book', 'Book'),
  movie('movie', 'Movie'),
  tv('tv', 'TV Show'),
  music('music', 'Music'),
  other('other', 'Other');

  const MediaType(this.value, this.label);

  final String value;
  final String label;

  static MediaType fromValue(String value) {
    return MediaType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => MediaType.other,
    );
  }
}

/// Entry status options.
enum EntryStatus {
  wishlist('wishlist', 'Wishlist'),
  inProgress('in-progress', 'In Progress'),
  completed('completed', 'Completed'),
  dropped('dropped', 'Dropped'),
  recall('recall', 'Recall');

  const EntryStatus(this.value, this.label);

  final String value;
  final String label;

  static EntryStatus fromValue(String value) {
    return EntryStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => EntryStatus.wishlist,
    );
  }
}
