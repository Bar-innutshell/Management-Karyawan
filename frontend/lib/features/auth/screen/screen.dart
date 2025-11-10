import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/controller.dart';
import '../../../core/widgets/custom_text_field.dart'; 
import '../../../core/widgets/button.dart'; 

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.put(AuthController());
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Login', style: TextStyle(color: Colors.white)),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F1115), Color(0xFF111827)],
              ),
            ),
          ),

          // Accent Glows
          Positioned(
            top: -60,
            left: -40,
            child: _Glow(color: const Color(0xFF2563EB), size: 160),
          ),
          Positioned(
            bottom: -80,
            right: -50,
            child: _Glow(color: const Color(0xFF10B981), size: 200),
          ),

          // Content Card
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child:
                  Card(
                        color: const Color(0xFF1F2937),
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Header Teks
                              Text(
                                'Selamat datang',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Masuk untuk melanjutkan',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.white70),
                              ),
                              const SizedBox(height: 20),

                              // Form Input
                              CustomTextField(
                                controller: emailController,
                                labelText: 'Email',
                              ),
                              const SizedBox(height: 12),
                              CustomTextField(
                                controller: passwordController,
                                labelText: 'Password',
                                obscureText: true,
                              ),
                              const SizedBox(height: 16),

                              // Tombol Login
                              Obx(
                                () => Button(
                                  isLoading: controller.isLoading.value,
                                  text: 'Login',
                                  onPressed: () {
                                    // Logika Validasi & Login
                                    final email = emailController.text.trim();
                                    final password = passwordController.text;
                                    if (email.isEmpty || password.isEmpty) {
                                      Get.snackbar(
                                        'Validation',
                                        'Email and password are required',
                                        backgroundColor: Colors.red[800],
                                        colorText: Colors.white,
                                      );
                                      return;
                                    }
                                    controller.login(email, password);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.1, end: 0, curve: Curves.easeOut),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget Glow
class _Glow extends StatelessWidget {
  final Color color;
  final double size;
  const _Glow({required this.color, required this.size});

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
