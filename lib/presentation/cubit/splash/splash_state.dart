part of 'splash_cubit.dart';

abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object> get props => [];
}

class SplashInitial extends SplashState {}

class SplashAuthenticated extends SplashState {
  final FamilyModel family;
  final String loggedInUserName;

  const SplashAuthenticated({
    required this.family,
    required this.loggedInUserName,
  });

  @override
  List<Object> get props => [family, loggedInUserName];
}

class SplashUnauthenticated extends SplashState {}
