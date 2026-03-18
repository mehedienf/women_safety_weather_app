import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/app_provider.dart';
import 'services/safety_service.dart';
import 'settings_page.dart';
import 'theme.dart';
import 'widgets/disaster_app_bar.dart';

class WomenSafetyPage extends StatefulWidget {
  final VoidCallback? onMenuTap;
  const WomenSafetyPage({super.key, this.onMenuTap});

  @override
  State<WomenSafetyPage> createState() => _WomenSafetyPageState();
}

class _WomenSafetyPageState extends State<WomenSafetyPage> {
  final _service = SafetyService();
  final _nameCtrl = TextEditingController();
  final _locCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _alertSent = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _prefillLocation());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locCtrl.dispose();
    super.dispose();
  }

  void _prefillLocation() {
    if (!mounted) return;
    final app = context.read<AppProvider>();
    _locCtrl.text =
        '${app.latitude.toStringAsFixed(5)}\u00b0N, ${app.longitude.toStringAsFixed(5)}\u00b0E';
  }

  Future<void> _sendEmergency() async {
    if (!_formKey.currentState!.validate()) return;

    final sosNums = context.read<AppProvider>().activeSosNumbers;
    if (sosNums.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('কোনো জরুরি নম্বর সেট করা নেই। সেটিংসে যান।'),
          backgroundColor: Colors.redAccent,
          action: SnackBarAction(
            label: 'সেটিংস',
            textColor: Colors.white,
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsPage()));
            },
          ),
        ),
      );
      return;
    }

    setState(() => _busy = true);
    final name = _nameCtrl.text.trim();
    final loc = _locCtrl.text.trim();
    final message = 'EMERGENCY: $name needs help. Location: $loc';

    // SMS all configured numbers
    for (final number in sosNums) {
      await _service.sendSms(to: number, message: message);
    }
    // Call the primary (first) number
    await _service.directCall(sosNums.first);

    if (mounted) {
      setState(() {
        _busy = false;
        _alertSent = true;
      });
    }
  }

  Future<void> _sendSafe() async {
    setState(() => _busy = true);
    final name = _nameCtrl.text.trim();
    final sosNums = context.read<AppProvider>().activeSosNumbers;
    final message = 'SAFE: $name is now safe.';
    for (final number in sosNums) {
      await _service.sendSms(to: number, message: message);
    }
    if (mounted) {
      setState(() {
        _busy = false;
        _alertSent = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: DisasterAppBar(
        title: 'নারী ও শিশু সুরক্ষা',
        showMenuButton: true,
        showTickerTape: true,
        onMenuTap: widget.onMenuTap,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          16,
          20,
          16,
          120,
        ), // Bottom padding for navigation bar
        children: [
          // â”€â”€ Emergency Alert Form â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          _SectionHeader(
            title: 'জরুরি সাহায্য পাওয়ার জন্য',
            icon: Icons.sos_rounded,
            color: const Color(0xFFAD1457),
          ),
          const SizedBox(height: 14),
          _EmergencyFormCard(
            nameCtrl: _nameCtrl,
            locCtrl: _locCtrl,
            formKey: _formKey,
            alertSent: _alertSent,
            busy: _busy,
            onEmergency: _sendEmergency,
            onSafe: _sendSafe,
            onResend: _sendEmergency,
          ),

          const SizedBox(height: 28),

          // â”€â”€ Women Helplines â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          const _SectionHeader(
            title: 'নারী সহায়তা হেল্পলাইন',
            icon: Icons.woman_rounded,
            color: Color(0xFFAD1457),
          ),
          const SizedBox(height: 14),
          ..._womenContacts.map((c) => _ContactTile(contact: c)),

          const SizedBox(height: 28),

          // â”€â”€ Children Helplines â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          const _SectionHeader(
            title: 'শিশু সহায়তা হেল্পলাইন',
            icon: Icons.child_care_rounded,
            color: Color(0xFF0288D1),
          ),
          const SizedBox(height: 14),
          ..._childrenContacts.map((c) => _ContactTile(contact: c)),

          const SizedBox(height: 28),

          // ── Cyber & Digital Safety
          const _SectionHeader(
            title: 'সাইবার ও ডিজিটাল নিরাপত্তা',
            icon: Icons.security_rounded,
            color: Color(0xFF0957DE),
          ),
          const SizedBox(height: 14),
          ..._cyberContacts.map((c) => _ContactTile(contact: c)),

          const SizedBox(height: 28),

          // ── One-Stop Crisis Centre
          const _SectionHeader(
            title: 'ওয়ান-স্টপ ক্রাইসিস সেন্টার (OCC)',
            icon: Icons.local_hospital_rounded,
            color: Color(0xFF00838F),
          ),
          const SizedBox(height: 14),
          const _InfoBannerCard(
            icon: Icons.info_rounded,
            color: Color(0xFF00838F),
            body:
                'OCC সরকারি হাসপাতালে বিনামূল্যে পাওয়া যায়। '
                'চিকিৎসা, পুলিশ, আইনি সহায়তা, কাউন্সেলিং ও আশ্রয় একই ছাদের নিচে।\n\n'
                '📍 DMCH, স্যার সলিমুল্লাহ, রাজশাহী, চট্টগ্রাম, সিলেট ওসমানী, ময়মনসিংহ মেডিকেল — সকল বিভাগীয় ও জেলা হাসপাতাল।',
          ),
          const SizedBox(height: 10),
          ..._occContacts.map((c) => _ContactTile(contact: c)),

          const SizedBox(height: 28),

          // ── Acid Attack & Violence
          const _SectionHeader(
            title: 'এসিড হামলা ও সহিংসতা সহায়তা',
            icon: Icons.emergency_rounded,
            color: Color(0xFFDC2626),
          ),
          const SizedBox(height: 14),
          ..._acidContacts.map((c) => _ContactTile(contact: c)),

          const SizedBox(height: 28),

          // ── Mental Health
          const _SectionHeader(
            title: 'মানসিক স্বাস্থ্য সহায়তা',
            icon: Icons.psychology_rounded,
            color: Color(0xFF7C3AED),
          ),
          const SizedBox(height: 14),
          ..._mentalHealthContacts.map((c) => _ContactTile(contact: c)),

          const SizedBox(height: 28),

          // ── Safety Guidelines
          const _SectionHeader(
            title: 'নিরাপত্তা নির্দেশিকা',
            icon: Icons.menu_book_rounded,
            color: Color(0xFF1565C0),
          ),
          const SizedBox(height: 14),
          ..._guidelines.map(
            (g) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _GuidelineCard(guide: g),
            ),
          ),
        ],
      ),
    );
  }
}

