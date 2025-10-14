import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InsightCard extends StatelessWidget {
  const InsightCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFFEFEFEF),
                  child: Icon(Icons.person, color: Colors.grey[700], size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Social media post',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Scheduled for April 12',
                      style: GoogleFonts.inter(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.push_pin_outlined, color: Colors.black54),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Music is not just sounds, it\'s a way to express your soul 🎵',
              style: GoogleFonts.lora(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Today, we\'re creating unique melodies that reflect every moment of our lives. Music inspires us, opens new horizons, and brings emotions that words can\'t express.',
              style: GoogleFonts.inter(
                fontSize: 15,
                color: Colors.black.withOpacity(0.7),
                height: 1.5,
              ),
            ),
             const SizedBox(height: 16),
            Text(
              '💡 Creativity in music knows no boundaries, so ex...',
               style: GoogleFonts.inter(
                fontSize: 15,
                color: Colors.black.withOpacity(0.7),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1500534623283-312aade485b7?w=500',
                      fit: BoxFit.cover,
                      height: 100,
                      errorBuilder: (context, error, stack) => Image.asset(
                        'assets/images/green-brush-background.jpg',
                        fit: BoxFit.cover,
                        height: 100,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1519608487953-e999c8d477b6?w=500',
                      fit: BoxFit.cover,
                      height: 100,
                      errorBuilder: (context, error, stack) => Image.asset(
                        'assets/images/green-brush-background.jpg',
                        fit: BoxFit.cover,
                        height: 100,
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
