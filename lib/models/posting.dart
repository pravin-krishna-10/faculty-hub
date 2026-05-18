import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a single posting (faculty job, JRF, internship, etc.) on FacultyHub.
///
/// Maps to a document in the Firestore `postings` collection.
/// Field names use snake_case in Firestore but camelCase in Dart code.
class Posting {
  final String id;

  // Position & employment classification
  final String positionType; // e.g. "asst_prof", "jrf"
  final String employmentType; // e.g. "full_time_permanent", "part_time"

  // What the position is for
  final String discipline; // e.g. "Computer Science"
  final String? specialization; // e.g. "Machine Learning, NLP"

  // Where
  final String instituteName;
  final String city;

  // When & how
  final DateTime deadline;
  final String howToApply; // Email or URL

  // Trust
  final String source; // "official" or "heard"

  // Optional content
  final String? salaryRange; // "8-12 LPA" or "37000/month"
  final String? duration; // "2 years", "1 semester" — required if not permanent
  final String? description; // Free-form catch-all

  // Poster info (denormalized for fast feed reads)
  final String postedByUid;
  final String postedByName;
  final String postedByInstitute;
  final String postedByRole; // "faculty" or "recruiter"

  // Lifecycle
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime expiresAt;
  final String status; // "active", "expired", "reported", "deleted"

  const Posting({
    required this.id,
    required this.positionType,
    required this.employmentType,
    required this.discipline,
    this.specialization,
    required this.instituteName,
    required this.city,
    required this.deadline,
    required this.howToApply,
    required this.source,
    this.salaryRange,
    this.duration,
    this.description,
    required this.postedByUid,
    required this.postedByName,
    required this.postedByInstitute,
    required this.postedByRole,
    required this.createdAt,
    required this.updatedAt,
    required this.expiresAt,
    required this.status,
  });

  /// Construct a Posting from a Firestore document snapshot.
  /// Used when reading from Firestore.
  factory Posting.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Posting(
      id: doc.id,
      positionType: data['position_type'] as String,
      employmentType: data['employment_type'] as String,
      discipline: data['discipline'] as String,
      specialization: data['specialization'] as String?,
      instituteName: data['institute_name'] as String,
      city: data['city'] as String,
      deadline: (data['deadline'] as Timestamp).toDate(),
      howToApply: data['how_to_apply'] as String,
      source: data['source'] as String,
      salaryRange: data['salary_range'] as String?,
      duration: data['duration'] as String?,
      description: data['description'] as String?,
      postedByUid: data['posted_by_uid'] as String,
      postedByName: data['posted_by_name'] as String,
      postedByInstitute: data['posted_by_institute'] as String,
      postedByRole: data['posted_by_role'] as String,
      createdAt: (data['created_at'] as Timestamp).toDate(),
      updatedAt: (data['updated_at'] as Timestamp).toDate(),
      expiresAt: (data['expires_at'] as Timestamp).toDate(),
      status: data['status'] as String,
    );
  }

  /// Convert this Posting back to a Map for writing to Firestore.
  /// Used when creating or updating documents.
  Map<String, dynamic> toFirestore() {
    return {
      'position_type': positionType,
      'employment_type': employmentType,
      'discipline': discipline,
      if (specialization != null) 'specialization': specialization,
      'institute_name': instituteName,
      'city': city,
      'deadline': Timestamp.fromDate(deadline),
      'how_to_apply': howToApply,
      'source': source,
      if (salaryRange != null) 'salary_range': salaryRange,
      if (duration != null) 'duration': duration,
      if (description != null) 'description': description,
      'posted_by_uid': postedByUid,
      'posted_by_name': postedByName,
      'posted_by_institute': postedByInstitute,
      'posted_by_role': postedByRole,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
      'expires_at': Timestamp.fromDate(expiresAt),
      'status': status,
    };
  }
}
