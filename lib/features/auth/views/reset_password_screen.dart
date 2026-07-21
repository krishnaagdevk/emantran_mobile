import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/widgets/atmospheric_blobs.dart';
import '../../../app/widgets/frameless_text_field.dart';
import '../../../data/repositories/api_repository.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String? email;

  const ResetPasswordScreen({super.key, this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  
  int _strengthScore = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.email);
    _passwordController.addListener(_assessPasswordStrength);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_assessPasswordStrength);
    _emailController.dispose();
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _assessPasswordStrength() {
    final text = _passwordController.text;
    int score = 0;
    if (text.isEmpty) {
      score = 0;
    } else {
      if (text.length >= 6) score++; // length
      if (text.contains(RegExp(r'[A-Z]'))) score++; // uppercase
      if (text.contains(RegExp(r'[0-9]'))) score++; // digit
      if (text.contains(RegExp(r'[!@#\$&*~_=-]'))) score++; // special char
    }
    setState(() {
      _strengthScore = score.clamp(0, 4);
    });
  }

  Future<void> _submit() async {
    if (_isLoading) return;

    if (_formKey.currentState!.validate()) {
      if (_strengthScore < 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please choose a stronger password (at least MEDIUM or STRONG).'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final repo = Provider.of<ApiRepository>(context, listen: false);
        await repo.resetPassword(
          _emailController.text.trim(),
          _tokenController.text.trim(),
          _passwordController.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password updated successfully. Please log in.'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text(e.toString().replaceAll('Exception: ', ''))),
                ],
              ),
              backgroundColor: AppColors.danger,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  'Set a new password',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.primary,
                        fontSize: 28,
                      ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Configure high-security lock credentials containing uppercase letters, numbers, and special characters.',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    color: AppColors.muted,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 24),

                // Reset Form Card
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border, width: 1.2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x061E1B1A),
                        blurRadius: 20,
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
                        // Email Input
                        FramelessTextField(
                          labelText: 'organization email',
                          hintText: 'sarah.jenkins@adobe.com',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Recovery Token Input
                        FramelessTextField(
                          labelText: 'recovery token',
                          hintText: 'mock-reset-...',
                          controller: _tokenController,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter your password reset token';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // New Password Input
                        FramelessTextField(
                          labelText: 'new password',
                          hintText: '••••••••',
                          controller: _passwordController,
                          obscureText: true,
                          validator: (val) {
                            if (val == null || val.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Password strength meter
                        _buildStrengthMeter(),
                        const SizedBox(height: 24),

                        // Confirm Password Input
                        FramelessTextField(
                          labelText: 'confirm password',
                          hintText: '••••••••',
                          controller: _confirmController,
                          obscureText: true,
                          validator: (val) {
                            if (val != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 36),

                        // Action Button (Coral Pill)
                        ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          child: _isLoading 
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Update password'),
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

  Widget _buildStrengthMeter() {
    String label = 'WEAK';
    Color scoreColor = AppColors.danger; // ba1a1a

    if (_strengthScore >= 3) {
      label = 'STRONG';
      scoreColor = AppColors.success; // Green #10B981
    } else if (_strengthScore == 2) {
      label = 'MEDIUM';
      scoreColor = AppColors.pending; // Amber
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'STRENGTH:',
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.muted.withOpacity(0.8),
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: scoreColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: List.generate(4, (index) {
            final active = index < _strengthScore;
            Color segColor = AppColors.faint.withOpacity(0.2); // unfilled

            if (active) {
              if (_strengthScore <= 1) {
                segColor = AppColors.danger;
              } else if (_strengthScore == 2) {
                segColor = AppColors.pending;
              } else {
                segColor = AppColors.success;
              }
            }

            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(
                  right: index < 3 ? 6 : 0,
                ),
                decoration: BoxDecoration(
                  color: segColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
