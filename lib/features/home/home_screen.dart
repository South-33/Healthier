import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healthier/features/documents/scan_document_screen.dart';
import 'package:healthier/features/emergency/emergency_countdown_screen.dart';
import 'package:healthier/features/reference/widgets/glassmorphic_container.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final localizations = MaterialLocalizations.of(context);
    final greeting = _greetingForHour(now.hour);
    final dateText = localizations.formatFullDate(now);

    final timeline = const [
      _TimelineEntry(
        time: '8:00 AM',
        title: 'Metformin',
        detail: '500 mg with breakfast',
        state: _TimelineState.current,
      ),
      _TimelineEntry(
        time: '12:00 PM',
        title: 'Blood Pressure',
        detail: 'Log systolic and diastolic',
        state: _TimelineState.upcoming,
      ),
      _TimelineEntry(
        time: '6:00 PM',
        title: 'Lisinopril',
        detail: '20 mg after meal',
        state: _TimelineState.upcoming,
      ),
    ];

    void showComingSoon(BuildContext ctx, String feature) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text('$feature coming soon')),
      );
    }

    final emergencyAction = _QuickAction(
      icon: Icons.sos_outlined,
      label: 'Emergency SOS',
      backgroundColor: const Color(0xFFFFE6E6),
      borderColor: const Color(0xFFFF8A8A),
      iconColor: const Color(0xFFB91C1C),
      textColor: const Color(0xFFB91C1C),
      opacity: 0.9,
      onSelected: (ctx) {
        Navigator.of(ctx).push(
          MaterialPageRoute(builder: (_) => const EmergencyCountdownScreen()),
        );
      },
    );

    final routineActions = [
      _QuickAction(
        icon: Icons.note_add_outlined,
        label: 'Log symptom',
        onSelected: (ctx) => showComingSoon(ctx, 'Symptom logging'),
      ),
      _QuickAction(
        icon: Icons.monitor_heart_outlined,
        label: 'Add vital',
        onSelected: (ctx) => showComingSoon(ctx, 'Vital capture'),
      ),
      _QuickAction(
        icon: Icons.vaccines_outlined,
        label: 'Record intake',
        onSelected: (ctx) => showComingSoon(ctx, 'Intake recording'),
      ),
    ];

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
                      _Header(
                        greeting: greeting,
                        dateText: dateText,
                        onScanPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ScanDocumentScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      _NowCard(theme: theme),
                      const SizedBox(height: 24),
                      _TimelineSection(entries: timeline),
                      const SizedBox(height: 24),
                      _QuickActions(emergency: emergencyAction, routine: routineActions),
                      SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
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

  static String _greetingForHour(int hour) {
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    if (hour < 21) return 'Good evening';
    return 'Good night';
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.greeting,
    required this.dateText,
    required this.onScanPressed,
  });

  final String greeting;
  final String dateText;
  final VoidCallback onScanPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting, Ada',
                style: GoogleFonts.lora(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  letterSpacing: -0.3,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                dateText,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87.withOpacity(0.65),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        GlassmorphicContainer(
          blur: 12,
          borderRadius: 18,
          opacity: 0.6,
          border: Border.all(color: Colors.white.withOpacity(0.25)),
          child: IconButton(
            onPressed: onScanPressed,
            icon: const Icon(Icons.document_scanner_outlined, color: Colors.black87),
            tooltip: 'Scan documents',
          ),
        ),
      ],
    );
  }
}

