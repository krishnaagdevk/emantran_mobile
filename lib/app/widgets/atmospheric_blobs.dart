import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AtmosphericBlobs extends StatefulWidget {
  const AtmosphericBlobs({super.key, required this.child});

  final Widget child;

  @override
  State<AtmosphericBlobs> createState() => _AtmosphericBlobsState();
}

class _AtmosphericBlobsState extends State<AtmosphericBlobs> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Stack(
        children: [
          // Background Layer with Slowly Moving Blurred Pastel Blobs
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final val = _controller.value;
              final double t1 = val * 2 * math.pi;

              // Animate blob coordinates with simple sinusoid waves
              final double b1Left = size.width * -0.15 + math.sin(t1) * 35;
              final double b1Top = size.height * -0.05 + math.cos(t1) * 30;

              final double b2Right = size.width * -0.2 + math.cos(t1 + 1.0) * 45;
              final double b2Bottom = size.height * 0.1 + math.sin(t1 + 1.0) * 40;

              final double b3Left = size.width * 0.15 + math.sin(t1 * 1.5) * 50;
              final double b3Top = size.height * 0.35 + math.cos(t1 * 0.8) * 40;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Blob 1: Coral Blob Top-Left
                  Positioned(
                    left: b1Left,
                    top: b1Top,
                    child: Container(
                      width: 320,
                      height: 320,
                      decoration: const BoxDecoration(
                        color: AppColors.blobCoral,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Blob 2: Lavender Blob Bottom-Right
                  Positioned(
                    right: b2Right,
                    bottom: b2Bottom,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: const BoxDecoration(
                        color: AppColors.blobLavender,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Blob 3: Tertiary Yellow/Coral Soft Center-Left Blob
                  Positioned(
                    left: b3Left,
                    top: b3Top,
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        color: AppColors.cta.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          // Heavy Gaussian Blur Layer to turn crisp circles into smooth atmospheric gradients
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80.0, sigmaY: 80.0),
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
          ),
          // Content Overlay
          Positioned.fill(child: widget.child),
        ],
      ),
    );
  }
}
