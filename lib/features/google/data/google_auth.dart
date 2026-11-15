import 'dart:async';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:googleapis/drive/v3.dart' as gdrive;
import 'package:googleapis_auth/googleapis_auth.dart' show AuthClient;

import '../../../core/providers.dart';

/// Google scopes requested in Phase 2. Gmail is added in Phase 3.
const googleScopes = [
  gcal.CalendarApi.calendarScope,
  gdrive.DriveApi.driveAppdataScope,
  gdrive.DriveApi.driveFileScope,
];

/// Requested only when you first send e-mail (Phase 3).
const gmailSendScope = 'https://www.googleapis.com/auth/gmail.send';

class GoogleNotReady implements Exception {
  GoogleNotReady(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Thin wrapper around google_sign_in 7: sign in once interactively, then get
/// authorised API clients silently.
class GoogleAuth {
  GoogleAuth(this.ref);
  final Ref ref;
  static bool _initialized = false;
  static String? _initializedWith;
  GoogleSignInAccount? _account;

  String get _webClientId => ref.read(settingsProvider).googleWebClientId.trim();

  Future<void> _init() async {
    final id = _webClientId;
    if (id.isEmpty) {
      throw GoogleNotReady('Add your Web client ID first (Me → Google account). See the README.');
    }
    if (_initialized) {
      if (_initializedWith != id) {
        throw GoogleNotReady('Client ID changed: close and reopen Solo Leveling to use the new one.');
      }
      return;
    }
    await GoogleSignIn.instance.initialize(serverClientId: id);
    _initialized = true;
    _initializedWith = id;
  }

  /// Interactive: account picker + consent for Calendar and Drive.
  Future<String> signIn() async {
    await _init();
    final acc = await GoogleSignIn.instance.authenticate(scopeHint: googleScopes);
    await acc.authorizationClient.authorizeScopes(googleScopes);
    _account = acc;
    await ref.read(settingsRepoProvider).set('googleEmail', acc.email);
    return acc.email;
  }

  Future<void> signOut() async {
    try {
      await _init();
      await GoogleSignIn.instance.disconnect();
    } catch (_) {}
    _account = null;
    await ref.read(settingsRepoProvider).set('googleEmail', '');
  }

  /// An authorised HTTP client without any UI, or null if you need to sign
  /// in again (or Google can't be reached from here, e.g. in the background).
  Future<AuthClient?> client({List<String> scopes = googleScopes}) async {
    if (ref.read(settingsProvider).googleEmail.isEmpty) return null;
    try {
      await _init();
      _account ??= await GoogleSignIn.instance.attemptLightweightAuthentication();
      final acc = _account;
      if (acc == null) return null;
      final auth = await acc.authorizationClient.authorizationForScopes(scopes);
      return auth?.authClient(scopes: scopes);
    } catch (_) {
      return null;
    }
  }

  /// Asks once (interactively) for permission to send e-mail via Gmail.
  Future<void> authorizeGmail() async {
    await _init();
    _account ??= await GoogleSignIn.instance.attemptLightweightAuthentication();
    _account ??= await GoogleSignIn.instance.authenticate(scopeHint: [...googleScopes, gmailSendScope]);
    await _account!.authorizationClient.authorizeScopes([gmailSendScope]);
    await ref.read(settingsRepoProvider).set('gmailGranted', true);
  }

  Future<AuthClient?> gmailClient() => client(scopes: const [gmailSendScope]);
}

final googleAuthProvider = Provider((ref) => GoogleAuth(ref));
