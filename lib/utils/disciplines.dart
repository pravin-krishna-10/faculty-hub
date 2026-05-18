/// The flat list of academic disciplines supported in v0.
/// Keep this in sync with the Firestore data — never use values not in this list
/// (except "Other" with the free-text fallback).
class Disciplines {
  static const List<String> all = [
    // Engineering & Technology
    'Computer Science',
    'Information Technology',
    'Electronics and Communication',
    'Electrical Engineering',
    'Mechanical Engineering',
    'Civil Engineering',
    'Chemical Engineering',
    'Aerospace Engineering',
    'Biotechnology',
    'Biomedical Engineering',
    'Industrial Engineering',
    'Materials Science',
    'Metallurgical Engineering',
    'Mining Engineering',
    'Petroleum Engineering',
    'Textile Engineering',
    'Agricultural Engineering',

    // Natural Sciences
    'Physics',
    'Chemistry',
    'Mathematics',
    'Statistics',
    'Biology',
    'Biochemistry',
    'Microbiology',
    'Botany',
    'Zoology',
    'Earth Sciences',
    'Environmental Science',

    // Humanities & Social Sciences
    'English',
    'Hindi',
    'History',
    'Philosophy',
    'Sociology',
    'Psychology',
    'Political Science',
    'Public Administration',
    'Economics',
    'Linguistics',
    'Geography',
    'Anthropology',

    // Commerce & Management
    'Commerce',
    'Accounting and Finance',
    'Management',
    'Marketing',
    'Human Resource Management',
    'Operations Management',

    // Professional & Applied
    'Law',
    'Medicine',
    'Pharmacy',
    'Architecture',
    'Design',
    'Education',
    'Library Science',
    'Journalism',

    // Other (with free-text fallback)
    'Other',
  ];
}
