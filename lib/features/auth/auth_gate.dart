import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as fui;
import 'package:flutter/material.dart';
import 'package:healthier/features/onboarding/profile_setup_screen.dart';

class AuthGate extends StatelessWidget {
  final Widget child;
  const AuthGate({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<fa.User?>(
      stream: fa.FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (user == null) {
          // Prebuilt FirebaseUI screen for Email/Password
          return fui.SignInScreen(
            providers: [fui.EmailAuthProvider()],
            actions: [
              fui.AuthStateChangeAction<fui.SignedIn>((context, state) {
                // Once signed in, AuthGate will rebuild showing the app.
              }),
              fui.AuthStateChangeAction<fui.UserCreated>((context, state) {
                final newUser = state.credential.user;
                if (newUser != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => OnboardingProfileScreen(user: newUser),
                    ),
                  );
                }
              }),
            ],
          );
        }
        return child;
      },
    );
  }
}
