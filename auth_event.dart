import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CheckAuthStatus extends AuthEvent {}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;
  SignInRequested({required this.email, required this.password});
  @override
  List<Object?> get props => [email];
}

class SignUpRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  SignUpRequested({required this.name, required this.email, required this.password});
  @override
  List<Object?> get props => [email];
}

class SignOutRequested extends AuthEvent {}
