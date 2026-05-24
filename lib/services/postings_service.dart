import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/posting.dart';
import '../models/posting_filters.dart';

/// Holds the currently active filters for the home feed.
/// All fields are nullable — null means "no filter applied for this field".

/// Wraps Firestore reads for the postings collection.
///
/// Keeps all Firestore query logic in one place so screens don't have to
/// know about collection names, field names, or query construction.
class PostingsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Reference to the postings collection.
  CollectionReference get _postings => _firestore.collection('postings');

  /// Stream of all active postings, ordered by most recently created first.
  ///
  /// Returns a Stream so the UI can listen for real-time updates — when a
  /// new posting is added to Firestore, the stream emits a new list and
  /// the UI rebuilds automatically.
  Stream<List<Posting>> watchActivePostings({PostingFilters? filters}) {
    Query query = _postings.where('status', isEqualTo: 'active');

    if (filters?.discipline != null) {
      query = query.where('discipline', isEqualTo: filters!.discipline);
    }
    if (filters?.positionType != null) {
      query = query.where('position_type', isEqualTo: filters!.positionType);
    }
    if (filters?.city != null) {
      query = query.where('city', isEqualTo: filters!.city);
    }
    if (filters?.source != null) {
      query = query.where('source', isEqualTo: filters!.source);
    }
    // Segment filter: if a group is selected, use whereIn on position_type.
    // Only applies when no specific positionType is already set.
    if (filters != null &&
        filters.positionType == null &&
        filters.segmentPositionTypes != null) {
      query = query.where(
        'position_type',
        whereIn: filters.segmentPositionTypes,
      );
    }

    query = query.orderBy('created_at', descending: true);

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Posting.fromFirestore(doc)).toList();
    });
  }

  /// Fetch a single posting by its document ID. Returns null if not found.
  Future<Posting?> getPostingById(String id) async {
    final doc = await _postings.doc(id).get();
    if (!doc.exists) return null;
    return Posting.fromFirestore(doc);
  }
}
