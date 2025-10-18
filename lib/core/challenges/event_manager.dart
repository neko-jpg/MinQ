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
    // TODO: Implement logic to save the event to Firestore.
    print("Creating event: ${event.name}");
  }

  /// Fetches the currently active events.
  Future<List<Event>> getActiveEvents() async {
    // TODO: Implement logic to query Firestore for events where the current date
    // is between the start and end dates.
    return [];
  }

  /// Registers a user for an event.
  Future<void> registerForEvent({
    required String userId,
    required String eventId,
  }) async {
    // TODO: Add user to the list of participants for the event.
    print("User $userId registered for event $eventId.");
  }
}