import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthBloc>().state;
    String name = '';
    String email = '';
    String role = '';
    if (state is Authenticated) {
      name = state.name;
      email = state.email;
      role = state.role;
    }

    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Padding(
        padding: EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: $name', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Email: $email', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Role: $role', style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.read<AuthBloc>().add(SignOutRequested());
              },
              child: Text('Sign Out'),
            )
          ],
        ),
      ),
    );
  }
}
