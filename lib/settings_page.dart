import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/app_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _ctrl1 = TextEditingController();
  final _ctrl2 = TextEditingController();
  final _ctrl3 = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final nums = context.read<AppProvider>().sosNumbers;
      _ctrl1.text = nums[0];
      _ctrl2.text = nums[1];
      _ctrl3.text = nums[2];
    });
  }

  @override
  void dispose() {
    _ctrl1.dispose();
    _ctrl2.dispose();
    _ctrl3.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final n1 = _ctrl1.text.trim();
    final n2 = _ctrl2.text.trim();
    final n3 = _ctrl3.text.trim();

    // At least one number must be provided
    if (n1.isEmpty && n2.isEmpty && n3.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('অন্তত একটি জরুরি নম্বর দিন।'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _saving = true);
    await context.read<AppProvider>().setSosNumbers([n1, n2, n3]);
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('জরুরি নম্বর সংরক্ষিত হয়েছে ✓'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text('সেটিংস'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
        children: [
          // ── SOS Numbers Section ──────────────────────────────────────────
          _SectionCard(
            icon: Icons.sos_rounded,
            iconColor: const Color(0xFFAD1457),
            title: 'জরুরি SOS নম্বর',
            subtitle:
                'SOS বোতাম চাপলে নিচের নম্বরে কল ও বার্তা যাবে।\n'
                'প্রথম নম্বরে কল করা হবে; সব নম্বরে SMS যাবে।',
            child: Column(
              children: [
                const SizedBox(height: 16),
                _NumberField(
                  controller: _ctrl1,
                  label: 'নম্বর ১ (প্রধান — কল করা হবে)',
                  index: 1,
                ),
                const SizedBox(height: 12),
                _NumberField(controller: _ctrl2, label: 'নম্বর ২', index: 2),
                const SizedBox(height: 12),
                _NumberField(controller: _ctrl3, label: 'নম্বর ৩', index: 3),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFAD1457),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.save_rounded),
                    label: const Text(
                      'সংরক্ষণ করুন',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Info card ────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFB300)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFFE65100),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'নম্বর না দিলে SOS বোতাম কাজ করবে না। '
                    'বিশ্বস্ত পরিবারের সদস্য বা বন্ধুর নম্বর দিন।',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.brown[800],
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: iconColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12.5,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int index;

  const _NumberField({
    required this.controller,
    required this.label,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    const rose = Color(0xFFAD1457);
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        hintText: label,
        hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(10),
          child: CircleAvatar(
            radius: 11,
            backgroundColor: rose.withValues(alpha: 0.12),
            child: Text(
              '$index',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: rose,
              ),
            ),
          ),
        ),
        filled: true,
        fillColor: const Color(0xFFFCE4EC).withValues(alpha: 0.35),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF8BBD9)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF8BBD9)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: rose, width: 1.5),
        ),
      ),
    );
  }
}
