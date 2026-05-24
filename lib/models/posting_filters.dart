/// Holds the currently active filters for the home feed.
/// All fields are nullable — null means "no filter applied for this field".

enum PostingSegment { all, faculty, research }

class PostingFilters {
  final String? discipline;
  final String? positionType;
  final String? city;
  final String? source;
  final PostingSegment segment;

  const PostingFilters({
    this.segment = PostingSegment.all,
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
    PostingSegment? segment,
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
      segment: segment ?? this.segment,
      discipline: clearDiscipline ? null : (discipline ?? this.discipline),
      positionType: clearPositionType
          ? null
          : (positionType ?? this.positionType),
      city: clearCity ? null : (city ?? this.city),
      source: clearSource ? null : (source ?? this.source),
    );
  }

  /// Returns the list of position_type keys that belong to the current segment.
  /// Returns null for "All" — meaning don't filter by position type group.
  List<String>? get segmentPositionTypes {
    switch (segment) {
      case PostingSegment.all:
        return null;
      case PostingSegment.faculty:
        return const [
          'asst_prof',
          'assoc_prof',
          'professor',
          'visiting_faculty',
          'adjunct',
        ];
      case PostingSegment.research:
        return const [
          'jrf',
          'srf',
          'project_associate',
          'phd_position',
          'postdoc',
          'internship',
        ];
    }
  }
}