class _Contact {
  final String name;
  final String number;
  final String description;
  final IconData icon;
  final Color color;
  const _Contact({
    required this.name,
    required this.number,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class _Guide {
  final String title;
  final String body;
  final IconData icon;
  const _Guide({required this.title, required this.body, required this.icon});
}

const _womenContacts = [
  _Contact(
    name: 'জাতীয় নারী নির্যাতন প্রতিরোধ হেল্পলাইন',
    number: '109',
    description: 'মহিলা ও শিশু বিষয়ক মন্ত্রণালয়  — ২৪/৭',
    icon: Icons.support_agent_rounded,
    color: Color(0xFFAD1457),
  ),
  _Contact(
    name: 'জাতীয় জরুরি সেবা',
    number: '999',
    description: 'পুলিশ, ফায়ার সার্ভিস ও অ্যাম্বুলেন্স',
    icon: Icons.local_police_rounded,
    color: Color(0xFF1565C0),
  ),
  _Contact(
    name: 'BNWLA হেল্পলাইন',
    number: '01713014574',
    description: 'বাংলাদেশ জাতীয় নারী আইনজীবী সমিতি',
    icon: Icons.balance_rounded,
    color: Color(0xFF6A1B9A),
  ),
  _Contact(
    name: 'আইনি সহায়তা',
    number: '01714790400',
    description: 'বিনামূল্যে আইনি পরামর্শ সেবা',
    icon: Icons.gavel_rounded,
    color: Color(0xFF0277BD),
  ),
];

const _childrenContacts = [
  _Contact(
    name: 'শিশু হেল্পলাইন',
    number: '1098',
    description: 'শিশু সুরক্ষা ও নিপীড়ন প্রতিরোধ',
    icon: Icons.child_friendly_rounded,
    color: Color(0xFF0288D1),
  ),
  _Contact(
    name: 'শিশু সুরক্ষা কেন্দ্র',
    number: '01714090905',
    description: 'CPC — শিশু অধিকার সুরক্ষা',
    icon: Icons.security_rounded,
    color: Color(0xFF00838F),
  ),
];

const _guidelines = [
  _Guide(
    title: 'গৃহস্থালী সহিংসতা থেকে সুরক্ষা',
    body:
        'নিরাপদ স্থানে যান, প্রতিবেশী বা আত্মীয়ের সাহায্য নিন। '
        'প্রয়োজনে ১০৯ বা ৯৯৯ নম্বরে ফোন করুন। ঘরের বাইরে একটি নিরাপদ আশ্রয়ের ঠিকানা জেনে রাখুন।',
    icon: Icons.home_rounded,
  ),
  _Guide(
    title: 'হয়রানির ক্ষেত্রে করণীয়',
    body:
        'ঘটনার বিবরণ, তারিখ ও সাক্ষী মনে রাখুন। '
        'BNWLA বা আইনি সহায়তা কেন্দ্রে যোগাযোগ করুন। ডিজিটাল হয়রানির ক্ষেত্রে স্ক্রিনশট সংরক্ষণ করুন।',
    icon: Icons.report_rounded,
  ),
  _Guide(
    title: 'শিশু নিরাপত্তায় সতর্কতা',
    body:
        'শিশুকে অপরিচিতদের সাথে একা রাখবেন না। '
        'বিদ্যালয়-পথের রুটিন নির্ধারণ করুন। যেকোনো অস্বাভাবিক আচরণ দেখলে শিশু হেল্পলাইন ১০৯৮-এ ফোন করুন।',
    icon: Icons.shield_rounded,
  ),
  _Guide(
    title: 'দুর্যোগকালীন নারী নিরাপত্তা',
    body:
        'আশ্রয়কেন্দ্রে যাওয়ার সময় পরিচিত নারী বা পরিবারের সাথে থাকুন। '
        'আশ্রয়কেন্দ্রে আলাদা নারী-কক্ষ ব্যবহার করুন। প্রয়োজনে স্থানীয় কর্তৃপক্ষকে জানান।',
    icon: Icons.family_restroom_rounded,
  ),
  _Guide(
    title: 'ডিজিটাল হয়রানি থেকে সুরক্ষা',
    body:
        'হয়রানিমূলক বার্তা, ছবি বা পোস্টের স্ক্রিনশট সংরক্ষণ করুন। '
        'সোশ্যাল মিডিয়া প্রোফাইল প্রাইভেট রাখুন। '
        'সাইবার ক্রাইম ইউনিটে (01766678888) অথবা https://cybercrime.gov.bd -এ অভিযোগ করুন। '
        'পরিচিত ব্যক্তির সাথে ব্যক্তিগত তথ্য শেয়ার করা থেকে বিরত থাকুন।',
    icon: Icons.phonelink_lock_rounded,
  ),
  _Guide(
    title: 'নিরাপদ যাতায়াত',
    body:
        'রাইড শেয়ারে (পাঠাও/উবার) চালকের তথ্য ও গাড়ির নম্বর পরিবারকে জানান। '
        '"শেয়ার ট্রিপ" ফিচার চালু রাখুন। '
        'রাতে একা বাস স্টপে দাঁড়াবেন না। '
        'নিজেকে অনুসরণ করা মনে হলে জনবহুল জায়গায় প্রবেশ করুন ও ৯৯৯ নম্বরে ফোন করুন। '
        'চালক আপত্তিজনক আচরণ করলে গাড়ি থামিয়ে নামুন।',
    icon: Icons.directions_car_rounded,
  ),
  _Guide(
    title: 'কর্মক্ষেত্রে যৌন হয়রানি',
    body:
        'বাংলাদেশ শ্রম আইন ২০০৬ ও হাইকোর্টের ২০০৯ সালের নির্দেশনা অনুযায়ী '
        'প্রতিটি কর্মপ্রতিষ্ঠানে অভিযোগ কমিটি থাকা বাধ্যতামূলক। '
        'ঘটনার বিবরণ, তারিখ ও সাক্ষী লিখে রাখুন। HR-কে বা সরাসরি কমিটিতে লিখিত অভিযোগ দিন। '
        'আইনি সহায়তায় BNWLA: 01713014574।',
    icon: Icons.business_center_rounded,
  ),
  _Guide(
    title: 'এসিড হামলায় তাৎক্ষণিক করণীয়',
    body:
        '⚠️ সাথে সাথে প্রচুর পানি দিয়ে ক্ষত স্থান ধুয়ে ফেলুন (নিরপেক্ষক ব্যবহার করবেন না!)। '
        'দ্রুত নিকটতম হাসপাতাল বা OCC-তে যান। '
        'পুলিশে FIR করুন — এসিড নিক্ষেপ মারাত্মক ফৌজদারি অপরাধ। '
        'চিকিৎসা, আইনি ও পুনর্বাসন সহায়তায়: ASF বাংলাদেশ: 01730049901।',
    icon: Icons.warning_rounded,
  ),
  _Guide(
    title: 'মানব পাচার থেকে সতর্কতা',
    body:
        'অপরিচিত ব্যক্তির বিদেশে ভালো চাকরির প্রলোভন সম্পর্কে সতর্ক থাকুন। '
        'পাচারের সন্দেহ হলে: BNWLA 24hr হটলাইন: 01730049000, '
        'IOM বাংলাদেশ: 01779-300000 বা ৯৯৯ নম্বরে কল করুন। '
        'বৈধ রিক্রুটিং এজেন্সি BMET (www.bmet.gov.bd) তালিকায় যাচাই করুন।',
    icon: Icons.people_alt_rounded,
  ),
  _Guide(
    title: 'আইনি অধিকার — যা জানা দরকার',
    body:
        '• নারী ও শিশু নির্যাতন দমন আইন ২০০০ — ধর্ষণ, যৌতুকসহ নির্যাতনে সর্বোচ্চ মৃত্যুদণ্ড।\n'
        '• পারিবারিক সহিংসতা (প্রতিরোধ ও সুরক্ষা) আইন ২০১০ — সুরক্ষা আদেশ পাওয়ার অধিকার।\n'
        '• এসিড নিক্ষেপ নিয়ন্ত্রণ আইন ২০০২ — আজীবন কারাদণ্ড পর্যন্ত সাজা।\n'
        '• বিনামূল্যে আইনি সহায়তা: ১৬৪৩০ (জাতীয় আইনি সহায়তা সংস্থা)।',
    icon: Icons.gavel_rounded,
  ),
  _Guide(
    title: 'মানসিক স্বাস্থ্য — নিজেকে সাহায্য করুন',
    body:
        'সহিংসতা বা ট্রমার পর কাউন্সেলিং নেওয়া দুর্বলতা নয় — এটি সাহসিকতা। '
        'কান পেতে রই (Kaan Pete Roi): 01779-554391 — গোপনীয় শ্রবণ সেবা। '
        'NIMH কাউন্সেলিং সেবা: 02-9112613। '
        'OCC ও BNWLA-এর মাধ্যমে বিনামূল্যে সাইকোসোশ্যাল সাপোর্ট পাওয়া যায়।',
    icon: Icons.favorite_rounded,
  ),
];

const _cyberContacts = [
  _Contact(
    name: 'সাইবার ক্রাইম ইউনিট',
    number: '01766678888',
    description: 'BGD e-GOV CIRT — অনলাইন হয়রানি ও সাইবার অপরাধ',
    icon: Icons.computer_rounded,
    color: Color(0xFF0957DE),
  ),
  _Contact(
    name: 'পুলিশ সাইবার অপরাধ বিভাগ',
    number: '999',
    description: 'জাতীয় জরুরি সেবা — সাইবার অপরাধ রিপোর্ট',
    icon: Icons.local_police_rounded,
    color: Color(0xFF1565C0),
  ),
  _Contact(
    name: 'ডিজিটাল নিরাপত্তা হেল্পডেস্ক',
    number: '105',
    description: 'তথ্য ও যোগাযোগ প্রযুক্তি বিভাগ',
    icon: Icons.help_rounded,
    color: Color(0xFF0284C7),
  ),
];

const _occContacts = [
  _Contact(
    name: 'জাতীয় নারী নির্যাতন প্রতিরোধ হেল্পলাইন',
    number: '109',
    description: 'OCC রেফারেল ও সহায়তা — ২৪/৭ বিনামূল্যে',
    icon: Icons.local_hospital_rounded,
    color: Color(0xFF00838F),
  ),
  _Contact(
    name: 'DMCH OCC (ঢাকা মেডিকেল)',
    number: '02-55165305',
    description: 'ঢাকা মেডিকেল কলেজ হাসপাতাল — ১ম তলা',
    icon: Icons.medical_services_rounded,
    color: Color(0xFF00695C),
  ),
  _Contact(
    name: 'DNO জাতীয় হটলাইন',
    number: '16108',
    description: 'জাতীয় মহিলা নির্যাতন প্রতিরোধ ফোরাম',
    icon: Icons.support_agent_rounded,
    color: Color(0xFF00838F),
  ),
];

const _acidContacts = [
  _Contact(
    name: 'Acid Survivors Foundation (ASF)',
    number: '01730049901',
    description: 'চিকিৎসা, আইনি ও পুনর্বাসন সহায়তা',
    icon: Icons.emergency_rounded,
    color: Color(0xFFDC2626),
  ),
  _Contact(
    name: 'BNWLA — মানব পাচার হটলাইন',
    number: '01730049000',
    description: 'বাংলাদেশ জাতীয় নারী আইনজীবী সমিতি — ২৪/৭',
    icon: Icons.people_alt_rounded,
    color: Color(0xFF9C27B0),
  ),
  _Contact(
    name: 'IOM বাংলাদেশ (পাচার বিরোধী)',
    number: '01779300000',
    description: 'আন্তর্জাতিক অভিবাসন সংস্থা',
    icon: Icons.flight_rounded,
    color: Color(0xFF1565C0),
  ),
  _Contact(
    name: 'জাতীয় আইনি সহায়তা',
    number: '16430',
    description: 'বিনামূল্যে আইনি সহায়তা সেবা',
    icon: Icons.gavel_rounded,
    color: Color(0xFF558B2F),
  ),
];

const _mentalHealthContacts = [
  _Contact(
    name: 'কান পেতে রই',
    number: '01779554391',
    description: 'গোপনীয় পিয়ার লিসেনিং সার্ভিস',
    icon: Icons.hearing_rounded,
    color: Color(0xFF7C3AED),
  ),
  _Contact(
    name: 'NIMH কাউন্সেলিং',
    number: '029112613',
    description: 'জাতীয় মানসিক স্বাস্থ্য ইনস্টিটিউট, ঢাকা',
    icon: Icons.psychology_rounded,
    color: Color(0xFF6D28D9),
  ),
  _Contact(
    name: 'কান পেতে রই (বিকল্প)',
    number: '01779554391',
    description: 'মানসিক সহায়তা — রবি ও মঙ্গলবার বাদে প্রতিদিন',
    icon: Icons.self_improvement_rounded,
    color: Color(0xFF5B21B6),
  ),
];

// ─── Info Banner Card ──────────────────────────────────────────────────────────

class _InfoBannerCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String body;

  const _InfoBannerCard({
    required this.icon,
    required this.color,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              body,
              style: TextStyle(
                fontSize: 13,
                color: color.withValues(alpha: 0.85),
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.icon,
    this.color = const Color(0xFF1565C0),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

// â”€â”€â”€ Emergency Form Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _EmergencyFormCard extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController locCtrl;
  final GlobalKey<FormState> formKey;
  final bool alertSent;
  final bool busy;
  final VoidCallback onEmergency;
  final VoidCallback onSafe;
  final VoidCallback onResend;

  const _EmergencyFormCard({
    required this.nameCtrl,
    required this.locCtrl,
    required this.formKey,
    required this.alertSent,
    required this.busy,
    required this.onEmergency,
    required this.onSafe,
    required this.onResend,
  });

  static const _rose = Color(0xFFAD1457);
  static const _roseLight = Color(0xFFFCE4EC);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _rose.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: _rose.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name field
            TextFormField(
              controller: nameCtrl,
              decoration: _inputDec('আপনার নাম', Icons.person_outline),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'নাম আবশ্যক' : null,
            ),
            const SizedBox(height: 10),
            // Location field
            TextFormField(
              controller: locCtrl,
              decoration: _inputDec(
                'আপনার অবস্থান',
                Icons.location_on_outlined,
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'অবস্থান দিন' : null,
            ),
            const SizedBox(height: 14),

            if (!alertSent) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: busy ? null : onEmergency,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _rose,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    shadowColor: _rose.withValues(alpha: 0.4),
                  ),
                  icon: busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.sos_rounded),
                  label: const Text(
                    'জরুরি সাহায্য পাঠান',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF2E7D32)),
                ),
                child: const Text(
                  'সাহায্যের বার্তা পাঠানো হয়েছে।',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1B5E20),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: busy ? null : onSafe,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2E7D32),
                        side: const BorderSide(color: Color(0xFF2E7D32)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.check_circle_outline_rounded),
                      label: const Text(
                        'আমি নিরাপদ',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: busy ? null : onResend,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _rose,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text(
                        'আবার পাঠান',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDec(String label, IconData icon) => InputDecoration(
    hintText: label,
    hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
    prefixIcon: Icon(icon, color: _rose, size: 20),
    filled: true,
    fillColor: _roseLight.withValues(alpha: 0.35),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
      borderSide: const BorderSide(color: _rose, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.red, width: 2),
    ),
  );
}

// â”€â”€â”€ Contact Tile â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _ContactTile extends StatelessWidget {
  final _Contact contact;
  const _ContactTile({required this.contact});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: contact.color.withValues(alpha: 0.18)),
            boxShadow: [
              BoxShadow(
                color: contact.color.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            leading: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: contact.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(contact.icon, color: contact.color, size: 24),
            ),
            title: Text(
              contact.name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0D1B2A),
              ),
            ),
            subtitle: Text(
              contact.description,
              style: const TextStyle(fontSize: 11, color: Colors.black45),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ActionBtn(
                  icon: Icons.phone_rounded,
                  color: contact.color,
                  tooltip: 'কল করুন',
                  onTap: () => SafetyService().directCall(contact.number),
                ),
                const SizedBox(width: 6),
                _ActionBtn(
                  icon: Icons.sms_rounded,
                  color: const Color(0xFF1565C0),
                  tooltip: 'SMS পাঠান',
                  onTap: () => SafetyService().sendSms(
                    to: contact.number,
                    message: 'EMERGENCY: Help needed.',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }
}

// â”€â”€â”€ Guideline Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _GuidelineCard extends StatefulWidget {
  final _Guide guide;
  const _GuidelineCard({required this.guide});

  @override
  State<_GuidelineCard> createState() => _GuidelineCardState();
}

class _GuidelineCardState extends State<_GuidelineCard> {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              widget.guide.icon,
              color: const Color(0xFF1565C0),
              size: 22,
            ),
          ),
          title: Text(
            widget.guide.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0D1B2A),
            ),
          ),
          iconColor: const Color(0xFF1565C0),
          collapsedIconColor: Colors.black38,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                widget.guide.body,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
