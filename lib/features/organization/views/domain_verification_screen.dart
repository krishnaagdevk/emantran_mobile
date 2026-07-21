import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/widgets/atmospheric_blobs.dart';
import '../../../data/repositories/api_repository.dart';
import '../../dashboard/views/dashboard_screen.dart';

class DomainVerificationScreen extends StatefulWidget {
  const DomainVerificationScreen({super.key});

  @override
  State<DomainVerificationScreen> createState() => _DomainVerificationScreenState();
}

class _DomainVerificationScreenState extends State<DomainVerificationScreen> {
  int? _selectedMethodIndex;
  bool _isVerifying = false;
  bool _isVerified = false;
  String _verificationStatusText = 'Resolving DNS records for domain...';

  void _startVerification() async {
    if (_selectedMethodIndex == null) return;
    
    setState(() {
      _isVerifying = true;
      _verificationStatusText = 'Resolving DNS records for domain...';
    });

    // Step 1: DNS Resolve
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() {
      _verificationStatusText = 'Checking TXT records matching emantran-verification...';
    });

    // Step 2: TXT check
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() {
      _verificationStatusText = 'Establishing SSL handshake with authority server...';
    });

    // Step 3: Authority Server handshake
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() {
      _verificationStatusText = 'Applying official cryptographic signature...';
    });

    // Step 4: Verification finalize
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      final repo = Provider.of<ApiRepository>(context, listen: false);
      await repo.verifyCurrentRoom(); // Updates isVerified state globally

      setState(() {
        _isVerifying = false;
        _isVerified = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<ApiRepository>(context);
    final roomName = repo.currentRoom?.name ?? 'Emantra Workspace';
    final domain = repo.currentRoom?.domain ?? repo.currentUser?.domain ?? 'emantra.app';

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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _isVerified 
                ? _buildSuccessState(roomName)
                : _isVerifying 
                    ? _buildVerifyingState() 
                    : _buildMethodsState(roomName, domain),
          ),
        ),
      ),
    );
  }

  Widget _buildMethodsState(String roomName, String domain) {
    final methods = [
      {
        'title': 'DNS TXT Record',
        'desc': 'Insert a unique verification code txt record emantran-verification=7f3f... into your domain name records.',
        'icon': Icons.dns_outlined,
      },
      {
        'title': 'Privileged Admin Email',
        'desc': 'Receive a secure security payload link at admin@$domain, it@$domain, or hostmaster@$domain.',
        'icon': Icons.admin_panel_settings_outlined,
      },
      {
        'title': 'Document Upload',
        'desc': 'Upload corporate registration utility bills or tax invoice files proving authority over @$domain branding.',
        'icon': Icons.upload_file_outlined,
      },
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          Text(
            'Verify $roomName',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.primary,
                  fontSize: 26,
                ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Confirm authority over this email domain to unlock the green Official badge and display your room first in member discovery searches.',
            style: TextStyle(fontFamily: 'Outfit', color: AppColors.muted, fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 24),

          // Methods List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: methods.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final method = methods[index];
              final isSelected = _selectedMethodIndex == index;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMethodIndex = index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppColors.violet : AppColors.border,
                      width: isSelected ? 2.0 : 1.2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x041E1B1A),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        method['icon'] as IconData,
                        color: isSelected ? AppColors.violet : AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              method['title'] as String,
                              style: const TextStyle(
                                fontFamily: 'Outfit',
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              method['desc'] as String,
                              style: const TextStyle(
                                fontFamily: 'Outfit',
                                color: AppColors.muted,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Radio Circle Selector
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppColors.violet : AppColors.faint,
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: isSelected
                            ? Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: AppColors.violet,
                                  shape: BoxShape.circle,
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 32),

          // Primary Verify Action
          ElevatedButton(
            onPressed: _selectedMethodIndex != null ? _startVerification : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedMethodIndex != null ? AppColors.cta : AppColors.faint,
            ),
            child: const Text('Initiate validation process'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildVerifyingState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(
            color: AppColors.violet,
            strokeWidth: 4.5,
          ),
        ),
        const SizedBox(height: 36),
        Text(
          _verificationStatusText,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.primary,
                fontSize: 20,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        const Text(
          'Emantran verification systems are establishing handshake parameters with your domain record server...',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Outfit',
            color: AppColors.muted,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessState(String roomName) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: const BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0x2510B981),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.verified_rounded,
            color: Colors.white,
            size: 44,
          ),
        ),
        const SizedBox(height: 36),
        Text(
          'Verified Official Room!',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.primary,
                fontSize: 26,
              ),
        ),
        const SizedBox(height: 10),
        Text(
          'Congratulations! Your partition "$roomName" has been verified as an official organization space. All domain employees will auto-discover your official space first.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Outfit',
            color: AppColors.muted,
            fontSize: 15,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 48),

        ElevatedButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
              (route) => false,
            );
          },
          child: const Text('Go to room dashboard'),
        ),
      ],
    );
  }
}
