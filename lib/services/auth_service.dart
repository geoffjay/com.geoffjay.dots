import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pocketbase/pocketbase.dart';

import '../config/environment.dart';

class AuthService {
  final PocketBase _pb = PocketBase(Environment.pocketbaseUrl);
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: Environment.googleServerClientId,
  );

  static const String _tokenKey = 'pb_token';

  bool get isAuthenticated => _pb.authStore.isValid;
  RecordModel? get currentUser =>
      _pb.authStore.record != null ? _pb.authStore.record as RecordModel : null;

  Future<void> restoreSession() async {
    final token = await _storage.read(key: _tokenKey);
    if (token != null && token.isNotEmpty) {
      _pb.authStore.save(token, null);
      try {
        await _pb.collection('users').authRefresh();
        await _saveSession();
      } catch (e) {
        await logout();
      }
    }
  }

  Future<RecordModel> loginWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Google sign-in was cancelled');
    }

    final serverAuthCode = googleUser.serverAuthCode;
    if (serverAuthCode == null) {
      throw Exception('Failed to get server auth code');
    }

    final authData = await _pb.collection('users').authWithOAuth2Code(
          'google',
          serverAuthCode,
          '',
          'urn:ietf:wg:oauth:2.0:oob',
        );

    await _saveSession();
    return authData.record;
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    _pb.authStore.clear();
    await _storage.delete(key: _tokenKey);
  }

  Future<void> _saveSession() async {
    await _storage.write(key: _tokenKey, value: _pb.authStore.token);
  }
}
