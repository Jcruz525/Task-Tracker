import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {}

class UpdateAvatar extends ProfileEvent {
  final String avatarUrl;

  UpdateAvatar(this.avatarUrl);

  @override
  List<Object?> get props => [avatarUrl];
}

class UpdateThemeColor extends ProfileEvent {
  final String themeColor;

  UpdateThemeColor(this.themeColor);

  @override
  List<Object?> get props => [themeColor];
}

class SignOutRequested extends ProfileEvent {}
