import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ScanDocumentScreen extends StatelessWidget {
  const ScanDocumentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan documents'),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF7F9F4), Color(0xFFE9F1EA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Capture medical documents',
                style: GoogleFonts.lora(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Point the camera at prescriptions, discharge notes, or lab results. We will enhance the image and extract important details for your records.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.black87.withOpacity(0.75),
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Center(
                  child: Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: theme.colorScheme.primary.withOpacity(0.35), width: 2),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.document_scanner_outlined, size: 72, color: theme.colorScheme.primary),
                        const SizedBox(height: 16),
                        Text(
                          'Tap to start scanning',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Supports single or multi-page PDFs.',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.black87.withOpacity(0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Scanning flow coming soon...')),
                    );
                  },
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Start scan'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
