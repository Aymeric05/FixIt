import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthCheckRequested extends AuthEvent {}
class RefreshProfileRequested extends AuthEvent {}
class AuthSignInAnonymous extends AuthEvent {}
class AuthSignOutRequested extends AuthEvent {}
