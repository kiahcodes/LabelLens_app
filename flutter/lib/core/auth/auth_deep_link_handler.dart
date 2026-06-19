import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_callback_state.dart';

Uri? _pendingSignupConfirmUri;

/// Call before [Supabase.initialize] so signup confirmation URIs are captured
/// before the session is established.
Future<void> prepareAuthDeepLinkState() async {
  final initialUri = await AppLinks().getInitialLink();
  if (isSignupConfirmationUri(initialUri)) {
    _pendingSignupConfirmUri = initialUri;
  }
}

Future<void> _handleSignupConfirmation(
  GlobalKey<NavigatorState> navigatorKey,
) async {
  authCallbackHandled = true;
  _pendingSignupConfirmUri = null;

  await Supabase.instance.client.auth.signOut();

  navigatorKey.currentState?.pushNamedAndRemoveUntil(
    '/login',
    (_) => false,
    arguments: {'emailVerified': true},
  );
}

Future<void> setupAuthDeepLinks(GlobalKey<NavigatorState> navigatorKey) async {
  final appLinks = AppLinks();

  final initialUri = await appLinks.getInitialLink();
  if (isSignupConfirmationUri(initialUri)) {
    _pendingSignupConfirmUri = initialUri;
  }

  appLinks.uriLinkStream.listen((uri) {
    if (isSignupConfirmationUri(uri)) {
      _pendingSignupConfirmUri = uri;
    }
  });

  Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
    if (data.event == AuthChangeEvent.passwordRecovery) {
      authCallbackHandled = true;
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/reset-password',
        (_) => false,
      );
      return;
    }

    if (data.event == AuthChangeEvent.signedIn &&
        _pendingSignupConfirmUri != null &&
        isSignupConfirmationUri(_pendingSignupConfirmUri)) {
      await _handleSignupConfirmation(navigatorKey);
    }
  });

  // Supabase may have already processed the deep link during initialize.
  if (_pendingSignupConfirmUri != null &&
      isSignupConfirmationUri(_pendingSignupConfirmUri) &&
      Supabase.instance.client.auth.currentSession != null) {
    await _handleSignupConfirmation(navigatorKey);
  }
}
