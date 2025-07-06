import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.isLoading = false, this.error});
}

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _firebaseAuth;

  AuthCubit(this._firebaseAuth) : super(AuthState(isLoading: true)) {
    _firebaseAuth.authStateChanges().listen((user) {
      emit(AuthState(user: user, isLoading: false));
    }, onError: (error) {
      emit(AuthState(isLoading: false, error: error.toString()));
    });
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  
}
