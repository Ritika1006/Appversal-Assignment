import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repo;
  StreamSubscription? _authSub;

  AuthBloc(this._repo) : super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuth);
    on<SignInRequested>(_onSignIn);
    on<SignUpRequested>(_onSignUp);
    on<SignOutRequested>(_onSignOut);

    // start listening to auth changes
    add(CheckAuthStatus());
  }

  Future<void> _onCheckAuth(CheckAuthStatus event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await _authSub?.cancel();
    _authSub = _repo.authState.listen((user) async {
      if (user == null) {
        emit(Unauthenticated());
      } else {
        // fetch user profile
        final profile = await _repo.getUserProfile(user.uid);
        final role = profile?['role'] ?? 'user';
        final name = profile?['name'] ?? '';
        final email = profile?['email'] ?? user.email ?? '';
        emit(Authenticated(uid: user.uid, role: role, name: name, email: email));
      }
    });
  }

  Future<void> _onSignIn(SignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _repo.signIn(email: event.email, password: event.password);
      if (user == null) {
        emit(AuthFailure("Sign in failed"));
        return;
      }
      final profile = await _repo.getUserProfile(user.uid);
      emit(Authenticated(
        uid: user.uid,
        role: profile?['role'] ?? 'user',
        name: profile?['name'] ?? '',
        email: profile?['email'] ?? user.email ?? '',
      ));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onSignUp(SignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _repo.signUp(name: event.name, email: event.email, password: event.password);
      if (user == null) {
        emit(AuthFailure("Sign up failed"));
        return;
      }
      final profile = await _repo.getUserProfile(user.uid);
      emit(Authenticated(
        uid: user.uid,
        role: profile?['role'] ?? 'user',
        name: profile?['name'] ?? event.name,
        email: profile?['email'] ?? event.email,
      ));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onSignOut(SignOutRequested event, Emitter<AuthState> emit) async {
    await _repo.signOut();
    emit(Unauthenticated());
  }

  @override
  Future<void> close() {
    _authSub?.cancel();
    return super.close();
  }
}
