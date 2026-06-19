/// Set when a deep-link auth callback has been handled in [main.dart].
bool authCallbackHandled = false;

/// Returns true when the URI is a Supabase signup email confirmation callback.
bool isSignupConfirmationUri(Uri? uri) {
  if (uri == null) return false;
  return '${uri.query}${uri.fragment}'.contains('type=signup');
}
