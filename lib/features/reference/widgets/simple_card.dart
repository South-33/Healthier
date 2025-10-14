import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SimpleCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? avatarColor;

  const SimpleCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.avatarColor,
  });

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
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: avatarColor ?? Colors.grey.shade300,
              radius: 20,
              child: icon != null 
                ? Icon(icon, color: Colors.white, size: 20)
                : const Icon(Icons.person, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: GoogleFonts.inter(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.more_horiz, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}
