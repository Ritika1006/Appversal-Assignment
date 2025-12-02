import '../../models/event_model.dart';

abstract class EventState {}

class EventLoadInProgress extends EventState {}

class EventLoadSuccess extends EventState {
  final List<EventModel> events;
  EventLoadSuccess(this.events);
}

class EventLoadFailure extends EventState {
  final String error;
  EventLoadFailure(this.error);
}
