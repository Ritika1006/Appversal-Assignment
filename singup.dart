import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import 'home_screen.dart';

class SignUpScreen extends StatefulWidget {
  @override State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  void _signUp() {
    final name = _name.text.trim();
    final email = _email.text.trim();
    final password = _password.text.trim();
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all fields')));
      return;
    }
    context.read<AuthBloc>().add(SignUpRequested(name: name, email: email, password: password));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) setState(() => _loading = true); else setState(() => _loading = false);
          if (state is Authenticated) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
          if (state is AuthFailure) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        },
        child: Padding(
          padding: EdgeInsets.all(14),
          child: Column(children: [
            TextField(controller: _name, decoration: InputDecoration(labelText: 'Full name')),
            SizedBox(height: 8),
            TextField(controller: _email, decoration: InputDecoration(labelText: 'Email')),
            SizedBox(height: 8),
            TextField(controller: _password, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
            SizedBox(height: 16),
            ElevatedButton(onPressed: _loading ? null : _signUp, child: _loading ? CircularProgressIndicator(color: Colors.white) : Text('Create Account')),
          ]),
        ),
      ),
    );
  }
}
