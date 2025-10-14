import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healthier/features/documents/scan_document_screen.dart';
import 'package:healthier/features/reference/widgets/glassmorphic_container.dart';

class OnboardingProfileScreen extends StatefulWidget {
  const OnboardingProfileScreen({super.key, required this.user});

  final fa.User user;

  @override
  State<OnboardingProfileScreen> createState() => _OnboardingProfileScreenState();
}

class _OnboardingProfileScreenState extends State<OnboardingProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _physicianController = TextEditingController();
  final _conditionsController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _insuranceController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyRelationController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();

  final List<String> _pronounOptions = const ['She / Her', 'He / Him'];
  int? _selectedPronounIndex;

  @override
  void initState() {
    super.initState();
    _fullNameController.text = widget.user.displayName ?? '';
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _dobController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _physicianController.dispose();
    _conditionsController.dispose();
    _medicationsController.dispose();
    _allergiesController.dispose();
    _insuranceController.dispose();
    _emergencyNameController.dispose();
    _emergencyRelationController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  Future<void> _showDatePicker() async {
    final now = DateTime.now();
    final initialDate = DateTime(now.year - 50);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 120),
      lastDate: now,
    );
    if (picked != null) {
      final formatted = MaterialLocalizations.of(context).formatMediumDate(picked);
      setState(() {
        _dobController.text = formatted;
      });
    }
  }

  void _handleContinue() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      return;
    }
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved.')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    InputDecoration _outlinedDecoration(String label, {String? hint, Widget? suffix}) {
      final fill = Colors.white.withOpacity(0.95);
      return InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: fill,
        suffixIcon: suffix,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      );
    }
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Complete your profile',
          style: GoogleFonts.lora(fontWeight: FontWeight.w600, fontSize: 22),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/green-brush-background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    '     A few details help tailor reminders and insights for you. You can scan a document if that is easier.',
                    style: GoogleFonts.inter(fontSize: 16, color: Colors.black87.withOpacity(0.7), height: 1.4),
                  ),
                  const SizedBox(height: 28),
                  GlassmorphicContainer(
                    blur: 22,
                    borderRadius: 28,
                    opacity: 0.9,
                    border: Border.all(color: Colors.white.withOpacity(0.25)),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Personal information',
                            style: GoogleFonts.lora(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black87),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _fullNameController,
                            decoration: _outlinedDecoration('Full name'),
                            textCapitalization: TextCapitalization.words,
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: _showDatePicker,
                            behavior: HitTestBehavior.translucent,
                            child: AbsorbPointer(
                              child: TextFormField(
                                controller: _dobController,
                                decoration: _outlinedDecoration(
                                  'Date of birth',
                                  suffix: const Icon(Icons.calendar_today_outlined),
                                ),
                                validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Pronouns',
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87.withOpacity(0.7)),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            children: [
                              for (var i = 0; i < _pronounOptions.length; i++)
                                ChoiceChip(
                                  label: Text(_pronounOptions[i]),
                                  selected: _selectedPronounIndex == i,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedPronounIndex = selected ? i : null;
                                    });
                                  },
                                ),
                              ChoiceChip(
                                label: const Text('Other'),
                                selected: _selectedPronounIndex == -1,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedPronounIndex = selected ? -1 : null;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _heightController,
                                  decoration: _outlinedDecoration('Height', hint: 'e.g., 165 cm'),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _weightController,
                                  decoration: _outlinedDecoration('Weight', hint: 'e.g., 65 kg'),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _physicianController,
                            decoration: _outlinedDecoration('Primary physician'),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _insuranceController,
                            decoration: _outlinedDecoration('Insurance details'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  GlassmorphicContainer(
                    blur: 18,
                    borderRadius: 24,
                    opacity: 0.7,
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: theme.colorScheme.primary.withOpacity(0.35)),
                            ),
                            child: Icon(Icons.document_scanner_outlined, color: theme.colorScheme.primary, size: 26),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Scan a document',
                                  style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Use prescriptions or discharge summaries to auto-fill details.',
                                  style: GoogleFonts.inter(fontSize: 14, color: Colors.black87.withOpacity(0.7)),
                                ),
                              ],
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const ScanDocumentScreen()),
                              );
                            },
                            icon: const Icon(Icons.camera_alt_outlined),
                            label: const Text('Scan'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  GlassmorphicContainer(
                    blur: 22,
                    borderRadius: 28,
                    opacity: 0.9,
                    border: Border.all(color: Colors.white.withOpacity(0.25)),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Health snapshot',
                            style: GoogleFonts.lora(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black87),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Conditions',
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87.withOpacity(0.7)),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _conditionsController,
                            maxLines: 3,
                            decoration: _outlinedDecoration('Conditions', hint: 'e.g., Hypertension, Arthritis'),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Medications',
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87.withOpacity(0.7)),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _medicationsController,
                            maxLines: 3,
                            decoration: _outlinedDecoration('Medications', hint: 'e.g., Metformin 500 mg AM'),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Allergies',
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87.withOpacity(0.7)),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _allergiesController,
                            maxLines: 3,
                            decoration: _outlinedDecoration('Allergies', hint: 'e.g., Penicillin, Tree nuts'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  GlassmorphicContainer(
                    blur: 22,
                    borderRadius: 28,
                    opacity: 0.9,
                    border: Border.all(color: Colors.white.withOpacity(0.25)),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Emergency contact',
                            style: GoogleFonts.lora(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black87),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _emergencyNameController,
                            decoration: _outlinedDecoration('Contact name'),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emergencyRelationController,
                            decoration: _outlinedDecoration('Relationship'),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emergencyPhoneController,
                            decoration: _outlinedDecoration('Phone number'),
                            keyboardType: TextInputType.phone,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleContinue,
                      child: const Text('Continue'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Skip for now'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
