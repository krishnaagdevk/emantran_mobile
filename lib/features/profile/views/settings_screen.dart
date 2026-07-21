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
                      _showSettingUpdatedToast('Dark Mode preference saved.');
                    }),
                    const Divider(height: 1, color: AppColors.border),
                    _buildToggleRow('Compact Event List View', _compactView, (val) {
                      setState(() {
                        _compactView = val;
                      });
                      _showSettingUpdatedToast('Compact view preference saved.');
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
                      _showSettingUpdatedToast('Instant response alerts ${val ? "enabled" : "disabled"}.');
                    }),
                    const Divider(height: 1, color: AppColors.border),
                    _buildToggleRow('Guest Accepted Alerts', _notifAccepted, (val) {
                      setState(() {
                        _notifAccepted = val;
                      });
                      _showSettingUpdatedToast('Guest acceptance alerts ${val ? "enabled" : "disabled"}.');
                    }),
                    const Divider(height: 1, color: AppColors.border),
                    _buildToggleRow('Daily digest summary', _notifDaily, (val) {
                      setState(() {
                        _notifDaily = val;
                      });
                      _showSettingUpdatedToast('Daily digest report ${val ? "enabled" : "disabled"}.');
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
                        onTap: _showChangePasswordBottomSheet,
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
                        onTap: _showDeleteAccountConfirmationDialog,
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

  void _showSettingUpdatedToast(String message) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
        duration: const Duration(milliseconds: 1000),
      ),
    );
  }

  void _showChangePasswordBottomSheet() {
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 38,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.faint.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Change Password Lock',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Secure your offline access to invite registries and room directories.',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    style: const TextStyle(fontFamily: 'Outfit', color: AppColors.ink),
                    decoration: const InputDecoration(
                      labelText: 'NEW PASSWORD',
                      labelStyle: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.muted),
                      hintText: 'Enter at least 4 characters',
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.violet)),
                    ),
                    validator: (val) {
                      if (val == null || val.length < 4) {
                        return 'Password must be at least 4 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: confirmController,
                    obscureText: true,
                    style: const TextStyle(fontFamily: 'Outfit', color: AppColors.ink),
                    decoration: const InputDecoration(
                      labelText: 'CONFIRM PASSWORD',
                      labelStyle: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.muted),
                      hintText: 'Repeat new password',
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.violet)),
                    ),
                    validator: (val) {
                      if (val != passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Security lock password successfully updated!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    },
                    child: const Text('Update Password'),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDeleteAccountConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 24),
              SizedBox(width: 8),
              Text(
                'Delete Account?',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
          content: const Text(
            'This action is irreversible. All of your cached contacts, RSVP histories, and private keys will be wiped permanently from the device and room databases.',
            style: TextStyle(fontFamily: 'Outfit', fontSize: 13, color: AppColors.muted, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(fontFamily: 'Outfit', color: AppColors.muted)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Account erasure request queued & mock local workspace purged.'),
                    backgroundColor: AppColors.danger,
                  ),
                );
              },
              child: const Text('Permanently Delete', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700, color: AppColors.danger)),
            ),
          ],
        );
      },
    );
  }
}
