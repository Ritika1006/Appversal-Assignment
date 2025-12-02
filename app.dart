import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/events/event_bloc.dart';
import 'repositories/auth_repository.dart';
import 'repositories/event_repository.dart';
import 'ui/screens/splash_screen.dart';

class EventSyncProApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(AuthRepository())..add(CheckAuthStatus())),
        BlocProvider(create: (_) => EventBloc(EventRepository())..add(LoadEvents())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'EventSyncPro',
        theme: ThemeData(primarySwatch: Colors.deepPurple),
        home: SplashScreen(),
      ),
    );
  }
}
