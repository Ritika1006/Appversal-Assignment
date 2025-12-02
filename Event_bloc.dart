import 'package:flutter_bloc/flutter_bloc.dart';
import 'event_event.dart';
import 'event_state.dart';
import '../../repositories/event_repository.dart';
import '../../models/event_model.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final EventRepository _repo;
  EventBloc(this._repo) : super(EventLoadInProgress()) {
    on<LoadEvents>((event, emit) {
      _repo.getEventsStream().listen((docs) {
        final events = docs.map((d) => EventModel.fromDoc(d)).toList();
        emit(EventLoadSuccess(events));
      });
    });
  }
}
