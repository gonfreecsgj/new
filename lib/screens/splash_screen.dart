import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../themes/app_theme.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _logoRotation = Tween<double>(begin: 0.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeIn,
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOut,
      ),
    );

    _startAnimation();
  }

  void _startAnimation() async {
    await _logoController.forward();
    await _textController.forward();
    
    await Future.delayed(const Duration(milliseconds: 1000));
    
    if (!mounted) return;
    
    // Check if user is already logged in
    final authProvider = context.read<AuthProvider>();
    await authProvider.initialize();
    
    if (authProvider.isAuthenticated) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.backgroundColor,
              AppTheme.surfaceColor,
              AppTheme.backgroundColor,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background particles
            Positioned.fill(
              child: CustomPaint(
                painter: _ParticlesPainter(),
              ),
            ),
            
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with glow effect
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoScale.value,
                        child: Transform.rotate(
                          angle: _logoRotation.value * 3.14159,
                          child: Container(
                            width: isSmallScreen ? 120 : 150,
                            height: isSmallScreen ? 120 : 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppTheme.neonGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryColor.withOpacity(0.5),
                                  blurRadius: 50,
                                  spreadRadius: 20,
                                ),
                                BoxShadow(
                                  color: AppTheme.secondaryColor.withOpacity(0.3),
                                  blurRadius: 80,
                                  spreadRadius: 40,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                Icons.wifi_tethering_rounded,
                                size: isSmallScreen ? 60 : 80,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // App name
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _textOpacity.value,
                        child: SlideTransition(
                          position: _textSlide,
                          child: Column(
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) {
                                  return AppTheme.neonGradient.createShader(bounds);
                                },
                                child: Text(
                                  'COGONA',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 36 : 48,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 8,
                                    shadows: [
                                      Shadow(
                                        color: AppTheme.primaryColor.withOpacity(0.8),
                                        blurRadius: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'NET',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 24 : 32,
                                  fontWeight: FontWeight.w300,
                                  color: AppTheme.textSecondary,
                                  letterSpacing: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Tagline
                  FadeInUp(
                    delay: const Duration(milliseconds: 1500),
                    duration: const Duration(milliseconds: 800),
                    child: Text(
                      'مستقبل إدارة شبكات الواي فاي',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        color: AppTheme.textMuted,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Loading indicator
                  FadeIn(
                    delay: const Duration(milliseconds: 2000),
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Version info at bottom
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: FadeIn(
                delay: const Duration(milliseconds: 1000),
                child: Center(
                  child: Text(
                    'الإصدار 1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for animated particles
class _ParticlesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryColor.withOpacity(0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.fill;

    // Draw random dots
    for (int i = 0; i < 50; i++) {
      final x = (i * 37) % size.width;
      final y = (i * 53) % size.height;
      final radius = (i % 3 + 1).toDouble();
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // Draw connecting lines
    final linePaint = Paint()
      ..color = AppTheme.primaryColor.withOpacity(0.05)
      ..strokeWidth = 0.5;

    for (int i = 0; i < 20; i++) {
      final x1 = (i * 73) % size.width;
      final y1 = (i * 89) % size.height;
      final x2 = (i * 113) % size.width;
      final y2 = (i * 127) % size.height;
      
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
