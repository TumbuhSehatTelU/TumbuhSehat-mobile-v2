part of 'profile_cubit.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {
  final String message;
  const ProfileLoading(this.message);
  @override
  List<Object> get props => [message];
}

class ProfileSuccess extends ProfileState {
  final String message;
  const ProfileSuccess(this.message);
  @override
  List<Object> get props => [message];
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
  @override
  List<Object> get props => [message];
}
