import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/events/event_bloc.dart';
import '../../blocs/events/event_state.dart';
import '../../models/event_model.dart';
import 'create_event_screen.dart';
import '../widgets/event_card.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';

class HomeScreen extends StatefulWidget {
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    String? role;
    if (authState is Authenticated) role = authState.role;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('EventSyncPro'),
          bottom: TabBar(tabs: [Tab(text: 'Upcoming'), Tab(text: 'Ongoing'), Tab(text: 'Completed')]),
        ),
        body: BlocBuilder<EventBloc, EventState>(
          builder: (context, state) {
            if (state is EventLoadInProgress) return Center(child: CircularProgressIndicator());
            if (state is EventLoadSuccess) {
              final upcoming = <EventModel>[];
              final ongoing = <EventModel>[];
              final completed = <EventModel>[];
              for (var e in state.events) {
                if (e.status == 'upcoming') upcoming.add(e);
                else if (e.status == 'ongoing') ongoing.add(e);
                else completed.add(e);
              }
              return TabBarView(children: [
                _buildList(upcoming),
                _buildList(ongoing),
                _buildList(completed),
              ]);
            }
            if (state is EventLoadFailure) return Center(child: Text('Error: ${state.error}'));
            return Center(child: Text('No events'));
          },
        ),
        floatingActionButton: role == 'admin'
            ? FloatingActionButton(
                child: Icon(Icons.add),
                onPressed: () {
                  final userUid = (context.read<AuthBloc>().state is Authenticated) ? (context.read<AuthBloc>().state as Authenticated).uid : 'admin-demo';
                  Navigator.push(context, MaterialPageRoute(builder: (_) => CreateEventScreen(adminUid: userUid)));
                },
              )
            : null,
      ),
    );
  }

  Widget _buildList(List<EventModel> events) {
    if (events.isEmpty) return Center(child: Text('No events'));
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (_, i) => EventCard(event: events[i]),
    );
  }
}
