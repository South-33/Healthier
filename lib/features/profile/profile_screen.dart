import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healthier/features/reference/widgets/glassmorphic_container.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/green-brush-background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profile',
                        style: GoogleFonts.lora(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 28),
                      _HeroCard(theme: theme),
                      const SizedBox(height: 32),
                      _PersonalInfoCard(theme: theme),
                      const SizedBox(height: 28),
                      _WellnessTags(theme: theme),
                      const SizedBox(height: 28),
                      _CareCircleCard(theme: theme),
                      const SizedBox(height: 28),
                      _PreferencesCard(theme: theme),
                      const SizedBox(height: 28),
                      _DocumentsCard(theme: theme),
                      SizedBox(height: MediaQuery.of(context).padding.bottom + 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

Color _darken(Color color, double amount) {
  assert(amount >= 0 && amount <= 1);
  final hsl = HSLColor.fromColor(color);
  final darker = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
  return darker.toColor();
}
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      blur: 24,
      borderRadius: 32,
      color: theme.colorScheme.primary,
      opacity: 0.16,
      border: Border.all(color: theme.colorScheme.primary.withOpacity(0.25), width: 1.2),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            colors: [
              Color(0xFFE8F2EB),
              Color(0xFFF9FBF8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.32),
            width: 1.4,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 32,
                  backgroundColor: Color(0xFFCBD5D5),
                  child: Icon(Icons.person_outline, size: 38, color: Color(0xFF1F2933)),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ada Rivers',
                        style: GoogleFonts.lora(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Age 67 • Type 2 Diabetes',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.black87.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                _TagChip(label: 'Metformin 500mg daily'),
                _TagChip(label: 'Hypertension'),
                _TagChip(label: 'Nut allergy'),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    label: const Text('Edit details'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.ios_share_outlined, size: 20),
                    label: const Text('Share emergency card'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      foregroundColor: Colors.black87,
                      side: BorderSide(color: Colors.black87.withOpacity(0.25)),
                      backgroundColor: Colors.white.withOpacity(0.55),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PersonalInfoCard extends StatelessWidget {
  const _PersonalInfoCard({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      blur: 18,
      borderRadius: 24,
      opacity: 0.75,
      border: Border.all(color: const Color(0xFFE5EEE8), width: 1),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal details',
              style: GoogleFonts.lora(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            const _InfoRow(label: 'Date of birth', value: 'May 4, 1958'),
            const SizedBox(height: 16),
            const _InfoRow(label: 'Pronouns', value: 'She / Her'),
            const SizedBox(height: 16),
            const _InfoRow(label: 'Primary physician', value: 'Dr. Douglass Hall'),
            const SizedBox(height: 16),
            const _InfoRow(label: 'Insurance', value: 'Sunrise Health Basic Plan • Member #4821'),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.manage_accounts_outlined),
                label: const Text('Manage profile info'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WellnessTags extends StatelessWidget {
  const _WellnessTags({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      blur: 18,
      borderRadius: 24,
      opacity: 0.7,
      border: Border.all(color: Colors.white.withOpacity(0.22)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            final isWide = maxWidth >= 600;
            final groupWidth = isWide ? (maxWidth - 16) / 2 : maxWidth;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Health overview',
                  style: GoogleFonts.lora(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: groupWidth,
                      child: _WellnessGroup(
                        icon: Icons.favorite_outline,
                        title: 'Conditions',
                        items: ['Type 2 diabetes', 'Hypertension'],
                        accentColor: const Color(0xFFFBA2AF),
                      ),
                    ),
                    SizedBox(
                      width: groupWidth,
                      child: _WellnessGroup(
                        icon: Icons.warning_amber_outlined,
                        title: 'Allergies',
                        items: ['Peanuts', 'Penicillin'],
                        accentColor: const Color(0xFFF9C98F),
                      ),
                    ),
                    SizedBox(
                      width: groupWidth,
                      child: _WellnessGroup(
                        icon: Icons.medical_services_outlined,
                        title: 'Active medications',
                        items: ['Metformin', 'Lisinopril', 'Vitamin D3'],
                        accentColor: const Color(0xFF8EDFB6),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _WellnessGroup extends StatelessWidget {
  const _WellnessGroup({
    required this.icon,
    required this.title,
    required this.items,
    required this.accentColor,
  });

  final IconData icon;
  final String title;
  final List<String> items;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withOpacity(0.22), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: _darken(accentColor, 0.12)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items
                .map((label) => _TagChip(
                      label: label,
                      textColor: _darken(accentColor, 0.16),
                      borderColor: accentColor.withOpacity(0.26),
                    ))
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

Color _darken(Color color, double amount) {
  assert(amount >= 0 && amount <= 1);
  final hsl = HSLColor.fromColor(color);
  final darker = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
  return darker.toColor();
}

class _CareCircleCard extends StatelessWidget {
  const _CareCircleCard({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      blur: 18,
      borderRadius: 24,
      opacity: 0.7,
      border: Border.all(color: Colors.white.withOpacity(0.22)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Care circle',
              style: GoogleFonts.lora(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            const SizedBox(height: 18),
            _CareContactTile(
              name: 'Emma Rivers',
              relationship: 'Daughter • Full access',
              theme: theme,
              leading: Icons.favorite_outline,
            ),
            const SizedBox(height: 14),
            _CareContactTile(
              name: 'Dr. Douglass Hall',
              relationship: 'Primary physician • View appointments',
              theme: theme,
              leading: Icons.local_hospital_outlined,
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.person_add_alt_1_outlined),
              label: const Text('Invite caregiver'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black87,
                side: BorderSide(color: Colors.black87.withOpacity(0.25)),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreferencesCard extends StatelessWidget {
  const _PreferencesCard({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      blur: 18,
      borderRadius: 24,
      opacity: 0.7,
      border: Border.all(color: Colors.white.withOpacity(0.22)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preferences',
              style: GoogleFonts.lora(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            const _PreferenceRow(
              icon: Icons.notifications_outlined,
              title: 'Reminders',
              subtitle: 'Morning 8:00 • Evening 6:30',
            ),
            const SizedBox(height: 16),
            const _PreferenceRow(
              icon: Icons.visibility_outlined,
              title: 'Accessibility',
              subtitle: 'Large text • Voice prompts on',
            ),
            const SizedBox(height: 16),
            const _PreferenceRow(
              icon: Icons.lock_outline,
              title: 'Privacy mode',
              subtitle: 'Cloud AI + local data • Passcode enabled',
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentsCard extends StatelessWidget {
  const _DocumentsCard({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      blur: 18,
      borderRadius: 24,
      opacity: 0.7,
      border: Border.all(color: Colors.white.withOpacity(0.22)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Documents & IDs',
              style: GoogleFonts.lora(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            const SizedBox(height: 18),
            const _DocumentRow(title: 'Insurance card', status: 'Verified • Updated May 2025'),
            const SizedBox(height: 14),
            const _DocumentRow(title: 'Latest labs', status: 'Glucose panel • March 12'),
            const SizedBox(height: 14),
            const _DocumentRow(title: 'Advance directive', status: 'Signature requested'),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.drive_folder_upload_outlined),
                label: const Text('Upload document'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label, this.textColor, this.borderColor});

  final String label;
  final Color? textColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor ?? Colors.black12.withOpacity(0.08)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textColor ?? const Color(0xFF1F2933),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87.withOpacity(0.7),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _CareContactTile extends StatelessWidget {
  const _CareContactTile({
    required this.name,
    required this.relationship,
    required this.theme,
    required this.leading,
  });

  final String name;
  final String relationship;
  final ThemeData theme;
  final IconData leading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(leading, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  relationship,
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.black87.withOpacity(0.7)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black87,
              side: BorderSide(color: Colors.black87.withOpacity(0.2)),
            ),
            child: const Text('Manage'),
          ),
        ],
      ),
    );
  }
}

class _PreferenceRow extends StatelessWidget {
  const _PreferenceRow({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.black87.withOpacity(0.7)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: () {},
            child: const Text('Adjust'),
          ),
        ],
      ),
    );
  }
}

class _DocumentRow extends StatelessWidget {
  const _DocumentRow({required this.title, required this.status});

  final String title;
  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.black87.withOpacity(0.7)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
            color: Colors.black87,
          ),
        ],
      ),
    );
  }
}
