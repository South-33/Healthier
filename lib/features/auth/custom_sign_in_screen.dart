import 'package:firebase_ui_auth/firebase_ui_auth.dart' as fui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/guest_mode_manager.dart';
import '../onboarding/profile_setup_screen.dart';

class CustomSignInScreen extends StatelessWidget {
  final VoidCallback onGuestContinue;
  
  const CustomSignInScreen({
    super.key,
    required this.onGuestContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Firebase UI Sign In Screen
          fui.SignInScreen(
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
          ),
          
          // Guest Mode Button - Positioned at the bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Divider(),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: onGuestContinue,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF99B898),
                        side: const BorderSide(color: Color(0xFF99B898), width: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        minimumSize: const Size(double.infinity, 56),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.person_outline, size: 22),
                          const SizedBox(width: 12),
                          Text(
                            'Continue as Guest',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Explore the app without creating an account',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF8F928D),
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
