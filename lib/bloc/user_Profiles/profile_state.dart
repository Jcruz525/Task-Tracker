import 'package:equatable/equatable.dart';
import '../../models/user_preferences.dart';

abstract class ProfileState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserPreferences preferences;

  ProfileLoaded(this.preferences);

  @override
  List<Object?> get props => [preferences];
}

class ProfileError extends ProfileState {
  final String message;

  ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
