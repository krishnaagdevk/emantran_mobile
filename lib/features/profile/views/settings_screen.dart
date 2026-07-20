import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _compactView = false;
  bool _notifRSVP = true;
  bool _notifAccepted = true;
  bool _notifDaily = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Group A: APPEARANCE
              _buildGroupHeader('APPEARANCE'),
              Container(
                decoration: _buildGroupDecoration(),
                child: Column(
                  children: [
                    _buildToggleRow('Dark Mode Theme', _darkMode, (val) {
                      setState(() {
                        _darkMode = val;
                      });
                    }),
                    const Divider(height: 1, color: AppColors.border),
                    _buildToggleRow('Compact Event List View', _compactView, (val) {
                      setState(() {
                        _compactView = val;
                      });
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Group B: NOTIFICATIONS
              _buildGroupHeader('NOTIFICATIONS'),
              Container(
                decoration: _buildGroupDecoration(),
                child: Column(
                  children: [
                    _buildToggleRow('Instant RSVP Responses', _notifRSVP, (val) {
                      setState(() {
                        _notifRSVP = val;
                      });
                    }),
                    const Divider(height: 1, color: AppColors.border),
                    _buildToggleRow('Guest Accepted Alerts', _notifAccepted, (val) {
                      setState(() {
                        _notifAccepted = val;
                      });
                    }),
                    const Divider(height: 1, color: AppColors.border),
                    _buildToggleRow('Daily digest summary', _notifDaily, (val) {
                      setState(() {
                        _notifDaily = val;
                      });
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Group C: LANGUAGE & REGION
              _buildGroupHeader('LANGUAGE & REGION'),
              Container(
                decoration: _buildGroupDecoration(),
                child: Column(
                  children: [
                    ListTile(
                      dense: true,
                      title: const Text(
                        'Language Selector',
                        style: TextStyle(fontFamily: 'Outfit', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink),
                      ),
                      trailing: Text(
                        'ENGLISH (US)',
                        style: TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary.withOpacity(0.8),
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.border),
                    ListTile(
                      dense: true,
                      title: const Text(
                        'System Calendar Standard',
                        style: TextStyle(fontFamily: 'Outfit', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink),
                      ),
                      trailing: Text(
                        'GREGORIAN',
                        style: TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Group D: ACCOUNT
              _buildGroupHeader('ACCOUNT CONFIGURATIONS'),
              Container(
                decoration: _buildGroupDecoration(),
                child: Column(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: ListTile(
                        dense: true,
                        onTap: () {},
                        title: const Text(
                          'Change security lock password',
                          style: TextStyle(fontFamily: 'Outfit', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.muted, size: 14),
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.border),
                    Material(
                      color: Colors.transparent,
                      child: ListTile(
                        dense: true,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Account erasure request sent to room administrator.'),
                              backgroundColor: AppColors.danger,
                            ),
                          );
                        },
                        title: const Text(
                          'Request Account Deletion',
                          style: TextStyle(fontFamily: 'Outfit', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.danger),
                        ),
                        trailing: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'JetBrains Mono',
          color: AppColors.cta, // Brand Coral headers
          fontWeight: FontWeight.w800,
          fontSize: 10,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  BoxDecoration _buildGroupDecoration() {
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border, width: 1.2),
    );
  }

  Widget _buildToggleRow(String title, bool value, ValueChanged<bool> onChanged) {
    return ListTile(
      dense: true,
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Outfit',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
      ),
      trailing: Switch.adaptive(
        value: value,
        activeColor: AppColors.cta,
        onChanged: onChanged,
      ),
    );
  }
}
