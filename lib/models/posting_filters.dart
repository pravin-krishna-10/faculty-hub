/// Holds the currently active filters for the home feed.
/// All fields are nullable — null means "no filter applied for this field".
class PostingFilters {
  final String? discipline;
  final String? positionType;
  final String? city;
  final String? source;

  const PostingFilters({
    this.discipline,
    this.positionType,
    this.city,
    this.source,
  });

  /// Returns true if any filter is active.
  bool get isAnyActive =>
      discipline != null ||
      positionType != null ||
      city != null ||
      source != null;

  /// Returns a copy with one or more fields changed.
  /// Pass `clearX: true` to explicitly clear a field.
  PostingFilters copyWith({
    String? discipline,
    String? positionType,
    String? city,
    String? source,
    bool clearDiscipline = false,
    bool clearPositionType = false,
    bool clearCity = false,
    bool clearSource = false,
  }) {
    return PostingFilters(
      discipline: clearDiscipline ? null : (discipline ?? this.discipline),
      positionType: clearPositionType
          ? null
          : (positionType ?? this.positionType),
      city: clearCity ? null : (city ?? this.city),
      source: clearSource ? null : (source ?? this.source),
    );
  }
}
