import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import 'signin_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // listen to auth state and navigate accordingly
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
        } else if (state is Unauthenticated) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SignInScreen()));
        }
      },
      child: Scaffold(
        body: Center(
          child: Text('EventSyncPro', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
