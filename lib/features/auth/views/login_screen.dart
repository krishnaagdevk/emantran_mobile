import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/widgets/atmospheric_blobs.dart';
import '../../../app/widgets/frameless_text_field.dart';
import '../../../data/repositories/api_repository.dart';
import '../../organization/views/room_discovery_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // Curated slider state for event backdrops
  late final PageController _pageController;
  late final Timer _slideTimer;
  int _currentPage = 0;
  final List<String> _sliderImages = [
    'https://images.unsplash.com/photo-1511578314322-379afb476865?w=600',
    'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=600',
    'https://images.unsplash.com/photo-1475721027785-f74eccf877e2?w=600',
    'https://images.unsplash.com/photo-1505373877841-8d25f7d46678?w=600',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _slideTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % _sliderImages.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _slideTimer.cancel();
    _pageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading) return;
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final repo = Provider.of<ApiRepository>(context, listen: false);
        await repo.login(_emailController.text.trim(), _passwordController.text.trim());
        
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const RoomDiscoveryScreen()),
          );
        }
      } catch (e) {
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
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AtmosphericBlobs(
      child: Scaffold(
        backgroundColor: Colors.transparent, // Allow atmospheric blobs to show through
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                // Brand Header
                Text(
                  'Emantran',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: AppColors.primary,
                        fontSize: 42,
                        letterSpacing: -1.5,
                      ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Syncing communities, building events.',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    color: AppColors.muted,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 36),

                // Overlapping Card Structure (Login Group)
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Top Card: Bento Deck illustration with automatic sliding image carousel
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SizedBox(
                        width: double.infinity,
                        height: 180,
                        child: Stack(
                          children: [
                            // PageView slider
                            PageView.builder(
                              controller: _pageController,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentPage = index;
                                });
                              },
                              itemCount: _sliderImages.length,
                              itemBuilder: (context, index) {
                                return Image.network(
                                  _sliderImages[index],
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: AppColors.primary,
                                      child: const Center(
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white30),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: AppColors.primary,
                                    );
                                  },
                                );
                              },
                            ),
                            // Dark glass-morphic gradient overlay on top of PageView
                            IgnorePointer(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primary.withOpacity(0.85),
                                      AppColors.primary.withOpacity(0.45),
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                ),
                              ),
                            ),
                            // Welcome Back text
                            const Center(
                              child: IgnorePointer(
                                child: Text(
                                  'WELCOME BACK',
                                  style: TextStyle(
                                    fontFamily: 'JetBrains Mono',
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 3.0,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black26,
                                        offset: Offset(0, 2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Subtle Pagination Dots at the bottom center of the slider
                            Positioned(
                              bottom: 12,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  _sliderImages.length,
                                  (index) => AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    height: 5,
                                    width: _currentPage == index ? 14 : 5,
                                    decoration: BoxDecoration(
                                      color: _currentPage == index
                                          ? AppColors.cta
                                          : Colors.white.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Overlapping Form Card (The Overlap)
                    Padding(
                      padding: const EdgeInsets.only(top: 140, left: 14, right: 14),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.border, width: 1.2),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0C1E1B1A),
                              blurRadius: 24,
                              offset: Offset(0, 12),
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
                                labelText: 'email',
                                hintText: 'hello@organization.com',
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                validator: (val) {
                                  if (val == null || !val.contains('@')) {
                                    return 'Please enter a valid organization email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),

                              // Password Input
                              FramelessTextField(
                                labelText: 'password',
                                hintText: '••••••••',
                                controller: _passwordController,
                                obscureText: true,
                                validator: (val) {
                                  if (val == null || val.length < 4) {
                                    return 'Please enter a password';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 32),

                              // Sign in Button (Coral Pill)
                              ElevatedButton(
                                onPressed: _isLoading ? null : _submit,
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.0,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Text('Sign in'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 36),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'New here?',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        color: AppColors.muted,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterScreen()),
                        );
                      },
                      child: const Text(
                        'Create one',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          color: AppColors.violet,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Forgot Password link
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                    );
                  },
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      color: AppColors.muted,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),

                // Secure Banner Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.verified_user_outlined,
                      size: 14,
                      color: AppColors.violet,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'SECURE AUTHENTICATION',
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.muted.withOpacity(0.8),
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '© 2026 EMANTRAN SYSTEMS',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                    color: AppColors.faint.withOpacity(0.8),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
