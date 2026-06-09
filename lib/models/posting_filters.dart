/// Holds the currently active filters for the home feed.
/// All fields are nullable — null means "no filter applied for this field".

enum PostingSegment { all, faculty, research }

class PostingFilters {
  final String? discipline;
  final String? positionType;
  final String? city;
  final String? source;
  final PostingSegment segment;
  final String? searchQuery;

  const PostingFilters({
    this.segment = PostingSegment.all,
    this.discipline,
    this.positionType,
    this.city,
    this.source,
    this.searchQuery,
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
    String? searchQuery,
    bool clearDiscipline = false,
    bool clearPositionType = false,
    bool clearCity = false,
    bool clearSource = false,
    bool clearSearch = false,
  }) {
    return PostingFilters(
      segment: segment ?? this.segment,
      discipline: clearDiscipline ? null : (discipline ?? this.discipline),
      positionType: clearPositionType
          ? null
          : (positionType ?? this.positionType),
      city: clearCity ? null : (city ?? this.city),
      source: clearSource ? null : (source ?? this.source),
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
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

  /// Filters a list of postings by the current searchQuery.
  /// Returns the input list if searchQuery is null or empty.
  /// Searches across: institute, discipline, specialization, city, description.
  List<dynamic> applySearch(List<dynamic> postings) {
    if (searchQuery == null || searchQuery!.trim().isEmpty) {
      return postings;
    }
    final q = searchQuery!.toLowerCase().trim();
    return postings.where((p) {
      final fields = [
        p.instituteName,
        p.discipline,
        p.specialization ?? '',
        p.city,
        p.description ?? '',
      ];
      return fields.any((f) => f.toString().toLowerCase().contains(q));
    }).toList();
  }
}
