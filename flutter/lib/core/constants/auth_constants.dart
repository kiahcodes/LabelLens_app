/// Deep link Supabase uses to return to the app after OAuth, password reset,
/// or signup email confirmation.
///
/// Must also be added in Supabase Dashboard → Authentication → URL Configuration
/// → Redirect URLs: `io.supabase.safescan://login-callback/`
const kAuthRedirectUrl = 'io.supabase.safescan://login-callback/';
