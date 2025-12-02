import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final String uid;
  final String role;
  final String name;
  final String email;

  Authenticated({
    required this.uid,
    required this.role,
    required this.name,
    required this.email,
  });

  @override
  List<Object?> get props => [uid, role, name, email];
}

class Unauthenticated extends AuthState {}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
  @override
  List<Object?> get props => [message];
}
