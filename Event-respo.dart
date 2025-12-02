import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants.dart';

class EventRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<QueryDocumentSnapshot>> getEventsStream() {
    return _db.collection(AppConstants.eventsCollection).snapshots().map((snap) => snap.docs);
  }

  Future<void> incrementAttendees(String id, int count) async {
    await _db.collection(AppConstants.eventsCollection)
        .doc(id)
        .update({'attendeesCount': FieldValue.increment(count)});
  }
}
