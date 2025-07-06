import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/user_preferences.dart';
import '../../repositories/user_repositories.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository repository;

  ProfileBloc(this.repository) : super(ProfileInitial()) {
    on<LoadProfile>((event, emit) async {
      emit(ProfileLoading());
      try {
        final prefs = await repository.getPreferences();
        emit(ProfileLoaded(prefs));
      } catch (e) {
        emit(ProfileError('Failed to load user preferences.'));
      }
    });

    on<UpdateAvatar>((event, emit) async {
      if (state is ProfileLoaded) {
        final currentPrefs = (state as ProfileLoaded).preferences;
        final updatedPrefs = UserPreferences(
          avatarUrl: event.avatarUrl,
          themeColor: currentPrefs.themeColor,
        );
        await repository.updatePreferences(updatedPrefs);
        emit(ProfileLoaded(updatedPrefs));
      }
    });

    on<UpdateThemeColor>((event, emit) async {
      if (state is ProfileLoaded) {
        final currentPrefs = (state as ProfileLoaded).preferences;
        final updatedPrefs = UserPreferences(
          avatarUrl: currentPrefs.avatarUrl,
          themeColor: event.themeColor,
        );
        await repository.updatePreferences(updatedPrefs);
        emit(ProfileLoaded(updatedPrefs));
      }
    });

    on<SignOutRequested>((event, emit) async {
      await repository.signOut();
      emit(ProfileInitial());
    });
  }
}
