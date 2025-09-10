part of 'login_cubit.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final FamilyModel family;
  final String loggedInUserName;

  const LoginSuccess({required this.family, required this.loggedInUserName});

  @override
  List<Object> get props => [family, loggedInUserName];
}

class LoginFailure extends LoginState {
  final String message;
  const LoginFailure({required this.message});

  @override
  List<Object> get props => [message];
}
