import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'providers/forecast_provider.dart';
import 'services/weather_service.dart';
import 'theme.dart';
import 'widgets/disaster_app_bar.dart';

// ── Signal data model ─────────────────────────────────────────────────────────

class _SignalData {
  final String banglaNumber;
  final String name;
  final Color color;
  final Color lightColor;
  final String windSpeed;
  final String stormNature;
  final List<String> publicActions;
  final List<String> portActions;
  final List<String> shipActions;
  final List<String> boatActions;

  const _SignalData({
    required this.banglaNumber,
    required this.name,
    required this.color,
    required this.lightColor,
    required this.windSpeed,
    required this.stormNature,
    required this.publicActions,
    required this.portActions,
    required this.shipActions,
    required this.boatActions,
  });
}

const _signals = <_SignalData>[
  _SignalData(
    banglaNumber: '১',
    name: 'দূরবর্তী সতর্ক সংকেত',
    color: Color(0xFF16A34A),
    lightColor: Color(0xFFDCFCE7),
    windSpeed: '৪০–৫০ কিমি/ঘন্টা',
    stormNature:
        'সমুদ্র এলাকায় নিম্নচাপ সৃষ্টি হয়েছে, এখনো বিপদের সম্ভাবনা কম।',
    publicActions: ['আবহাওয়ার খবর শুনতে হবে', 'সবাইকে সতর্ক থাকতে জানাতে হবে'],
    portActions: ['সতর্ক সংকেত উত্তোলন', 'নৌযানকে সতর্ক করা'],
    shipActions: ['সাবধানে চলাচল করতে হবে'],
    boatActions: ['গভীর সমুদ্রে না যাওয়াই ভালো'],
  ),
  _SignalData(
    banglaNumber: '২',
    name: 'দূরবর্তী হুঁশিয়ারি',
    color: Color(0xFF16A34A),
    lightColor: Color(0xFFDCFCE7),
    windSpeed: '৫০–৬০ কিমি/ঘন্টা',
    stormNature: 'নিম্নচাপ শক্তিশালী হচ্ছে।',
    publicActions: ['জরুরি খাদ্য ও পানি প্রস্তুত রাখুন', 'মোবাইল চার্জ রাখুন'],
    portActions: ['ছোট নৌযান সতর্ক রাখুন'],
    shipActions: ['আবহাওয়া পর্যবেক্ষণ করুন'],
    boatActions: ['দ্রুত ফিরে আসার প্রস্তুতি নিন'],
  ),
  _SignalData(
    banglaNumber: '৩',
    name: 'স্থানীয় সতর্ক সংকেত',
    color: Color(0xFFCA8A04),
    lightColor: Color(0xFFFEF9C3),
    windSpeed: '৬০ কিমি/ঘন্টা বা তার বেশি দমকা হাওয়া',
    stormNature: 'স্থানীয় ঝড় আঘাত করতে পারে।',
    publicActions: [
      'ঘরের দরজা-জানালা শক্ত করুন',
      'বাইরে অপ্রয়োজনীয় চলাচল কমান',
    ],
    portActions: ['ছোট নৌযান চলাচল সীমিত রাখুন'],
    shipActions: ['নিরাপদ অবস্থানে থাকুন'],
    boatActions: ['উপকূলে ফিরে আসুন'],
  ),
  _SignalData(
    banglaNumber: '৪',
    name: 'স্থানীয় হুঁশিয়ারি',
    color: Color(0xFFCA8A04),
    lightColor: Color(0xFFFEF9C3),
    windSpeed: '৬০–৭০ কিমি/ঘন্টা',
    stormNature: 'বন্দর এলাকায় ঝড় আঘাত হানতে পারে।',
    publicActions: [
      'আশ্রয়কেন্দ্র চিহ্নিত করুন',
      'গুরুত্বপূর্ণ কাগজ নিরাপদ স্থানে রাখুন',
    ],
    portActions: ['ঝুঁকিপূর্ণ কাজ বন্ধ রাখুন'],
    shipActions: ['নিরাপদ স্থানে নোঙর করুন'],
    boatActions: ['সমুদ্রে যাওয়া নিষিদ্ধ'],
  ),
  _SignalData(
    banglaNumber: '৫',
    name: 'বিপদ সংকেত',
    color: Color(0xFFEA580C),
    lightColor: Color(0xFFFFEDD5),
    windSpeed: '৭০–৮০ কিমি/ঘন্টা',
    stormNature: 'মাঝারি ঘূর্ণিঝড়।',
    publicActions: ['আশ্রয়ে যাওয়ার প্রস্তুতি নিন', 'শুকনা খাবার সংগ্রহ করুন'],
    portActions: ['বিপদ সংকেত জারি করুন'],
    shipActions: ['নিরাপদ আশ্রয়ে যান'],
    boatActions: ['দ্রুত তীরে ফিরুন'],
  ),
  _SignalData(
    banglaNumber: '৬',
    name: 'বড় বিপদ সংকেত',
    color: Color(0xFFEA580C),
    lightColor: Color(0xFFFFEDD5),
    windSpeed: '৮০–৯০ কিমি/ঘন্টা',
    stormNature: 'শক্তিশালী ঘূর্ণিঝড়।',
    publicActions: ['নিচু এলাকা ত্যাগ করুন', 'আশ্রয়কেন্দ্রে যাওয়া শুরু করুন'],
    portActions: ['সকল বন্দর কার্যক্রম বন্ধ রাখুন'],
    shipActions: ['নিরাপদ স্থানে অবস্থান নিন'],
    boatActions: ['সম্পূর্ণ চলাচল বন্ধ রাখুন'],
  ),
  _SignalData(
    banglaNumber: '৭',
    name: 'অতি বিপদ সংকেত',
    color: Color(0xFFDC2626),
    lightColor: Color(0xFFFEE2E2),
    windSpeed: '৯০–১১০ কিমি/ঘন্টা',
    stormNature: 'প্রবল ঘূর্ণিঝড় ও জলোচ্ছ্বাসের আশঙ্কা।',
    publicActions: ['সবাই অবিলম্বে আশ্রয়কেন্দ্রে যাবেন'],
    portActions: ['জরুরি অবস্থা ঘোষণা করুন'],
    shipActions: ['নিরাপদ অবস্থানে থাকুন'],
    boatActions: ['নৌকা শক্তভাবে বেঁধে রাখুন'],
  ),
  _SignalData(
    banglaNumber: '৮',
    name: 'মহাবিপদ সংকেত',
    color: Color(0xFFDC2626),
    lightColor: Color(0xFFFEE2E2),
    windSpeed: '১১০–১২০ কিমি/ঘন্টা',
    stormNature: 'মারাত্মক ঘূর্ণিঝড় ও বড় জলোচ্ছ্বাস।',
    publicActions: ['অবিলম্বে আশ্রয়কেন্দ্রে যান'],
    portActions: ['সম্পূর্ণ কার্যক্রম বন্ধ করুন'],
    shipActions: ['গভীর নিরাপদ স্থানে থাকুন'],
    boatActions: ['নিরাপদে বেঁধে রাখুন'],
  ),
  _SignalData(
    banglaNumber: '৯',
    name: 'চরম মহাবিপদ',
    color: Color(0xFF44403C),
    lightColor: Color(0xFFF5F5F4),
    windSpeed: '১২০–১৫০ কিমি/ঘন্টা',
    stormNature: 'অত্যন্ত ভয়ংকর ঘূর্ণিঝড়।',
    publicActions: ['বাইরে যাওয়া সম্পূর্ণ নিষেধ'],
    portActions: ['সম্পূর্ণ বিপর্যয় অবস্থা'],
    shipActions: ['জীবনরক্ষামূলক ব্যবস্থা চালু করুন'],
    boatActions: ['নিরাপদ আশ্রয়ে রাখুন'],
  ),
  _SignalData(
    banglaNumber: '১০',
    name: 'সর্বোচ্চ মহাবিপদ',
    color: Color(0xFF44403C),
    lightColor: Color(0xFFF5F5F4),
    windSpeed: '১৫০ কিমি/ঘন্টা বা তার বেশি',
    stormNature: 'সুপার সাইক্লোন, ব্যাপক ধ্বংস।',
    publicActions: [
      'আশ্রয়কেন্দ্রে অবস্থান করুন',
      'ঝড় শেষ না হওয়া পর্যন্ত বের হবেন না',
    ],
    portActions: ['সম্পূর্ণ বন্ধ ঘোষণা করুন'],
    shipActions: ['চরম নিরাপত্তা ব্যবস্থা নিন'],
    boatActions: ['সমুদ্রে থাকা সম্পূর্ণ নিষিদ্ধ'],
  ),
];