class _NowCard extends StatelessWidget {
  const _NowCard({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      blur: 24,
      borderRadius: 28,
      color: theme.colorScheme.primary,
      opacity: 0.18,
      border: Border.all(color: Colors.white.withOpacity(0.2)),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: [
              Color(0xFFE8F2EB),
              Color(0xFFF9FBF8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.35),
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Now',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: Colors.black87.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Metformin 500 mg',
              style: GoogleFonts.lora(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.schedule, size: 20, color: Colors.black87.withOpacity(0.65)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Take with breakfast • Due now',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.check_circle_outline, size: 22),
                label: Text(
                  'Confirm intake',
                  style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  side: BorderSide(color: Colors.black87.withOpacity(0.25)),
                  backgroundColor: Colors.white.withOpacity(0.5),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: Text(
                  'Snooze 15 min',
                  style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineSection extends StatelessWidget {
  const _TimelineSection({required this.entries});

  final List<_TimelineEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassmorphicContainer(
      blur: 18,
      borderRadius: 24,
      opacity: 0.75,
      border: Border.all(color: Colors.white.withOpacity(0.2)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today's plan",
              style: GoogleFonts.lora(fontSize: 26, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            const SizedBox(height: 24),
            for (var i = 0; i < entries.length; i++) ...[
              _TimelineRow(entry: entries[i]),
              if (i != entries.length - 1) const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.entry});

  final _TimelineEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outline = _stateColor(theme, entry.state);
    final background = Colors.white.withOpacity(0.65);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: outline, width: 2),
          ),
          alignment: Alignment.center,
          child: Text(
            _formatTime(entry.time),
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
              color: const Color(0xFF1F2933),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.title,
                style: GoogleFonts.lora(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                entry.detail,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87.withOpacity(0.65),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Color _stateColor(ThemeData theme, _TimelineState state) {
    switch (state) {
      case _TimelineState.completed:
        return const Color(0xFF22C55E);
      case _TimelineState.current:
        return const Color(0xFFF59E0B);
      case _TimelineState.missed:
        return const Color(0xFFEF4444);
      case _TimelineState.upcoming:
        return const Color(0xFF64748B);
    }
  }

  String _formatTime(String raw) {
    final upper = raw.toUpperCase().trim();
    final match = RegExp(r'^(\d{1,2})(?::(\d{2}))?\s*(AM|PM)?').firstMatch(upper);
    if (match == null) return raw;
    final hour = match.group(1) ?? raw;
    final period = match.group(3);
    return period == null ? hour : '$hour\n$period';
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.emergency, required this.routine});

  final _QuickAction emergency;
  final List<_QuickAction> routine;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _QuickActionChip(action: emergency, theme: theme, expand: true),
        const SizedBox(height: 12),
        Row(
          children: routine.map((item) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: _QuickActionChip(action: item, theme: theme),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({required this.action, required this.theme, this.expand = false});

  final _QuickAction action;
  final ThemeData theme;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      blur: 18,
      borderRadius: 20,
      color: action.backgroundColor ?? Colors.white,
      opacity: action.opacity ?? 0.4,
      border: Border.all(
        color: (action.borderColor ?? theme.colorScheme.primary).withOpacity(0.25),
        width: 1.2,
      ),
      child: InkWell(
        onTap: () => action.onSelected(context),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: expand ? 24 : 18,
            vertical: expand ? 18 : 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(action.icon, size: 24, color: action.iconColor ?? theme.colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                action.label,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: action.textColor ?? Colors.black87,
                  height: 1.3,
                ),
                maxLines: 2,
                softWrap: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InsightsSection extends StatelessWidget {
  const _InsightsSection({required this.items});

  final List<_InsightCardData> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Insights for you',
              style: GoogleFonts.lora(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            TextButton(onPressed: () {}, child: const Text('View all')),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(right: 16),
            itemBuilder: (context, index) {
              final item = items[index];
              return GlassmorphicContainer(
                blur: 18,
                borderRadius: 24,
                opacity: 0.65,
                border: Border.all(color: Colors.white.withOpacity(0.2)),
                child: Container(
                  width: 260,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(item.tag, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary)),
                      ),
                      const Spacer(),
                      Text(item.title, style: GoogleFonts.lora(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87)),
                      const SizedBox(height: 8),
                      Text(item.body, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black87.withOpacity(0.7))),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemCount: items.length,
          ),
        ),
      ],
    );
  }
}

class _JournalPreview extends StatelessWidget {
  const _JournalPreview();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassmorphicContainer(
      blur: 18,
      borderRadius: 24,
      opacity: 0.7,
      border: Border.all(color: Colors.white.withOpacity(0.2)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Latest journal entry', style: GoogleFonts.lora(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87)),
                  const SizedBox(height: 8),
                  Text(
                    '"Feeling more energetic after morning walk. Mild knee soreness rated 3/10."',
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black87.withOpacity(0.75)),
                  ),
                  const SizedBox(height: 12),
                  Text('Yesterday • Energy & Mobility', style: theme.textTheme.labelMedium?.copyWith(color: Colors.black87.withOpacity(0.6))),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16)),
              child: const Text('Add note'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CareCircleCard extends StatelessWidget {
  const _CareCircleCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassmorphicContainer(
      blur: 18,
      borderRadius: 24,
      opacity: 0.65,
      border: Border.all(color: Colors.white.withOpacity(0.2)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
          child: Icon(Icons.family_restroom_outlined, color: theme.colorScheme.primary),
        ),
        title: Text('Care circle updates', style: GoogleFonts.lora(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87)),
        subtitle: Text('Emma added a refill reminder for Saturday.', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black87.withOpacity(0.7))),
        trailing: Switch(value: true, onChanged: (_) {}),
      ),
    );
  }
}

class _EmergencyCard extends StatelessWidget {
  const _EmergencyCard();

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      blur: 18,
      borderRadius: 24,
      opacity: 0.7,
      border: Border.all(color: Colors.white.withOpacity(0.2)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444).withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.emergency_share_outlined, color: Color(0xFFEF4444)),
        ),
        title: Text('Emergency card', style: GoogleFonts.lora(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87)),
        subtitle: Text('Conditions, allergies, and emergency contacts at a glance.'),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
        onTap: () {},
      ),
    );
  }
}

class _TimelineEntry {
  const _TimelineEntry({
    required this.time,
    required this.title,
    required this.detail,
    required this.state,
  });

  final String time;
  final String title;
  final String detail;
  final _TimelineState state;
}

enum _TimelineState { completed, current, upcoming, missed }

class _QuickAction {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onSelected,
    this.backgroundColor,
    this.borderColor,
    this.iconColor,
    this.textColor,
    this.opacity,
  });

  final IconData icon;
  final String label;
  final void Function(BuildContext context) onSelected;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? iconColor;
  final Color? textColor;
  final double? opacity;
}

class _InsightCardData {
  const _InsightCardData({required this.title, required this.body, required this.tag});

  final String title;
  final String body;
  final String tag;
}
