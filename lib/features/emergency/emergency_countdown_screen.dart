import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmergencyCountdownScreen extends StatefulWidget {
  const EmergencyCountdownScreen({super.key});

  @override
  State<EmergencyCountdownScreen> createState() => _EmergencyCountdownScreenState();
}

class _EmergencyCountdownScreenState extends State<EmergencyCountdownScreen> {
  static const int _startSeconds = 5;
  late int _secondsRemaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = _startSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 1) {
        _completeSOS();
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _completeSOS() {
    _timer?.cancel();
    if (!mounted) return;
    setState(() => _secondsRemaining = 0);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contacting caregivers and emergency services...'),
        duration: Duration(seconds: 3),
      ),
    );
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  void _cancelSOS() {
    _timer?.cancel();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Emergency alert canceled. Stay safe.')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F0A0A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: _cancelSOS,
                ),
              ),
              const SizedBox(height: 48),
              Text(
                'Emergency SOS',
                style: GoogleFonts.lora(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'We will alert your care circle and call emergency services unless you cancel within the countdown.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.white.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFFF5F5).withOpacity(0.15),
                      const Color(0xFFFF3B30).withOpacity(0.38),
                    ],
                  ),
                  border: Border.all(color: const Color(0xFFFF3B30).withOpacity(0.5), width: 3),
                ),
                child: Center(
                  child: Text(
                    _secondsRemaining.toString().padLeft(2, '0'),
                    style: GoogleFonts.lora(
                      fontSize: 86,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _completeSOS,
                icon: const Icon(Icons.sos_outlined),
                label: const Text('Send now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF3B30),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
                  textStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _cancelSOS,
                child: const Text('Cancel alert'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.family_restroom_outlined, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Emergency contacts: Emma Rivers • Dr. Hall\nLocal emergency services: 911',
                        style: GoogleFonts.inter(color: Colors.white.withOpacity(0.85), height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
