import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'guidelines_page.dart';
import 'login.dart';
import 'providers/admin_notification_provider.dart';
import 'providers/app_provider.dart';
import 'providers/contact_provider.dart';
import 'providers/forecast_provider.dart';
import 'providers/shelter_provider.dart';
import 'services/notification_service.dart';
import 'settings_page.dart';
import 'widgets/app_drawer.dart';
import 'women_safety_page.dart';

const String _baseUrl = 'https://flicksize.com/women_safety/';

String _normalizeBdMobile(String rawMobile) {
  var digits = rawMobile.replaceAll(RegExp(r'\D+'), '');

  if (digits.startsWith('880') && digits.length == 13) {
    digits = '0${digits.substring(3)}';
  } else if (digits.startsWith('88') && digits.length == 12) {
    digits = '0${digits.substring(2)}';
  }

  return digits;
}

bool _isAllowedRobiAirtel(String normalizedMobile) {
  return RegExp(r'^01[3-9]\d{8}$').hasMatch(normalizedMobile);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WomenSafetyDisasterApp());
}

class WomenSafetyDisasterApp extends StatelessWidget {
  const WomenSafetyDisasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => ForecastProvider()),
        ChangeNotifierProvider(create: (_) => ShelterProvider()),
        ChangeNotifierProvider(create: (_) => ContactProvider()),
        ChangeNotifierProvider(
          create: (_) => AdminNotificationProvider()..load(),
        ),
      ],
      child: MaterialApp(
        title: 'দুর্যোগ ও নারী সেবা',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1976D2),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF8FAFC),
          textTheme: GoogleFonts.notoSansBengaliTextTheme().apply(
            fontFamily: 'TiroBangla',
          ),

          cardTheme: const CardThemeData(
            elevation: 0,
            color: Colors.white,
            margin: EdgeInsets.zero,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        home: const _StartupGate(),
        routes: {
          '/login': (_) => const LoginPage(),
          '/home': (_) => const _AppInitializer(),
        },
      ),
    );
  }
}

class _StartupGate extends StatefulWidget {
  const _StartupGate();

  @override
  State<_StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<_StartupGate> {
  bool _loading = true;
  bool _goHome = false;

  @override
  void initState() {
    super.initState();
    _resolveInitialRoute();
  }

  Future<void> _resolveInitialRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final phone = _normalizeBdMobile(
      prefs.getString('userPhone')?.trim() ?? '',
    );

    bool goHome = isLoggedIn;

    if (isLoggedIn && phone.isNotEmpty && _isAllowedRobiAirtel(phone)) {
      try {
        final response = await http
            .post(
              Uri.parse('$_baseUrl/check_subscription.php'),
              body: {'user_mobile': phone},
            )
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final status =
              data['subscriptionStatus']?.toString().toUpperCase() ?? '';

          final boolFlag = data['isSubscribed'];
          final isSubscribedFlag =
              boolFlag == true || boolFlag?.toString() == '1';

          // API অনুযায়ী: "INITIAL CHARGING PENDING" হলে user লগইন থাকবে।
          // তাই "pending/processing" স্ট্যাটাসে auto logout করাবো না।
          final isPending =
              status == 'INITIAL CHARGING PENDING' ||
              status == 'CHARGING PENDING' ||
              status == 'PENDING';

          final isSubscribed =
              isSubscribedFlag ||
              status == 'SUBSCRIBED' ||
              status == 'ACTIVATED' ||
              status == 'REGISTERED';

          if (!isSubscribed && !isPending) {
            goHome = false;
            await prefs.setBool('isLoggedIn', false);
          }
        }
      } catch (_) {
        // In case of network error, do not log the user out
      }
    } else if (!isLoggedIn) {
      goHome = false;
    }

    if (!mounted) return;
    setState(() {
      _goHome = goHome;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_goHome) {
      return const _AppInitializer();
    }

    return const LoginPage();
  }
}

class _AppInitializer extends StatefulWidget {
  const _AppInitializer();

  @override
  State<_AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<_AppInitializer> {
  bool _loading = true;
  Timer? _timer;
  late final NotificationService _notifService;

  @override
  void initState() {
    super.initState();
    _notifService = NotificationService();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _notifService.initialize(context, () {
        // navigate to notifications
      });
      final appProvider = context.read<AppProvider>();
      await appProvider.loadSosNumbers();
      await appProvider.fetchCurrentLocation();
      if (mounted) {
        // Trigger weather fetch after location is resolved
        context.read<ForecastProvider>().fetchForLocation(
          appProvider.latitude,
          appProvider.longitude,
        );
        _startClock();
        setState(() => _loading = false);
      }
    });
  }

  void _startClock() {
    context.read<AppProvider>().refreshDateTime();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) context.read<AppProvider>().refreshDateTime();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return const _MainNavigator();
  }
}

class _MainNavigator extends StatefulWidget {
  const _MainNavigator();

  @override
  State<_MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<_MainNavigator> {
  int _index = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openDrawer() => _scaffoldKey.currentState?.openDrawer();

  void _goto(int i) {
    // Index 6 = Settings — push as a full-screen route.
    if (i == 6) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const SettingsPage()));
      return;
    }
    if (i < 2) setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      WomenSafetyPage(onMenuTap: _openDrawer),
      GuidelinesPage(onMenuTap: _openDrawer),
    ];

    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(currentIndex: _index, onNavigate: _goto),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _goto,
        backgroundColor: Colors.white,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.woman_rounded),
            selectedIcon: Icon(Icons.woman_rounded),
            label: 'নারী সুরক্ষা',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'দুর্যোগ গাইড',
          ),
        ],
      ),
    );
  }
}
