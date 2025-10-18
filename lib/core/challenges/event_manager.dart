import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/domain/challenges/event.dart';

// Provider for the manager
final eventManagerProvider = Provider<EventManager>((ref) {
  return EventManager(FirebaseFirestore.instance);
});

class EventManager {
  final FirebaseFirestore _firestore;

  EventManager(this._firestore);

  /// Creates a new event.
  Future<void> createEvent(Event event) async {
    try {
      await _firestore
          .collection('events')
          .doc(event.id)
          .set(event.toJson());
      print("Event '${event.name}' created successfully.");
    } catch (e) {
      print("Error creating event: $e");
    }
  }

  /// Fetches the currently active events.
  Future<List<Event>> getActiveEvents() async {
    try {
      final now = DateTime.now();
      final snapshot = await _firestore
          .collection('events')
          .where('startDate', isLessThanOrEqualTo: now)
          .where('endDate', isGreaterThanOrEqualTo: now)
          .get();

      return snapshot.docs.map((doc) => Event.fromJson(doc.data())).toList();
    } catch (e) {
      print("Error fetching active events: $e");
      return [];
    }
  }

  /// Registers a user for an event.
  Future<void> registerForEvent({
    required String userId,
    required String eventId,
  }) async {
    try {
      await _firestore
          .collection('events')
          .doc(eventId)
          .collection('participants')
          .doc(userId)
          .set({'registeredAt': FieldValue.serverTimestamp()});
      print("User $userId registered for event $eventId.");
    } catch (e) {
      print("Error registering user for event: $e");
    }
  }
}