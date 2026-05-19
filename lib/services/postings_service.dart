import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/posting.dart';

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
  Stream<List<Posting>> watchActivePostings() {
    return _postings
        .where('status', isEqualTo: 'active')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Posting.fromFirestore(doc))
              .toList();
        });
  }

  /// Fetch a single posting by its document ID. Returns null if not found.
  Future<Posting?> getPostingById(String id) async {
    final doc = await _postings.doc(id).get();
    if (!doc.exists) return null;
    return Posting.fromFirestore(doc);
  }
}
