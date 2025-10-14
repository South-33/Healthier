import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/glassmorphic_container.dart';
import 'widgets/insight_card.dart';
import 'widgets/simple_card.dart';

class ReferenceScreen extends StatelessWidget {
  const ReferenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/green-brush-background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
                onPressed: () {},
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.swap_vert, color: Colors.black87),
                  onPressed: () {},
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      'Saved Insights',
                      style: GoogleFonts.lora(
                        fontSize: 36,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Row(
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    // Simple cards at the top
                    const SimpleCard(
                      title: 'Planned collaboration',
                      avatarColor: Color(0xFF8B5A3C),
                      icon: Icons.group,
                    ),
                    const SizedBox(height: 12),
                    const SimpleCard(
                      title: 'Engaging text',
                      avatarColor: Color(0xFF6B7280),
                      icon: Icons.text_fields,
                    ),
                    const SizedBox(height: 20),
                    // Main insight card
                    const InsightCard(),
                    const SizedBox(height: 100), // Space for floating button
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: Text('Create new', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        icon: const Icon(Icons.arrow_forward),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _FilterChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FilterChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4E6F7).withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.black87, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