// ── Guideline group model ─────────────────────────────────────────────────────

class _GuidelineGroup {
  final String heading;
  final String emoji;
  final List<String> items;
  const _GuidelineGroup({
    required this.heading,
    required this.emoji,
    required this.items,
  });
}

// ── Category info model ───────────────────────────────────────────────────────

class _CategoryInfo {
  final int index;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color lightColor;

  const _CategoryInfo({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.lightColor,
  });
}

// ── Main page (card grid) ─────────────────────────────────────────────────────

class GuidelinesPage extends StatelessWidget {
  final VoidCallback? onMenuTap;
  const GuidelinesPage({super.key, this.onMenuTap});

  /// Opens the signal detail directly from any page (e.g. home).
  /// [signalLevel] 0 = safe/no signal; 1–10 = BMD warning signal.
  static void openSignalPage(BuildContext context, int signalLevel) {
    if (signalLevel > 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SignalDetailPage(signalIndex: signalLevel - 1),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _GuidelineDetailPage(info: _categories[0]),
        ),
      );
    }
  }

  static const _categories = <_CategoryInfo>[
    _CategoryInfo(
      index: 0,
      title: 'আবহাওয়া সংকেত',
      subtitle: 'সংকেত ১–১০ বিবরণ ও করণীয়',
      icon: Icons.flag_rounded,
      color: Color(0xFF2563EB),
      lightColor: Color(0xFFEFF6FF),
    ),
    _CategoryInfo(
      index: 1,
      title: 'নারী ও শিশু',
      subtitle: 'বিশেষ সুরক্ষা নির্দেশিকা',
      icon: Icons.people_alt_rounded,
      color: Color(0xFFDB2777),
      lightColor: Color(0xFFFDF2F8),
    ),
    _CategoryInfo(
      index: 2,
      title: 'ঘূর্ণিঝড়',
      subtitle: 'আগে, সময়ে ও পরে করণীয়',
      icon: Icons.cyclone_rounded,
      color: Color(0xFF059669),
      lightColor: Color(0xFFF0FDF4),
    ),
    _CategoryInfo(
      index: 3,
      title: 'বন্যা',
      subtitle: 'আগে, সময়ে ও পরে করণীয়',
      icon: Icons.water_rounded,
      color: Color(0xFF0284C7),
      lightColor: Color(0xFFF0F9FF),
    ),
    _CategoryInfo(
      index: 4,
      title: 'ভূমিকম্প',
      subtitle: 'আগে, সময়ে ও পরে করণীয়',
      icon: Icons.landslide_outlined,
      color: Color(0xFFB45309),
      lightColor: Color(0xFFFFFBEB),
    ),
    _CategoryInfo(
      index: 5,
      title: 'অগ্নিকাণ্ড',
      subtitle: 'আগে ও পরে করণীয়',
      icon: Icons.local_fire_department_rounded,
      color: Color(0xFFDC2626),
      lightColor: Color(0xFFFFF5F5),
    ),
    _CategoryInfo(
      index: 6,
      title: 'জলোচ্ছ্বাস',
      subtitle: 'আগে, সময়ে ও পরে করণীয়',
      icon: Icons.tsunami_rounded,
      color: Color(0xFF0891B2),
      lightColor: Color(0xFFECFEFF),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      extendBodyBehindAppBar: true,
      appBar: DisasterAppBar(
        title: 'দুর্যোগ গাইড',
        showMenuButton: true,
        onMenuTap: onMenuTap,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          MediaQuery.of(context).padding.top +
              116 +
              12, // top safe area + appbar height
          16,
          120, // Bottom padding for navigation bar
        ),
        children: [
          // ── Live Weather + Cyclone Warning ──────────────────────────────
          const _WeatherWarningCard(),
          const SizedBox(height: 24),
          // ── Section title ───────────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 4,
                height: 22,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E40AF),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'দুর্যোগ প্রস্তুতি গাইড',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D1B2A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.72,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, i) => _CategoryCard(
              info: _categories[i],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => _GuidelineDetailPage(info: _categories[i]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Category card ─────────────────────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  final _CategoryInfo info;
  final VoidCallback onTap;
  const _CategoryCard({required this.info, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 20, 12, 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: info.color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(info.icon, color: Colors.white, size: 30),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    info.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D1B2A),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    info.subtitle,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black45,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: info.lightColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: info.color.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'বিস্তারিত দেখুন',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: info.color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Weather + Cyclone Warning Card ────────────────────────────────────────────

class _WeatherWarningCard extends StatelessWidget {
  const _WeatherWarningCard();

  static ({String emoji, String label}) _wmoInfo(int code) {
    if (code == 0) return (emoji: '☀️', label: 'পরিষ্কার আকাশ');
    if (code <= 3) return (emoji: '⛅', label: 'আংশিক মেঘলা');
    if (code <= 48) return (emoji: '🌫️', label: 'কুয়াশা');
    if (code <= 55) return (emoji: '🌦️', label: 'গুঁড়ি গুঁড়ি বৃষ্টি');
    if (code <= 65) return (emoji: '🌧️', label: 'বৃষ্টি');
    if (code <= 82) return (emoji: '🌧️', label: 'ঝরনা বৃষ্টি');
    if (code == 95) return (emoji: '⛈️', label: 'বজ্রপাতসহ ঝড়');
    if (code >= 96) return (emoji: '⛈️', label: 'শিলাবৃষ্টিসহ ঝড়');
    return (emoji: '🌤️', label: 'পরিবর্তনশীল');
  }

  static Color _gradientStart(int level) {
    if (level == 0) return const Color(0xFF1565C0);
    if (level <= 2) return const Color(0xFF1565C0);
    if (level <= 4) return const Color(0xFFB45309);
    if (level <= 6) return const Color(0xFFEA580C);
    return const Color(0xFFB91C1C);
  }

  static Color _gradientEnd(int level) {
    if (level == 0) return const Color(0xFF42A5F5);
    if (level <= 2) return const Color(0xFF1E88E5);
    if (level <= 4) return const Color(0xFFD97706);
    if (level <= 6) return const Color(0xFFDC2626);
    return const Color(0xFF7F1D1D);
  }

  static String _banglaNum(int n) {
    const map = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯', '১০'];
    return n < map.length ? map[n] : n.toString();
  }

  @override
  Widget build(BuildContext context) {
    final fp = context.watch<ForecastProvider>();
    final cw = fp.currentWeather;

    final temp = cw?.temperature ?? 28.0;
    final humidity = cw?.humidity ?? 72.0;
    final windSpeed = cw?.windSpeed ?? 0.0;
    final weatherCode = cw?.weatherCode ?? 0;
    final isLoading = fp.loading && cw == null;

    final signalLevel = WeatherService.calculateWarningLevel(windSpeed);
    final wmoData = _wmoInfo(weatherCode);
    final gStart = _gradientStart(signalLevel);
    final gEnd = _gradientEnd(signalLevel);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section label ─────────────────────────────────────────────────
        Row(
          children: [
            Container(
              width: 4,
              height: 22,
              decoration: BoxDecoration(
                color: gStart,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'আবহাওয়া ও সতর্কতা',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: gStart,
              ),
            ),
            if (fp.loading && cw != null) ...[
              const SizedBox(width: 10),
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2, color: gStart),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),

        // ── Main weather card ─────────────────────────────────────────────
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [gStart, gEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: gStart.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: isLoading
              ? const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white54),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row: condition + temp + signal badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Emoji + temp
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  wmoData.emoji,
                                  style: const TextStyle(fontSize: 44),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${temp.toStringAsFixed(1)}°C',
                                  style: const TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    height: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  wmoData.label,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Cyclone signal badge
                          GestureDetector(
                            onTap: () => GuidelinesPage.openSignalPage(
                              context,
                              signalLevel,
                            ),
                            child: Container(
                              width: 80,
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.35),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    signalLevel == 0
                                        ? 'ঘূর্ণিঝড়'
                                        : 'ঘূর্ণিঝড়',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10,
                                    ),
                                  ),
                                  Text(
                                    signalLevel == 0
                                        ? 'সংকেত নেই'
                                        : 'সংকেত ${_banglaNum(signalLevel)}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: signalLevel == 0 ? 13 : 18,
                                      fontWeight: FontWeight.bold,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Icon(
                                    signalLevel == 0
                                        ? Icons.check_circle_rounded
                                        : Icons.warning_rounded,
                                    color: signalLevel == 0
                                        ? Colors.greenAccent
                                        : Colors.yellowAccent,
                                    size: 20,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'বিস্তারিত',
                                    style: const TextStyle(
                                      color: Colors.white60,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Stat chips row
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _WeatherChip(
                            icon: Icons.water_drop_rounded,
                            label: '${humidity.toStringAsFixed(0)}%',
                            sublabel: 'আর্দ্রতা',
                          ),
                          _WeatherChip(
                            icon: Icons.air_rounded,
                            label: '${windSpeed.toStringAsFixed(1)} km/h',
                            sublabel: 'বায়ু গতি',
                          ),
                          if (fp.fromCache)
                            const _WeatherChip(
                              icon: Icons.cloud_done_rounded,
                              label: 'ক্যাশে',
                              sublabel: 'সংরক্ষিত',
                            ),
                        ],
                      ),

                      // Warning strip (only when signal active)
                      if (signalLevel > 0) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.yellowAccent.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Text('⚠️', style: TextStyle(fontSize: 18)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  WeatherService.warningDescription(
                                    signalLevel,
                                  ),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Safe status strip (when no signal)
                      if (signalLevel == 0) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Text('✅', style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'আবহাওয়া স্বাভাবিক — কোনো ঘূর্ণিঝড় সতর্কতা নেই।',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
        ),

        // "See signal detail" link when warning active
        if (!isLoading && signalLevel > 0) ...[
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () =>
                  GuidelinesPage.openSignalPage(context, signalLevel),
              icon: Icon(Icons.open_in_new_rounded, size: 15, color: gStart),
              label: Text(
                'সংকেত ${_banglaNum(signalLevel)} — বিস্তারিত দেখুন',
                style: TextStyle(
                  color: gStart,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],

        if (!isLoading && fp.error != null && cw == null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFF59E0B)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.wifi_off_rounded,
                  color: Color(0xFFB45309),
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'আবহাওয়া তথ্য পাওয়া যাচ্ছে না। ইন্টারনেট সংযোগ নিশ্চিত করুন।',
                    style: TextStyle(color: Color(0xFF92400E), fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _WeatherChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;

  const _WeatherChip({
    required this.icon,
    required this.label,
    required this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 16),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                sublabel,
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Detail page ───────────────────────────────────────────────────────────────

class _GuidelineDetailPage extends StatelessWidget {
  final _CategoryInfo info;
  const _GuidelineDetailPage({required this.info});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF0D1B2A),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          info.title,
          style: const TextStyle(
            color: Color(0xFF0D1B2A),
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE0E7EF), height: 1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 36),
        children: _content(),
      ),
    );
  }

  List<Widget> _content() {
    switch (info.index) {
      case 0: // আবহাওয়া সংকেত
        return [
          _AlertBanner(),
          const SizedBox(height: 14),
          const _SectionHeader(
            icon: Icons.flag_rounded,
            color: Color(0xFF2563EB),
            title: 'আবহাওয়া সংকেত বিবরণ',
            subtitle: 'সংকেত ১ থেকে ১০ — অর্থ ও করণীয়',
          ),
          const SizedBox(height: 8),
          ..._signals.map((s) => _SignalTile(data: s)),
          const SizedBox(height: 16),
          _QuickReminderCard(),
        ];
      case 1: // নারী ও শিশু
        return [
          const _SectionHeader(
            icon: Icons.people_alt_rounded,
            color: Color(0xFFDB2777),
            title: 'নারী ও শিশু নির্দেশিকা',
            subtitle: 'দুর্যোগের আগে, সময়ে ও পরে',
          ),
          const SizedBox(height: 8),
          const _GuidelineTile(
            title: 'নারীদের বিশেষ করণীয়',
            icon: Icons.female_rounded,
            accentColor: Color(0xFFDB2777),
            groups: [
              _GuidelineGroup(
                heading: 'দুর্যোগের আগে',
                emoji: '📋',
                items: [
                  'মেনস্ট্রুয়াল হাইজিন কিট ও গর্ভকালীন কিট পৃথক ব্যাগে রাখুন।',
                  'গর্ভবতী হলে নিকটস্থ হেলথ পোস্ট ও হটলাইন নম্বর নোট করুন।',
                  'নিরাপদ স্থান ও কাউন্সেলিং সেশনের সময়সূচী আগে থেকে জানুন।',
                  'জরুরি ব্যক্তিগত ওষুধ ও স্বাস্থ্য রেকর্ড হাতের কাছে রাখুন।',
                ],
              ),
              _GuidelineGroup(
                heading: 'দুর্যোগের সময়',
                emoji: '⚠️',
                items: [
                  'গর্ভবতী হলে আশ্রয়ে পৌঁছানোর সময় স্বাস্থ্যকর্মীর তথ্য জানান।',
                  'প্রয়োজনে প্রাথমিক প্রসূতি কিট সঙ্গে রাখুন।',
                  'আশ্রয়কেন্দ্রে মহিলা-সেল/বিভাগের দাবি করুন।',
                  'স্যানিটেশন ও ব্যক্তিগত গোপনীয়তা নিশ্চিত করুন।',
                ],
              ),
              _GuidelineGroup(
                heading: 'দুর্যোগের পরে',
                emoji: '🔄',
                items: [
                  'মহিলা-ফ্রেন্ডলি স্বাস্থ্যক্যাম্প ও কাউন্সেলিং স্পেস খুঁজুন।',
                  'GBV (লিঙ্গভিত্তিক সহিংসতা) হটলাইন: ১০৯ নম্বরে ফোন করুন।',
                  'গর্ভবতী/শিশু-মায়েদের পোষ্ট-নাটাল ও নবজাতক যত্ন নিন।',
                  'নিরাপদ হাউজিং নিশ্চিত না হওয়া পর্যন্ত আশ্রয় ত্যাগ করবেন না।',
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          const _GuidelineTile(
            title: 'শিশুদের বিশেষ করণীয়',
            icon: Icons.child_care_rounded,
            accentColor: Color(0xFF7C3AED),
            groups: [
              _GuidelineGroup(
                heading: 'দুর্যোগের আগে',
                emoji: '📋',
                items: [
                  'শিশুর পরিচয়পত্র/নাম-নম্বরসহ ফ্যামিলি ট্রেসিং কাগজ রাখুন।',
                  'শিশুর জন্য স্ন্যাক্স, ডায়াপার ও খেলার সামগ্রী প্রস্তুত রাখুন।',
                  'চাইল্ড-ফ্রেন্ডলি স্পেসের অবস্থান আগে থেকে জেনে রাখুন।',
                  'শিশুকে দুর্যোগ মোকাবেলার সহজ নিয়ম শেখান।',
                ],
              ),
              _GuidelineGroup(
                heading: 'দুর্যোগের সময়',
                emoji: '⚠️',
                items: [
                  'শিশু ও বৃদ্ধদের আগে আশ্রয়কেন্দ্রে নিয়ে যান।',
                  'শিশুকে সবসময় দায়িত্বশীল প্রাপ্তবয়স্কের কাছে রাখুন।',
                  'শিশুর পরিচয় লেবেল (নাম, ফোন নম্বর) পোশাকে লাগিয়ে রাখুন।',
                  'চাইল্ড-ফ্রেন্ডলি আশ্রয়স্থলে রাখুন — খাবার ও নিরাপত্তা নিশ্চিত করুন।',
                ],
              ),
              _GuidelineGroup(
                heading: 'দুর্যোগের পরে',
                emoji: '🔄',
                items: [
                  'চাইল্ড ফ্রেন্ডলি স্পেস (CFS) তৈরি করুন — খেলনা ও নিরাপদ খাবারের ব্যবস্থা রাখুন।',
                  'হারানো শিশুদের ৪৮ ঘণ্টার মধ্যে ফ্যামিলি ট্রেসিং শুরু করুন।',
                  'অস্থায়ী শিক্ষা কেন্দ্র যত দ্রুত সম্ভব চালু করুন।',
                  'শিশুর মানসিক স্বাস্থ্য — প্লে-থেরাপি ও সাইকোসোশ্যাল কেয়ার নিশ্চিত করুন।',
                ],
              ),
            ],
          ),
        ]; // end case 1
      case 2: // ঘূর্ণিঝড়
        return [
          const _SectionHeader(
            icon: Icons.cyclone_rounded,
            color: Color(0xFF059669),
            title: 'ঘূর্ণিঝড় নির্দেশিকা',
            subtitle: 'আগে, সময়ে ও পরে করণীয়',
          ),
          const SizedBox(height: 12),
          const _DisasterMediaSection(
            videoAsset: 'assets/videos/cyclone guideline.mp4',
          ),
          const SizedBox(height: 8),
          const _GuidelineTile(
            title: 'পরিবারের জন্য প্রস্তুতি',
            icon: Icons.home_rounded,
            accentColor: Color(0xFF059669),
            groups: [
              _GuidelineGroup(
                heading: 'জরুরি ব্যাগ তৈরি করুন',
                emoji: '🎒',
                items: [
                  'পানি: ৬ লিটার/প্রতি ব্যক্তি/দিন (৩ দিনের হিসাব)।',
                  'শুকনো খাবার ৩ দিনের জন্য, বেবি ফুড ও নার্সিং কিট।',
                  'ওষুধ ৭ দিনের মজুদ, টর্চ ও ব্যাটারি।',
                  'মোবাইল পাওয়ারব্যাংক ও চার্জার।',
                  'পরিচয়পত্রের কপি, নগদ অর্থ।',
                  'প্রাথমিক চিকিৎসার সরঞ্জাম।',
                ],
              ),
              _GuidelineGroup(
                heading: 'ঘর ও সম্পদ নিরাপদ করুন',
                emoji: '🏠',
                items: [
                  'BMD / বন্দর বার্তা নিয়মিত শুনুন।',
                  'গৃহস্থালি সামগ্রী প্লাস্টিক/ড্রাইব্যাগে সংরক্ষণ করুন।',
                  'ঘরের দরজা-জানালা শক্তভাবে বন্ধ এবং আটকে দিন।',
                  'গবাদি পশু নিরাপদ উঁচু স্থানে নিয়ে যাওয়ার পরিকল্পনা রাখুন।',
                  'বিদ্যুৎ, গ্যাস ও পানির মেইন সুইচ বন্ধ করুন।',
                ],
              ),
              _GuidelineGroup(
                heading: 'আশ্রয়ের পরিকল্পনা করুন',
                emoji: '🏥',
                items: [
                  'নিকটস্থ আশ্রয়কেন্দ্র ও ইভাকুয়েশন রুট আগেই চিহ্নিত করুন।',
                  'আশ্রয়কেন্দ্রের র‍্যাম্প, পানি ও টয়লেটের ব্যবস্থা যাচাই করুন।',
                  'শিশু, গর্ভবতী নারী ও বৃদ্ধদের জন্য আলাদা মেডিকেল কিট তৈরি করুন।',
                  'প্রতিবেশীদের সতর্ক করুন — বিশেষত বয়স্ক ও প্রতিবন্ধী ব্যক্তিদের।',
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),
          const _SectionHeader(
            icon: Icons.restore_rounded,
            color: Color(0xFF2563EB),
            title: 'ঘূর্ণিঝড়ের পরে করণীয়',
            subtitle: 'দুর্যোগ পরবর্তী পুনরুদ্ধার',
          ),
          const SizedBox(height: 8),
          const _GuidelineTile(
            title: '০–৭২ ঘন্টা: জীবনরক্ষা ও স্বাস্থ্য',
            icon: Icons.medical_services_rounded,
            accentColor: Color(0xFFDC2626),
            groups: [
              _GuidelineGroup(
                heading: 'তাৎক্ষণিক করণীয়',
                emoji: '🚨',
                items: [
                  'কর্তৃপক্ষের অনুমতি না পাওয়া পর্যন্ত বাড়িতে ফিরবেন না।',
                  'গ্যাস লাইন, বিদ্যুৎ ও পানির পাইপ ব্যবহারের আগে পরীক্ষা করুন।',
                  'বন্যার পানি এড়িয়ে চলুন — দূষিত ও বিপজ্জনক হতে পারে।',
                  'আহতদের প্রাথমিক চিকিৎসা দিন এবং অ্যাম্বুলেন্স ডাকুন।',
                  'সব পানীয় পানি ফুটিয়ে বা বিশুদ্ধকরণ ট্যাবলেট দিয়ে পান করুন।',
                ],
              ),
              _GuidelineGroup(
                heading: 'স্বাস্থ্য ও স্যানিটেশন',
                emoji: '🧼',
                items: [
                  'বন্যার পানির সংস্পর্শে আসা খাবার ও ওষুধ ফেলে দিন।',
                  'সাপ ও বন্যায় বাস্তুচ্যুত প্রাণী থেকে সতর্ক থাকুন।',
                  'ডেঙ্গু/ডায়রিয়া/টাইফয়েড প্রতিরোধে পরিচ্ছন্নতা বজায় রাখুন।',
                  'হাত ধোয়ার স্টেশন ও স্যানিটেশন জোন ব্যবহার করুন।',
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          const _GuidelineTile(
            title: '৩–৩০ দিন: পুনর্বাসন ও পুনর্গঠন',
            icon: Icons.build_rounded,
            accentColor: Color(0xFF2563EB),
            groups: [
              _GuidelineGroup(
                heading: 'খাদ্য ও ত্রাণ',
                emoji: '🍚',
                items: [
                  'পরিবার-ভিত্তিক খাদ্য ও কুকিং-কিট বিতরণ কেন্দ্র থেকে সংগ্রহ করুন।',
                  'নারীদের খাদ্য-স্বত্ব ও অগ্রাধিকার নিশ্চিত করুন।',
                  'রোগ-প্রতিরোধী পরিচ্ছন্নতা ক্যাম্পেইনে অংশ নিন।',
                ],
              ),
              _GuidelineGroup(
                heading: 'ঘর ও কাঠামো',
                emoji: '🏗️',
                items: [
                  'ক্ষতিগ্রস্ত ঘরে প্রবেশের আগে কর্তৃপক্ষের পরিদর্শন নিশ্চিত করুন।',
                  'বন্যা ও ঝড়-প্রতিরোধী হাউজিং মডেল অনুসরণ করে পুনর্নির্মাণ করুন।',
                  'ক্ষয়ক্ষতির তথ্য স্থানীয় কর্তৃপক্ষকে জানান ও ছবি সংরক্ষণ করুন।',
                ],
              ),
              _GuidelineGroup(
                heading: 'মানসিক স্বাস্থ্য',
                emoji: '💙',
                items: [
                  'শিশুদের জন্য প্লে-থেরাপি ও চাইল্ড-ফ্রেন্ডলি স্পেস নিশ্চিত করুন।',
                  'বয়স্কদের জন্য গ্রুপ কাউন্সেলিং ও কমিউনিটি সাপোর্ট গ্রুপে যোগ দিন।',
                  'দুর্যোগ-পরবর্তী মানসিক আঘাত স্বাভাবিক — পেশাদার সাহায্য নিন।',
                  'SMS বা সোশ্যাল মিডিয়ায় পরিবারের সাথে যোগাযোগ রাখুন।',
                ],
              ),
            ],
          ),
        ]; // end case 2
      case 3: // বন্যা
        return [
          const _SectionHeader(
            icon: Icons.water_rounded,
            color: Color(0xFF0284C7),
            title: 'বন্যা নির্দেশিকা',
            subtitle: 'বন্যার আগে, সময়ে ও পরে করণীয়',
          ),
          const SizedBox(height: 12),
          const _DisasterMediaSection(
            videoAsset: 'assets/videos/flood guideline.mp4',
          ),
          const SizedBox(height: 8),
          const _GuidelineTile(
            title: 'বন্যার আগে প্রস্তুতি',
            icon: Icons.inventory_2_rounded,
            accentColor: Color(0xFF0284C7),
            groups: [
              _GuidelineGroup(
                heading: 'আগাম সতর্কতা',
                emoji: '📻',
                items: [
                  'বাংলাদেশ পানি উন্নয়ন বোর্ড (BWDB)-এর বন্যা পূর্বাভাস নিয়মিত শুনুন।',
                  'মূল্যবান জিনিসপত্র ও গুরুত্বপূর্ণ কাগজ উপরের তলায় সরিয়ে রাখুন।',
                  'জরুরি কিট প্রস্তুত করুন — খাবার, বিশুদ্ধ পানি, টর্চ, প্রাথমিক চিকিৎসা।',
                  'নিকটস্থ বন্যা আশ্রয়কেন্দ্র ও নিরাপদ পথ আগে থেকে চিহ্নিত করুন।',
                  'গাড়িতে জ্বালানি পূর্ণ রাখুন — দ্রুত সরে যেতে হতে পারে।',
                  'ঘরের আশেপাশের ড্রেন পরিষ্কার রাখুন।',
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          const _GuidelineTile(
            title: 'বন্যার সময় করণীয়',
            icon: Icons.warning_amber_rounded,
            accentColor: Color(0xFFEA580C),
            groups: [
              _GuidelineGroup(
                heading: 'তাৎক্ষণিক পদক্ষেপ',
                emoji: '🚨',
                items: [
                  'পানি বাড়তে শুরু করলে সঙ্গে সঙ্গে উঁচু জায়গায় সরে যান।',
                  'বন্যার পানিতে হাঁটবেন না — ৬ ইঞ্চি পানিও ভাসিয়ে নিতে পারে।',
                  'নিরাপদ হলে বৈদ্যুতিক সরঞ্জাম বন্ধ করুন এবং গ্যাস মিটার বন্ধ করুন।',
                  'স্থানীয় দুর্যোগ ব্যবস্থাপনা কর্মকর্তার নির্দেশ মেনে চলুন।',
                  'ভাসমান লাইফবয়, নৌকা বা ভাসার উপকরণ ব্যবহার করুন।',
                  'শিশু ও বয়স্কদের সবসময় দায়িত্বশীল ব্যক্তির কাছে রাখুন।',
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          const _GuidelineTile(
            title: 'বন্যার পরে করণীয়',
            icon: Icons.restore_rounded,
            accentColor: Color(0xFF059669),
            groups: [
              _GuidelineGroup(
                heading: 'ঘরে ফেরার আগে',
                emoji: '🏠',
                items: [
                  'পানি পুরোপুরি নামার আগে এবং কর্তৃপক্ষের অনুমতি ছাড়া ঘরে ফিরবেন না।',
                  'ঘরের কাঠামোগত ক্ষতি পরীক্ষা করুন — ভেতরে ঢোকার আগে।',
                  'সব পানীয় পানি ফুটিয়ে নিন বা বিশুদ্ধকরণ ট্যাবলেট ব্যবহার করুন।',
                ],
              ),
              _GuidelineGroup(
                heading: 'স্বাস্থ্য ও পরিচ্ছন্নতা',
                emoji: '🧼',
                items: [
                  'বন্যার পানির সংস্পর্শে আসা সব খাবার ফেলে দিন।',
                  'সাপ ও বাস্তুচ্যুত প্রাণী থেকে সতর্ক থাকুন।',
                  'ডুবে যাওয়া সব সারফেস পরিষ্কার ও জীবাণুমুক্ত করুন।',
                  'ডেঙ্গু প্রতিরোধে জমা পানি এড়িয়ে চলুন ও মশার ওষুধ ব্যবহার করুন।',
                ],
              ),
            ],
          ),
        ]; // end case 3
      case 4: // ভূমিকম্প
        return [
          const _SectionHeader(
            icon: Icons.landslide_outlined,
            color: Color(0xFFB45309),
            title: 'ভূমিকম্প নির্দেশিকা',
            subtitle: 'ভূমিকম্পের আগে, সময়ে ও পরে করণীয়',
          ),
          const SizedBox(height: 12),
          const _DisasterMediaSection(
            videoAsset: 'assets/videos/earthquake guideline.mp4',
          ),
          const SizedBox(height: 8),
          const _GuidelineTile(
            title: 'ভূমিকম্পের আগে প্রস্তুতি',
            icon: Icons.checklist_rounded,
            accentColor: Color(0xFFB45309),
            groups: [
              _GuidelineGroup(
                heading: 'ঘর ও পরিবার প্রস্তুত রাখুন',
                emoji: '🏗️',
                items: [
                  'প্রতিটি ঘরে নিরাপদ জায়গা চিহ্নিত করুন — শক্ত টেবিলের নিচে বা ভেতরের দেওয়ালের পাশে।',
                  'ভারী আসবাবপত্র, বুকশেলফ ও ওয়াটার হিটার দেওয়ালে আটকে রাখুন।',
                  'গ্যাস, পানি ও বিদ্যুতের মেইন সুইচ বন্ধ করতে জানুন।',
                  'জরুরি সরবরাহ — পানি, খাবার, প্রাথমিক চিকিৎসা, টর্চ — হাতের কাছে রাখুন।',
                  'পরিবারের সাথে Drop, Cover, Hold On অভ্যাস করুন।',
                  'বাংলাদেশ উচ্চ ভূকম্পন ঝুঁকিপূর্ণ এলাকায় — প্রস্তুত থাকুন।',
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          const _GuidelineTile(
            title: 'ভূমিকম্পের সময় করণীয়',
            icon: Icons.crisis_alert_rounded,
            accentColor: Color(0xFFDC2626),
            groups: [
              _GuidelineGroup(
                heading: 'DROP → COVER → HOLD ON',
                emoji: '⚠️',
                items: [
                  'DROP — হাত ও হাঁটুর উপর ঝুঁকে পড়ুন, মাথা রক্ষা করুন।',
                  'COVER — শক্ত টেবিলের নিচে আশ্রয় নিন অথবা ভেতরের দেওয়ালের পাশে থাকুন।',
                  'HOLD ON — কাঁপন থামা পর্যন্ত ধরে থাকুন — নড়াচড়ায় বেশিরভাগ আঘাত হয়।',
                  'জানালা, বাইরের দেওয়াল ও পড়তে পারে এমন কিছু থেকে দূরে থাকুন।',
                  'বাইরে থাকলে ভবন, বিদ্যুতের খুঁটি ও তার থেকে দূরে সরে যান।',
                  'গাড়িতে থাকলে ওভারপাস ও ভবন থেকে দূরে পাশে থামুন।',
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          const _GuidelineTile(
            title: 'ভূমিকম্পের পরে করণীয়',
            icon: Icons.health_and_safety_rounded,
            accentColor: Color(0xFF059669),
            groups: [
              _GuidelineGroup(
                heading: 'পরবর্তী পদক্ষেপ',
                emoji: '🔍',
                items: [
                  'আফটারশকের জন্য প্রস্তুত থাকুন — প্রতিটির পরে আঘাত ও ক্ষতি পরীক্ষা করুন।',
                  'গ্যাস লিক পরীক্ষা করুন — গন্ধ পেলে বের হয়ে কর্তৃপক্ষকে জানান।',
                  'ভূমিকম্পের পরে লিফট ব্যবহার করবেন না।',
                  'ক্ষতিগ্রস্ত এলাকায় না যাওয়াই ভালো।',
                  'ভয়েস কল এড়িয়ে SMS বা সোশ্যাল মিডিয়ায় পরিবারের সাথে যোগাযোগ করুন।',
                  'ভাঙা কাচ ও ধ্বংসস্তূপ থেকে পা রক্ষায় মজবুত জুতা পরুন।',
                ],
              ),
            ],
          ),
        ]; // end case 4
      case 5: // অগ্নিকাণ্ড
        return [
          const _SectionHeader(
            icon: Icons.local_fire_department_rounded,
            color: Color(0xFFDC2626),
            title: 'অগ্নিকাণ্ড নির্দেশিকা',
            subtitle: 'আগুনের আগে, সময়ে ও পরে করণীয়',
          ),
          const SizedBox(height: 12),
          const _DisasterMediaSection(
            videoAsset: 'assets/videos/fire_guideline.mp4',
          ),
          const SizedBox(height: 8),
          const _GuidelineTile(
            title: 'অগ্নিকাণ্ডের আগে প্রস্তুতি',
            icon: Icons.fire_extinguisher_rounded,
            accentColor: Color(0xFFDC2626),
            groups: [
              _GuidelineGroup(
                heading: 'প্রতিরোধমূলক ব্যবস্থা',
                emoji: '🔒',
                items: [
                  'প্রতিটি তলায় স্মোক অ্যালার্ম লাগান — প্রতি মাসে পরীক্ষা করুন।',
                  'দুটি বের হওয়ার পথসহ হোম এস্কেপ প্ল্যান তৈরি করুন এবং অভ্যাস করুন।',
                  'রান্নাঘর ও স্টোরে অগ্নিনির্বাপক যন্ত্র সহজলভ্য রাখুন।',
                  'রান্না বা মোমবাতি জ্বালিয়ে রেখে কখনো ঘর ছাড়বেন না।',
                  'গ্যাস সিলিন্ডার বাসস্থান থেকে দূরে সংরক্ষণ করুন।',
                  'বাংলাদেশ ফায়ার সার্ভিস নম্বর (১৬১৬৩) ফোনে সংরক্ষণ করুন।',
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          const _GuidelineTile(
            title: 'অগ্নিকাণ্ডের সময় করণীয়',
            icon: Icons.exit_to_app_rounded,
            accentColor: Color(0xFFEA580C),
            groups: [
              _GuidelineGroup(
                heading: 'দ্রুত নিরাপদ হন',
                emoji: '🔥',
                items: [
                  '"আগুন!" বলে চিৎকার করুন এবং সবাইকে দ্রুত বের করে দিন।',
                  'বের হওয়ার সময় দরজা বন্ধ রাখুন — আগুন ছড়াতে দেরি হবে। তালা দেবেন না।',
                  'ধোঁয়ার নিচে হামাগুড়ি দিয়ে চলুন — মেঝের কাছে বাতাস তুলনামূলক পরিষ্কার।',
                  'দরজা খোলার আগে হাত দিয়ে গরম কিনা পরীক্ষা করুন। গরম হলে অন্য পথে বের হন।',
                  'বাইরে গেলে কোনো কারণেই ভেতরে ফিরে যাবেন না।',
                  'নিরাপদ স্থানে পৌঁছে ৯৯৯ বা ১৬১৬৩ নম্বরে ফোন করুন।',
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          const _GuidelineTile(
            title: 'অগ্নিকাণ্ডের পরে করণীয়',
            icon: Icons.manage_search_rounded,
            accentColor: Color(0xFF059669),
            groups: [
              _GuidelineGroup(
                heading: 'পরবর্তী পদক্ষেপ',
                emoji: '📋',
                items: [
                  'ফায়ার সার্ভিস নিরাপদ ঘোষণা না করা পর্যন্ত ভবনে প্রবেশ করবেন না।',
                  'ক্ষতির ছবি তুলুন এবং বিমা ও কর্তৃপক্ষকে জানান।',
                  'ইউনিয়ন পরিষদ বা স্থানীয় কর্তৃপক্ষের মাধ্যমে অস্থায়ী আশ্রয় নিন।',
                  'তাপ বা ধোঁয়ার সংস্পর্শে আসা খাবার, ওষুধ ফেলে দিন।',
                  'শিশু বা প্রাপ্তবয়স্ক আঘাতের লক্ষণ দেখালে কাউন্সেলিং নিন।',
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),
        ]; // end case 5
      case 6: // জলোচ্ছ্বাস
        return [
          const _SectionHeader(
            icon: Icons.tsunami_rounded,
            color: Color(0xFF0891B2),
            title: 'জলোচ্ছ্বাস নির্দেশিকা',
            subtitle: 'আগে, সময়ে ও পরে করণীয়',
          ),
          const SizedBox(height: 12),
          const _DisasterMediaSection(
            videoAsset: 'assets/videos/tsnunami_guideline.mp4',
          ),
          const SizedBox(height: 8),
          const _GuidelineTile(
            title: 'জলোচ্ছ্বাসের আগে প্রস্তুতি',
            icon: Icons.inventory_2_rounded,
            accentColor: Color(0xFF0891B2),
            groups: [
              _GuidelineGroup(
                heading: 'আগাম সতর্কতা ও পরিকল্পনা',
                emoji: '📻',
                items: [
                  'বাংলাদেশ আবহাওয়া অধিদপ্তর (BMD)-এর সতর্কতা ও বন্দর সংকেত নিয়মিত শুনুন।',
                  'জলোচ্ছ্বাস-প্রবণ উপকূলীয় এলাকায় বাস করলে নিকটস্থ আশ্রয়কেন্দ্র আগে থেকে চিহ্নিত করুন।',
                  'উঁচু স্থানে যাওয়ার পথ ও বিকল্প পথ পরিবারের সবাইকে জানিয়ে রাখুন।',
                  'জরুরি কিট প্রস্তুত রাখুন — বিশুদ্ধ পানি, শুকনা খাবার, টর্চ, প্রাথমিক চিকিৎসা ও ওষুধ।',
                  'মূল্যবান কাগজপত্র ও পরিচয়পত্র জলরোধী ব্যাগে সংরক্ষণ করুন।',
                  'গবাদি পশু নিরাপদ উঁচু জায়গায় বাঁধার পরিকল্পনা আগে থেকে করুন।',
                ],
              ),
              _GuidelineGroup(
                heading: 'ঘর ও সম্পদ সুরক্ষা',
                emoji: '🏠',
                items: [
                  'ঘরের গুরুত্বপূর্ণ জিনিসপত্র ও খাদ্যশস্য উপরের তলায় বা উঁচু আলমারিতে রাখুন।',
                  'বিদ্যুৎ, গ্যাস ও পানির মেইন সুইচ বন্ধ রাখার পদ্ধতি পরিবারের সবাইকে জানান।',
                  'নৌকা ও মৎস্যসরঞ্জাম শক্তভাবে বেঁধে নিরাপদ স্থানে রাখুন।',
                  'প্রতিবেশী ও বয়স্ক ব্যক্তিদের সতর্ক করুন এবং সহায়তার ব্যবস্থা রাখুন।',
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          const _GuidelineTile(
            title: 'জলোচ্ছ্বাসের সময় করণীয়',
            icon: Icons.warning_amber_rounded,
            accentColor: Color(0xFFEA580C),
            groups: [
              _GuidelineGroup(
                heading: 'তাৎক্ষণিক পদক্ষেপ',
                emoji: '🚨',
                items: [
                  'সতর্কসংকেত পেলে সঙ্গে সঙ্গে উঁচু স্থান বা আশ্রয়কেন্দ্রে যান — দেরি করবেন না।',
                  'জলোচ্ছ্বাসের পানিতে কখনো হাঁটবেন না বা সাঁতার কাটবেন না — স্রোতে ভেসে যাওয়ার ঝুঁকি আছে।',
                  'শিশু, গর্ভবতী নারী, বয়স্ক ও প্রতিবন্ধীদের আগে নিরাপদ স্থানে নিয়ে যান।',
                  'কর্তৃপক্ষের নির্দেশ না পাওয়া পর্যন্ত উঁচু স্থানেই থাকুন।',
                  'মোবাইল ফোন চার্জ রেখে জরুরি নম্বরে (৯৯৯, ১০৯০) সংযোগ রাখুন।',
                  'ভাসমান গাছপালা, ধ্বংসাবশেষ ও বিদ্যুতের তার থেকে নিরাপদ দূরত্বে থাকুন।',
                ],
              ),
              _GuidelineGroup(
                heading: 'আশ্রয়কেন্দ্রে করণীয়',
                emoji: '🏥',
                items: [
                  'আশ্রয়কেন্দ্রে পৌঁছে নাম ও পরিবারের তথ্য নিবন্ধন করুন।',
                  'খাবার পানি ও স্যানিটেশন সুবিধা সুশৃঙ্খলভাবে ব্যবহার করুন।',
                  'আহত ব্যক্তিদের স্বাস্থ্যকর্মীর কাছে নিয়ে যান।',
                  'মহিলা ও শিশুদের জন্য আলাদা স্থানের ব্যবস্থা নিশ্চিত করুন।',
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          const _GuidelineTile(
            title: 'জলোচ্ছ্বাসের পরে করণীয়',
            icon: Icons.restore_rounded,
            accentColor: Color(0xFF059669),
            groups: [
              _GuidelineGroup(
                heading: 'ঘরে ফেরার আগে',
                emoji: '🏠',
                items: [
                  'কর্তৃপক্ষের অনুমতি না পাওয়া পর্যন্ত বাড়িতে ফিরবেন না।',
                  'ঘরে ঢোকার আগে কাঠামোগত ক্ষতি পরীক্ষা করুন — ছাদ, দেওয়াল ও মেঝে দেখুন।',
                  'গ্যাস লিক আছে কিনা পরীক্ষা করুন — গন্ধ পেলে বের হয়ে কর্তৃপক্ষকে জানান।',
                  'বিদ্যুৎ সংযোগ পুনরায় চালু করার আগে বিদ্যুৎ বিভাগের অনুমোদন নিন।',
                ],
              ),
              _GuidelineGroup(
                heading: 'স্বাস্থ্য ও স্যানিটেশন',
                emoji: '🧼',
                items: [
                  'সব পানীয় পানি ফুটিয়ে নিন বা বিশুদ্ধকরণ ট্যাবলেট ব্যবহার করুন।',
                  'লবণাক্ত ও দূষিত পানির সংস্পর্শে আসা সব খাবার ও পানীয় ফেলে দিন।',
                  'সাপ, কুকুর ও বাস্তুচ্যুত প্রাণী থেকে সতর্ক থাকুন।',
                  'ডায়রিয়া, কলেরা ও চর্মরোগ প্রতিরোধে পরিচ্ছন্নতা বজায় রাখুন।',
                  'ডেঙ্গু ও ম্যালেরিয়া প্রতিরোধে জমা পানি ও মশার বিরুদ্ধে সচেতন থাকুন।',
                ],
              ),
              _GuidelineGroup(
                heading: 'পুনর্বাসন ও সহায়তা',
                emoji: '🤝',
                items: [
                  'ক্ষয়ক্ষতির তথ্য ছবিসহ স্থানীয় ইউপি বা জেলা প্রশাসনে জমা দিন।',
                  'সরকারি ত্রাণ ও পুনর্বাসন কার্যক্রমে নাম নিবন্ধন করুন।',
                  'মৎস্যজীবীরা নৌকা ও সরঞ্জামের ক্ষতি কর্তৃপক্ষকে জানান — সহায়তা পেতে পারেন।',
                  'মানসিক আঘাত (PTSD) স্বাভাবিক — প্রয়োজনে কাউন্সেলিং সেবা নিন।',
                  'প্রতিবেশীদের সাথে মিলে সম্প্রদায়-ভিত্তিক পুনর্গঠনে অংশ নিন।',
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
        ]; // end case 6
      default:
        return [];
    }
  }
}

// ── Alert banner ──────────────────────────────────────────────────────────────

class _AlertBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E40AF), Color(0xFF2563EB)],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'সংকেত মনে রাখুন',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '১–৩: খবর রাখুন  •  ৪–৬: প্রস্তুত হন  •  ৭–১০: আশ্রয়ে যান',
                  style: TextStyle(color: Colors.white70, fontSize: 11.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 26),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, color: Colors.black45),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Signal tile (always visible, no expand) ─────────────────────────────────

class _SignalTile extends StatelessWidget {
  final _SignalData data;
  const _SignalTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final d = data;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        borderRadius: BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────
            Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: d.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      d.banglaNumber,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${d.banglaNumber} নম্বর সংকেত',
                        style: TextStyle(
                          fontSize: 13,
                          color: d.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        d.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.air_rounded,
                            size: 16,
                            color: Colors.black45,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              d.windSpeed,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(color: d.color.withValues(alpha: 0.2), height: 1),
            const SizedBox(height: 10),
            // ── Storm nature ─────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: d.lightColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🌊  ', style: TextStyle(fontSize: 18)),
                  Expanded(
                    child: Text(
                      d.stormNature,
                      style: const TextStyle(fontSize: 15, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // ── Sub-sections ─────────────────────────────────────────
            _SignalSection(
              emoji: '👨‍👩‍👧',
              label: 'জনপদে করণীয়',
              color: d.color,
              items: d.publicActions,
            ),
            _SignalSection(
              emoji: '⚓',
              label: 'বন্দরে',
              color: d.color,
              items: d.portActions,
            ),
            _SignalSection(
              emoji: '🚢',
              label: 'জাহাজ',
              color: d.color,
              items: d.shipActions,
            ),
            _SignalSection(
              emoji: '🚤',
              label: 'মাছ ধরার নৌকা',
              color: d.color,
              items: d.boatActions,
            ),
          ],
        ),
      ),
    );
  }
}

class _SignalSection extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final List<String> items;

  const _SignalSection({
    required this.emoji,
    required this.label,
    required this.color,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    margin: const EdgeInsets.only(top: 6, right: 9),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 15, height: 1.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Guideline tile (always visible, no expand) ───────────────────────────────

class _GuidelineTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accentColor;
  final List<_GuidelineGroup> groups;

  const _GuidelineTile({
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.groups,
  });

  @override
  Widget build(BuildContext context) {
    final c = accentColor;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section title card ────────────────────────────────────
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: c.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: c, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D1B2A),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // ── Groups (always visible) ───────────────────────────────
          ...groups.map((g) => _GroupSection(group: g, color: c)),
        ],
      ),
    );
  }
}

class _GroupSection extends StatelessWidget {
  final _GuidelineGroup group;
  final Color color;

  const _GroupSection({required this.group, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(group.emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    group.heading,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ...group.items.asMap().entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Center(
                      child: Text(
                        '${e.key + 1}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      e.value,
                      style: const TextStyle(fontSize: 15, height: 1.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Public single-signal detail page (used by home page) ────────────────────

/// Shows details for exactly ONE BMD warning signal in a large accessible
/// layout. Opened by tapping the signal panel on the home weather card.
class SignalDetailPage extends StatelessWidget {
  final int signalIndex; // 0–9  →  signals ১–১০
  const SignalDetailPage({required this.signalIndex, super.key});

  @override
  Widget build(BuildContext context) {
    final d = _signals[signalIndex.clamp(0, 9)];
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF0D1B2A),
            size: 22,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${d.banglaNumber} নম্বর সংকেত',
          style: const TextStyle(
            color: Color(0xFF0D1B2A),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE0E7EF), height: 1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 52),
        children: [_SignalTile(data: d)],
      ),
    );
  }
}

// ── Quick reminder card ───────────────────────────────────────────────────────

class _QuickReminderCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: BorderRadius.circular(14),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.campaign_rounded, color: Color(0xFF1E40AF), size: 22),
              SizedBox(width: 8),
              Text(
                'দ্রুত মনে রাখুন',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E40AF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _reminderRow(
            '🟢',
            'সংকেত ১–৩',
            'খবর রাখুন ও প্রস্তুত থাকুন',
            const Color(0xFF16A34A),
          ),
          _reminderRow(
            '🟡',
            'সংকেত ৪–৬',
            'প্রস্তুত হন — ঝুঁকিপূর্ণ এলাকা ছাড়ুন',
            const Color(0xFFCA8A04),
          ),
          _reminderRow(
            '🔴',
            'সংকেত ৭–১০',
            'আশ্রয়ে যান — জীবন সবার আগে',
            const Color(0xFFDC2626),
          ),
        ],
      ),
    );
  }

  Widget _reminderRow(String flag, String signal, String action, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(flag, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Text(
            signal,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          const Text('—', style: TextStyle(color: Colors.black38)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              action,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Disaster Media Section ─────────────────────────────────────────────────────

class _DisasterMediaSection extends StatefulWidget {
  /// Full Flutter asset path, e.g. 'assets/videos/cyclone guideline.mp4'
  final String videoAsset;

  const _DisasterMediaSection({required this.videoAsset});

  @override
  State<_DisasterMediaSection> createState() => _DisasterMediaSectionState();
}

class _DisasterMediaSectionState extends State<_DisasterMediaSection> {
  // Video – nullable; only created when user taps play
  VideoPlayerController? _videoCtrl;
  bool _videoLoading = false;
  bool _videoReady = false;
  bool _videoError = false;

  @override
  void dispose() {
    _videoCtrl?.dispose();
    super.dispose();
  }

  // ── Video helpers ─────────────────────────────────────────────────────────

  Future<void> _onTapVideo() async {
    if (_videoLoading) return;

    // Already ready → toggle play/pause
    if (_videoReady && _videoCtrl != null) {
      if (_videoCtrl!.value.isPlaying) {
        await _videoCtrl!.pause();
      } else {
        await _videoCtrl!.play();
      }
      setState(() {});
      return;
    }

    // Lazy init on first tap
    setState(() {
      _videoLoading = true;
      _videoError = false;
    });

    try {
      // Copy asset to a temp file so VideoPlayerController.file() can handle
      // large videos that Android's AssetManager cannot stream reliably.
      final fileName = widget.videoAsset.split('/').last;
      final tmpDir = await getTemporaryDirectory();
      final tmpFile = File('${tmpDir.path}/$fileName');

      if (!tmpFile.existsSync()) {
        final byteData = await rootBundle.load(widget.videoAsset);
        await tmpFile.writeAsBytes(
          byteData.buffer.asUint8List(
            byteData.offsetInBytes,
            byteData.lengthInBytes,
          ),
          flush: true,
        );
      }

      final ctrl = VideoPlayerController.file(tmpFile);
      _videoCtrl = ctrl;

      await ctrl.initialize();
      if (!mounted) {
        ctrl.dispose();
        return;
      }
      ctrl.addListener(() {
        if (mounted) setState(() {});
      });
      setState(() {
        _videoLoading = false;
        _videoReady = true;
      });
      await ctrl.play();
    } catch (e) {
      if (mounted) {
        setState(() {
          _videoLoading = false;
          _videoError = true;
        });
      }
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isPlaying = _videoCtrl?.value.isPlaying ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Video card ──────────────────────────────────────────────────────
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            color: Colors.black,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Video surface or 16:9 placeholder
                _videoReady && _videoCtrl != null
                    ? AspectRatio(
                        aspectRatio: _videoCtrl!.value.aspectRatio,
                        child: VideoPlayer(_videoCtrl!),
                      )
                    : const AspectRatio(
                        aspectRatio: 16 / 9,
                        child: SizedBox.expand(),
                      ),

                // Loading spinner (only while initializing)
                if (_videoLoading)
                  const CircularProgressIndicator(color: Colors.white70),

                // Error state
                if (_videoError)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.white60,
                        size: 36,
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'ভিডিও লোড হয়নি',
                        style: TextStyle(color: Colors.white60),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          _videoCtrl?.dispose();
                          _videoCtrl = null;
                          setState(() => _videoError = false);
                          _onTapVideo();
                        },
                        child: const Text(
                          'আবার চেষ্টা করুন',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),

                // Play button overlay (hidden while playing or loading)
                if (!_videoLoading && !_videoError)
                  GestureDetector(
                    onTap: _onTapVideo,
                    child: AnimatedOpacity(
                      opacity: isPlaying ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          color: Color(0xCC000000),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 38,
                        ),
                      ),
                    ),
                  ),

                // Tap-to-pause overlay when playing
                if (isPlaying)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: _onTapVideo,
                      behavior: HitTestBehavior.translucent,
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Progress bar (visible only once video is ready)
        if (_videoReady && _videoCtrl != null)
          VideoProgressIndicator(
            _videoCtrl!,
            allowScrubbing: true,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            colors: const VideoProgressColors(
              playedColor: Color(0xFF2563EB),
              bufferedColor: Color(0xFFBFDBFE),
              backgroundColor: Color(0xFFE2E8F0),
            ),
          ),
      ],
    );
  }
}
