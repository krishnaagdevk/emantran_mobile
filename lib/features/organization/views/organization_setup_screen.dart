import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/widgets/atmospheric_blobs.dart';
import '../../../app/widgets/frameless_text_field.dart';
import '../../../data/repositories/api_repository.dart';
import 'room_discovery_screen.dart';
import 'domain_verification_screen.dart';

class OrganizationSetupScreen extends StatefulWidget {
  const OrganizationSetupScreen({super.key});

  @override
  State<OrganizationSetupScreen> createState() => _OrganizationSetupScreenState();
}

class _OrganizationSetupScreenState extends State<OrganizationSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _orgNameController = TextEditingController();

  @override
  void dispose() {
    _orgNameController.dispose();
    super.dispose();
  }

  void _createRoom() {
    if (_formKey.currentState!.validate()) {
      final repo = Provider.of<ApiRepository>(context, listen: false);
      final email = repo.currentUser?.email ?? '';
      final domain = email.contains('@') ? email.split('@').last : 'workspace.com';
      
      repo.createRoom(_orgNameController.text + ' Hub', domain);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Room "${_orgNameController.text} Hub" successfully established!'),
          backgroundColor: AppColors.success,
        ),
      );

      // Navigate to Domain Verification screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DomainVerificationScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<ApiRepository>(context);
    final email = repo.currentUser?.email ?? '';
    final domain = email.contains('@') ? email.split('@').last : 'workspace.com';

    return AtmosphericBlobs(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                Text(
                  'Create your organization room',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.primary,
                        fontSize: 28,
                      ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Establish a secure collaborative partition for events, RSVPs, and internal Slack-like threads.',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    color: AppColors.muted,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 36),

                // Form Card
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border, width: 1.2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x061E1B1A),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Organization Name Input
                        FramelessTextField(
                          labelText: 'organization room name',
                          hintText: 'Adobe Creative',
                          controller: _orgNameController,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter a name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Detected domain Pill
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'DETECTED DOMAIN:',
                              style: TextStyle(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.muted.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary, // #372475
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '@$domain'.toUpperCase(),
                                style: const TextStyle(
                                  fontFamily: 'JetBrains Mono',
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Only members with verified emails corresponding to this domain will be permitted entry.',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            color: AppColors.muted,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Action Button (Coral Pill)
                        ElevatedButton(
                          onPressed: _createRoom,
                          child: const Text('Create room'),
                        ),
                        const SizedBox(height: 16),

                        // Ghost Verify / Later option
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const RoomDiscoveryScreen()),
                            );
                          },
                          child: const Text(
                            'Verify domain identity later',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              color: AppColors.muted,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
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
}
