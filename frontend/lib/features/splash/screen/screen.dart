import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/config/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToAuth();
  }

  void _navigateToAuth() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    Get.offNamed(Routes.auth);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // background gradient (dark, professional)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F1115), Color(0xFF111827)],
              ),
            ),
          ),

          // decorative glow blobs
          Positioned(
            top: -60,
            left: -40,
            child: _GlowBlob(
              color: const Color(0xFF2563EB),
              size: 180,
            ),
          ),
          Positioned(
            bottom: -80,
            right: -50,
            child: _GlowBlob(
              color: const Color(0xFF10B981),
              size: 220,
            ),
          ),

          // content
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // logo circle with subtle pulse
                  Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1F2937), Color(0xFF111827)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black,
                              blurRadius: 24,
                              spreadRadius: 2,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.work_outline,
                            color: Colors.white,
                            size: 38,
                          ),
                        ),
                      )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(
                        begin: const Offset(0.98, 0.98),
                        end: const Offset(1.02, 1.02),
                        duration: 900.ms,
                        curve: Curves.easeInOut,
                      ),

                  const SizedBox(height: 20),

                  // app title
                  Text(
                        'Manajemen Karyawan',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),

                  const SizedBox(height: 8),

                  // tagline
                  Text(
                    'Kelola tim Anda lebih mudah, cepat, dan terukur',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ).animate().fadeIn(duration: 600.ms, delay: 120.ms),

                  const SizedBox(height: 28),

                  // three bouncing dots (dynamic loading)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _Dot(delay: 0.ms),
                      const SizedBox(width: 8),
                      _Dot(delay: 120.ms),
                      const SizedBox(width: 8),
                      _Dot(delay: 240.ms),
                    ],
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

// small glow circle
class _GlowBlob extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color, blurRadius: 80, spreadRadius: 40)],
      ),
    );
  }
}

// animated loading dot
class _Dot extends StatelessWidget {
  final Duration delay;
  const _Dot({required this.delay});

  @override
  Widget build(BuildContext context) {
    final dot = Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );

    return dot
        .animate(onPlay: (c) => c.repeat())
        .moveY(
          begin: 0,
          end: -6,
          duration: 600.ms,
          curve: Curves.easeInOut,
          delay: delay,
        )
        .then()
        .moveY(begin: -6, end: 0, duration: 600.ms, curve: Curves.easeInOut);
  }
}
