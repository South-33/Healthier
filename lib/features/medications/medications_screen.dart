import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healthier/features/reference/widgets/glassmorphic_container.dart';

class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({super.key});

  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  final List<String> _dayOrder = const ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  late String _selectedDay;

  @override
  void initState() {
    super.initState();
    final todayIndex = DateTime.now().weekday - 1;
    _selectedDay = _dayOrder[todayIndex.clamp(0, _dayOrder.length - 1)];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedMeds = _mockWeekPlan[_selectedDay] ?? const <_MedicationEntry>[];

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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Medications',
                  style: GoogleFonts.lora(fontSize: 32, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 150,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 6, right: 4),
                    itemCount: _dayOrder.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final day = _dayOrder[index];
                      return _WeeklyDayCard(
                        day: day,
                        selected: day == _selectedDay,
                        entries: _mockWeekPlan[day] ?? const [],
                        onTap: () => setState(() => _selectedDay = day),
                        onManage: () => _handleManageDay(context, day),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 22),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: const Color(0xFFD1D5DB), width: 1.4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 22,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedDay,
                                      style: GoogleFonts.lora(fontSize: 26, fontWeight: FontWeight.w600, color: Colors.black87),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      selectedMeds.isEmpty
                                          ? 'No medications scheduled yet.'
                                          : '${selectedMeds.length} medication${selectedMeds.length == 1 ? '' : 's'} planned',
                                      style: GoogleFonts.inter(fontSize: 15, color: Colors.black87.withOpacity(0.7)),
                                    ),
                                  ],
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => _handleManageDay(context, _selectedDay),
                                icon: const Icon(Icons.add_outlined),
                                label: const Text('Add / remove'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Expanded(
                            child: selectedMeds.isEmpty
                                ? Center(
                                    child: Text(
                                      'Tap “Add / remove” to plan $_selectedDay.',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.inter(fontSize: 16, color: Colors.black87.withOpacity(0.6)),
                                    ),
                                  )
                                : ListView.separated(
                                    itemCount: selectedMeds.length,
                                    separatorBuilder: (_, __) => Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      child: Divider(
                                        height: 1,
                                        color: Colors.black.withOpacity(0.08),
                                      ),
                                    ),
                                    itemBuilder: (context, index) {
                                      final med = selectedMeds[index];
                                      return _DayMedicationTile(
                                        entry: med,
                                        theme: theme,
                                        onInsights: () => _showMedicationInsights(context, med),
                                        onRemove: () => _handleRemoveMedication(context, med),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleManageDay(BuildContext context, String day) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Day planner for $day coming soon.')),
    );
  }

  void _handleRemoveMedication(BuildContext context, _MedicationEntry entry) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Removal flow for ${entry.name} coming soon.')),
    );
  }

  void _showMedicationInsights(BuildContext context, _MedicationEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            top: 12,
          ),
          child: GlassmorphicContainer(
            borderRadius: 26,
            blur: 24,
            opacity: 0.95,
            border: Border.all(color: Colors.white.withOpacity(0.3)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.name,
                          style: GoogleFonts.lora(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black87),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    entry.summary,
                    style: GoogleFonts.inter(fontSize: 15, color: Colors.black87.withOpacity(0.75), height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Weekly medication planner',
                    style: GoogleFonts.lora(fontSize: 32, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tap a day to peek, add, or remove doses. Clear, calm, and senior-friendly.',
                    style: GoogleFonts.inter(fontSize: 15, color: Colors.black87.withOpacity(0.75), height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Common effects',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: entry.effects
                        .map(
                          (label) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF99B898).withOpacity(0.18),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: const Color(0xFF99B898).withOpacity(0.35)),
                            ),
                            child: Text(
                              label,
                              style: GoogleFonts.inter(fontSize: 13.5, color: Colors.black87.withOpacity(0.75)),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Text(
                      'Always follow your clinician\'s instructions. AI notes make it easier to remember key points.',
                      style: GoogleFonts.inter(fontSize: 14, color: Colors.black87.withOpacity(0.7)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WeeklyDayCard extends StatelessWidget {
  const _WeeklyDayCard({
    required this.day,
    required this.selected,
    required this.entries,
    required this.onTap,
    required this.onManage,
  });

  final String day;
  final bool selected;
  final List<_MedicationEntry> entries;
  final VoidCallback onTap;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    final isEmpty = entries.isEmpty;
    final preview = isEmpty ? 'No meds yet' : '${entries.first.time} • ${entries.first.name}';
    final iconData = entries.isEmpty
        ? Icons.inventory_outlined
        : (entries.length > 2 ? Icons.medication_liquid : Icons.medication_outlined);

    final outlineColor = selected ? const Color(0xFF99B898) : Colors.black12;
    final previewNames = entries.map((e) => e.name).toList(growable: false);
    final previewText = isEmpty
        ? 'Tap to add medications'
        : previewNames.take(3).join('\n');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 148,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: selected ? Colors.white : Colors.white.withOpacity(0.75),
          border: Border.all(color: outlineColor, width: selected ? 2 : 1),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: const Color(0xFF99B898).withOpacity(0.18),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              day.substring(0, 3).toUpperCase(),
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1),
            ),
            const SizedBox(height: 8),
            Text(
              previewText,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(fontSize: 13, color: Colors.black87.withOpacity(0.82), height: 1.35),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  isEmpty ? 'Tap to plan' : '${entries.length} item${entries.length == 1 ? '' : 's'}',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87.withOpacity(0.7)),
                ),
                const Spacer(),
                IconButton(
                  onPressed: onManage,
                  icon: const Icon(Icons.tune, size: 18),
                  tooltip: 'Manage day',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DayMedicationTile extends StatelessWidget {
  const _DayMedicationTile({
    required this.entry,
    required this.theme,
    required this.onInsights,
    required this.onRemove,
  });

  final _MedicationEntry entry;
  final ThemeData theme;
  final VoidCallback onInsights;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      borderRadius: 24,
      blur: 18,
      opacity: 0.82,
      border: Border.all(color: Colors.white.withOpacity(0.22)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.name,
                        style: GoogleFonts.lora(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${entry.dose} • ${entry.time}',
                        style: GoogleFonts.inter(fontSize: 14, color: Colors.black87.withOpacity(0.7)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: theme.colorScheme.primary.withOpacity(0.4)),
                  ),
                  child: Text(
                    entry.tag,
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              entry.notes,
              style: GoogleFonts.inter(fontSize: 14, color: Colors.black87.withOpacity(0.7), height: 1.4),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Remove'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onInsights,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('See insights'),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
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

class _MedicationEntry {
  const _MedicationEntry({
    required this.name,
    required this.dose,
    required this.time,
    required this.notes,
    required this.tag,
    required this.summary,
    required this.effects,
  });

  final String name;
  final String dose;
  final String time;
  final String notes;
  final String tag;
  final String summary;
  final List<String> effects;
}

final Map<String, List<_MedicationEntry>> _mockWeekPlan = {
  'Monday': [
    const _MedicationEntry(
      name: 'Metformin',
      dose: '500 mg tablet',
      time: '8:00 AM',
      notes: 'Take after a few bites of breakfast and sip water.',
      tag: 'Glucose',
      summary: 'Helps the body use insulin better and lowers sugar made by the liver.',
      effects: ['Upset stomach', 'Loose stool', 'Metallic taste'],
    ),
    const _MedicationEntry(
      name: 'Vitamin D3',
      dose: '1000 IU capsule',
      time: '9:30 AM',
      notes: 'Pair with a light snack for better absorption.',
      tag: 'Supplement',
      summary: 'Supports bone strength and immune balance when sun is limited.',
      effects: ['Headache (rare)', 'Mild fatigue'],
    ),
  ],
  'Tuesday': [
    const _MedicationEntry(
      name: 'Metformin',
      dose: '500 mg tablet',
      time: '8:00 AM',
      notes: 'Keep the same breakfast routine for steady blood sugar.',
      tag: 'Glucose',
      summary: 'Morning dose keeps overnight glucose from drifting high.',
      effects: ['Gas', 'Nausea'],
    ),
    const _MedicationEntry(
      name: 'Lisinopril',
      dose: '20 mg tablet',
      time: '6:00 PM',
      notes: 'Sit upright, drink a full glass of water, rise slowly later.',
      tag: 'Blood pressure',
      summary: 'Relaxes blood vessels to ease pressure and protect kidneys.',
      effects: ['Dry cough', 'Lightheadedness'],
    ),
  ],
  'Wednesday': [
    const _MedicationEntry(
      name: 'Metformin',
      dose: '500 mg tablet',
      time: '8:00 AM',
      notes: 'Take with breakfast and note any stomach changes.',
      tag: 'Glucose',
      summary: 'Keeps mid-week glucose steady alongside meals and walks.',
      effects: ['Upset stomach'],
    ),
    const _MedicationEntry(
      name: 'Vitamin D3',
      dose: '1000 IU capsule',
      time: '9:30 AM',
      notes: 'Use the pill organizer so Friday dose is not missed.',
      tag: 'Supplement',
      summary: 'Supports calcium use and mood balance.',
      effects: ['Headache (rare)'],
    ),
  ],
  'Thursday': [
    const _MedicationEntry(
      name: 'Metformin',
      dose: '500 mg tablet',
      time: '8:00 AM',
      notes: 'Stay hydrated; call provider if tummy upset lasts.',
      tag: 'Glucose',
      summary: 'Maintains glucose coverage heading toward the weekend.',
      effects: ['Nausea'],
    ),
    const _MedicationEntry(
      name: 'Lisinopril',
      dose: '20 mg tablet',
      time: '6:00 PM',
      notes: 'Check blood pressure before bed twice this week.',
      tag: 'Blood pressure',
      summary: 'Gives all-day relaxation of blood vessels to reduce pressure.',
      effects: ['Dizziness'],
    ),
  ],
  'Friday': [
    const _MedicationEntry(
      name: 'Metformin',
      dose: '500 mg tablet',
      time: '8:00 AM',
      notes: 'Keep breakfast ready the night before for easy routine.',
      tag: 'Glucose',
      summary: 'Same steady routine keeps the weekend calm.',
      effects: ['Mild nausea'],
    ),
    const _MedicationEntry(
      name: 'Vitamin D3',
      dose: '1000 IU capsule',
      time: '9:30 AM',
      notes: 'Take with breakfast smoothie.',
      tag: 'Supplement',
      summary: 'Supports bones; safe with other morning meds.',
      effects: ['Mild fatigue'],
    ),
  ],
  'Saturday': [
    const _MedicationEntry(
      name: 'Metformin',
      dose: '500 mg tablet',
      time: '9:00 AM',
      notes: 'Weekend brunch? Take just after the first bites.',
      tag: 'Glucose',
      summary: 'Keeps glucose stable even with later meals.',
      effects: ['Upset stomach'],
    ),
  ],
  'Sunday': [
    const _MedicationEntry(
      name: 'Metformin',
      dose: '500 mg tablet',
      time: '8:30 AM',
      notes: 'Lay out pill pack Saturday night to stay on track.',
      tag: 'Glucose',
      summary: 'Closes the week with steady blood sugar support.',
      effects: ['Loose stool'],
    ),
  ],
};
