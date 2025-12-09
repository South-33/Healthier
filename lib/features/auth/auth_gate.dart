import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as fui;
import 'package:flutter/material.dart';
import 'package:healthier/features/onboarding/profile_setup_screen.dart';
import 'package:healthier/data/guest_mode_manager.dart';
import 'custom_sign_in_screen.dart';

class AuthGate extends StatefulWidget {
  final Widget child;
  const AuthGate({super.key, required this.child});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final GuestModeManager _guestModeManager = GuestModeManager();

  @override
  void initState() {
    super.initState();
    _guestModeManager.addListener(_onGuestModeChanged);
  }

  @override
  void dispose() {
    _guestModeManager.removeListener(_onGuestModeChanged);
    super.dispose();
  }

  void _onGuestModeChanged() {
    setState(() {});
  }

  void _handleGuestContinue() {
    _guestModeManager.enableGuestMode();
  }

  @override
  Widget build(BuildContext context) {
    // If guest mode is enabled, show the app directly
    if (_guestModeManager.isGuestMode) {
      return widget.child;
    }

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
          // Custom sign-in screen with guest mode option
          return CustomSignInScreen(
            onGuestContinue: _handleGuestContinue,
          );
        }
        return widget.child;
      },
    );
  }
}
