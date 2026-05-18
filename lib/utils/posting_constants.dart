/// Position type values. The string keys are what gets stored in Firestore.
/// The display labels are what users see in dropdowns and cards.
class PositionType {
  static const Map<String, String> values = {
    'asst_prof': 'Assistant Professor',
    'assoc_prof': 'Associate Professor',
    'professor': 'Professor',
    'visiting_faculty': 'Visiting Faculty',
    'adjunct': 'Adjunct Faculty',
    'jrf': 'JRF',
    'srf': 'SRF',
    'project_associate': 'Project Associate',
    'phd_position': 'PhD Position',
    'postdoc': 'Postdoc',
    'internship': 'Internship',
    'other': 'Other',
  };

  static String displayLabel(String key) => values[key] ?? key;
}

/// Employment type values.
class EmploymentType {
  static const Map<String, String> values = {
    'full_time_permanent': 'Full-time permanent',
    'full_time_contract': 'Full-time contract',
    'part_time': 'Part-time',
    'visiting_semester': 'Visiting (semester-based)',
    'adjunct_course_based': 'Adjunct (course-based)',
    'hourly': 'Hourly',
    'project_based': 'Project-based',
  };

  static String displayLabel(String key) => values[key] ?? key;

  /// Returns true for non-permanent positions, which need a Duration field.
  static bool requiresDuration(String key) {
    return key != 'full_time_permanent';
  }
}

/// Source of the posting — whether it's officially announced or "heard internally."
class PostingSource {
  static const String official = 'official';
  static const String heard = 'heard';
}

/// Status of a posting.
class PostingStatus {
  static const String active = 'active';
  static const String expired = 'expired';
  static const String reported = 'reported';
  static const String deleted = 'deleted';
}

/// Role of the user who posted — faculty member or recruiter.
class PosterRole {
  static const String faculty = 'faculty';
  static const String recruiter = 'recruiter';
}
