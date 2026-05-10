import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/family_info_model.dart';
import '../profile_page.dart';
import '../services/family_info_service.dart';

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

/// Shared Application Drawer
///
/// Place this on the root [MainScaffold] Scaffold. Each page receives
/// `onMenuTap` which calls `scaffoldKey.currentState?.openDrawer()`.
///
/// [currentIndex] : the currently visible page (0-5)
/// [onNavigate]   : called with the target page index when user taps an item
class AppDrawer extends StatefulWidget {
  final int currentIndex;
  final void Function(int index) onNavigate;

  const AppDrawer({
    super.key,
    required this.currentIndex,
    required this.onNavigate,
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  FamilyInfo? _familyInfo;
  bool _unsubscribing = false;

  @override
  void initState() {
    super.initState();
    FamilyInfoService().getFamilyInfo().then((info) {
      if (mounted) setState(() => _familyInfo = info);
    });
  }

  void _openProfile(BuildContext context) {
    Navigator.pop(context); // close drawer
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ProfilePage())).then((_) {
      // Reload family info when returning from profile
      FamilyInfoService().getFamilyInfo().then((info) {
        if (mounted) setState(() => _familyInfo = info);
      });
    });
  }

  Future<void> _unsubscribeFromDrawer() async {
    if (_unsubscribing) return;

    final shouldUnsubscribe = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('সাবস্ক্রিপশন বাতিল করবেন?'),
        content: const Text('বাতিল করলে আবার OTP দিয়ে লগইন করতে হবে।'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('না'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('হ্যাঁ, বাতিল করুন'),
          ),
        ],
      ),
    );

    if (shouldUnsubscribe != true) return;
    if(!mounted) return;
    // Close drawer after confirmation so this State stays valid for the dialog.
    Navigator.pop(context);

    setState(() => _unsubscribing = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final storedPhone =
          prefs.getString('userPhone') ?? _familyInfo?.phoneNumber ?? '';
      final phone = _normalizeBdMobile(storedPhone.trim());

      if (phone.isEmpty) {
        throw Exception('কোনো মোবাইল নম্বর পাওয়া যায়নি');
      }

      final response = await http
          .post(
            Uri.parse('${_baseUrl}unsubscribe.php'),
            body: {'user_mobile': phone},
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception('Server error: ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final status =
            decoded['statusCode']?.toString().trim().toUpperCase() ?? '';
        final statusDetail = decoded['statusDetail']?.toString().trim() ?? '';
        final message = decoded['message']?.toString().trim() ?? '';
        final success =
            decoded['success'] == true ||
            status == 'S1000' ||
            status == 'SUCCESS' ||
            status == 'OK';

        if (!success) {
          final serverMsg = message.isNotEmpty
              ? message
              : (statusDetail.isNotEmpty ? statusDetail : 'Unsubscribe failed');
          throw Exception(serverMsg);
        }
      }

      await prefs.setBool('isLoggedIn', false);
      await prefs.remove('userPhone');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('সাবস্ক্রিপশন বাতিল করা হয়েছে'),
          backgroundColor: Colors.green,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 250));
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('সাবস্ক্রিপশন বাতিল করা যায়নি: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _unsubscribing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final int currentIndex = widget.currentIndex;
    final onNavigate = widget.onNavigate;
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // ── Header ───────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 24,
              bottom: 28,
              left: 20,
              right: 20,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A3A6B), Color(0xFF1565C0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => _openProfile(context),
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  _familyInfo?.headOfFamilyName?.isNotEmpty == true
                      ? _familyInfo!.headOfFamilyName!
                      : 'Safe BD',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _familyInfo?.phoneNumber?.isNotEmpty == true
                      ? _familyInfo!.phoneNumber!
                      : 'দুর্যোগ ও নারী সেবা',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),

          // ── Menu Items ───────────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _DrawerItem(
                  icon: Icons.settings_rounded,
                  label: 'সেটিংস',
                  selected: currentIndex == 6,
                  onTap: () {
                    Navigator.pop(context);
                    onNavigate(6);
                  },
                ),
                // _DrawerItem(
                //   icon: Icons.info_outline_rounded,
                //   label: 'অ্যাপ সম্পর্কে',
                //   onTap: () => Navigator.pop(context),
                //   comingSoon: true,
                // ),
                _DrawerItem(
                  icon: Icons.remove_circle_outline_rounded,
                  label: _unsubscribing
                      ? 'সাবস্ক্রিপশন বাতিল হচ্ছে...'
                      : 'আনসাবস্ক্রাইব করুন',
                  customColor: const Color(0xFFD32F2F),
                  onTap: _unsubscribeFromDrawer,
                ),
              ],
            ),
          ),

          // ── Footer ───────────────────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Text(
              'দুর্যোগ সেবা v1.0.0',
              style: TextStyle(color: Colors.black38, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;
  final bool comingSoon;
  final Color? customColor;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.comingSoon = false,
    this.customColor,
  });

  @override
  Widget build(BuildContext context) {
    final itemColor =
        customColor ??
        (selected ? const Color(0xFF1565C0) : const Color(0xFF1A3A6B));

    return ListTile(
      leading: Icon(icon, color: itemColor, size: 24),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: itemColor,
        ),
      ),
      tileColor: selected ? const Color(0xFFEFF6FF) : Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      trailing: comingSoon
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF93C5FD)),
              ),
              child: const Text(
                'শীঘ্রই',
                style: TextStyle(fontSize: 11, color: Color(0xFF1565C0)),
              ),
            )
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      onTap: onTap,
    );
  }
}
