import 'dart:math';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'game_screen.dart';
import '../models/difficulty.dart';

class GameOverScreen extends StatefulWidget {
  final int score;
  final Difficulty difficulty; // pass difficulty so Retry relaunches same level

  const GameOverScreen({
    super.key,
    required this.score,
    required this.difficulty,
  });

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen>
    with TickerProviderStateMixin {

  // ── Entry animations ──
  late AnimationController _entryController;
  late Animation<double> _fadeAnim;
  late Animation<double> _slideAnim;
  late Animation<double> _scaleAnim;

  // ── Emoji bounce ──
  late AnimationController _bounceController;
  late Animation<double> _bounceAnim;

  // ── Score count-up ──
  late AnimationController _countController;
  late Animation<int> _countAnim;

  // ── Particle burst ──
  final List<_Particle> _particles = [];
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    _generateParticles();

    // 1. Entry: fade + slide up
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _slideAnim = Tween<double>(begin: 60, end: 0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    // 2. Emoji bounce (loops)
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _bounceAnim = Tween<double>(begin: 0, end: -14).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
    _bounceController.repeat(reverse: true);

    // 3. Score count-up
    _countController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _countAnim = IntTween(begin: 0, end: widget.score).animate(
      CurvedAnimation(
        parent: _countController,
        curve: Curves.easeOutCubic,
      ),
    );

    // 4. Particles
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    // Start sequence
    _entryController.forward().then((_) {
      _particleController.forward();
      _countController.forward();
    });
  }

  void _generateParticles() {
    final rng = Random();
    for (int i = 0; i < 18; i++) {
      _particles.add(_Particle(
        angle: rng.nextDouble() * 2 * pi,
        speed: rng.nextDouble() * 120 + 60,
        color: _particleColors[rng.nextInt(_particleColors.length)],
        size: rng.nextDouble() * 8 + 5,
      ));
    }
  }

  static const List<Color> _particleColors = [
    Color(0xFF6EE7F7),
    Color(0xFFA78BFA),
    Color(0xFF6EE7B7),
    Color(0xFFFDA4AF),
    Color(0xFFFBBF24),
    Color(0xFFFFFFFF),
  ];

  @override
  void dispose() {
    _entryController.dispose();
    _bounceController.dispose();
    _countController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  // ── Score message ──
  String get _message {
    if (widget.score >= 20) return "Legendary! 🔥";
    if (widget.score >= 12) return "Impressive!";
    if (widget.score >= 6)  return "Not bad!";
    if (widget.score >= 2)  return "Keep going!";
    return "You got this!";
  }

  Color get _scoreColor {
    if (widget.score >= 20) return const Color(0xFFFFD700);
    if (widget.score >= 12) return const Color(0xFF6EE7F7);
    if (widget.score >= 6)  return const Color(0xFF6EE7B7);
    return const Color(0xFFFDA4AF);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      body: Stack(
        children: [

          // ── Gradient background ──
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.3),
                radius: 1.2,
                colors: [Color(0xFF1E3A5F), Color(0xFF0B1220)],
              ),
            ),
          ),

          // ── Background stars ──
          ..._buildStars(context),

          // ── Particle burst (origin = center) ──
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, _) {
              final t = _particleController.value;
              final size = MediaQuery.of(context).size;
              final cx = size.width / 2;
              final cy = size.height * 0.36;

              return Stack(
                children: _particles.map((p) {
                  final dist = p.speed * t;
                  final opacity = (1 - t).clamp(0.0, 1.0);
                  return Positioned(
                    left: cx + cos(p.angle) * dist - p.size / 2,
                    top:  cy + sin(p.angle) * dist - p.size / 2,
                    child: Opacity(
                      opacity: opacity,
                      child: Container(
                        width: p.size,
                        height: p.size,
                        decoration: BoxDecoration(
                          color: p.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          // ── Main card ──
          Center(
            child: AnimatedBuilder(
              animation: _entryController,
              builder: (context, child) => Opacity(
                opacity: _fadeAnim.value,
                child: Transform.translate(
                  offset: Offset(0, _slideAnim.value),
                  child: Transform.scale(
                    scale: _scaleAnim.value,
                    child: child,
                  ),
                ),
              ),
              child: Container(
                width: 300,
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 36),
                decoration: BoxDecoration(
                  color: const Color(0xFF131F35),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 40,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // ── Bouncing emoji ──
                    AnimatedBuilder(
                      animation: _bounceAnim,
                      builder: (_, __) => Transform.translate(
                        offset: Offset(0, _bounceAnim.value),
                        child: const Text(
                          "💥",
                          style: TextStyle(fontSize: 56),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ── Game Over title ──
                    const Text(
                      "GAME OVER",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // ── Message ──
                    Text(
                      _message,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.45),
                        fontSize: 14,
                        letterSpacing: 0.3,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Score display ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "YOUR SCORE",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 11,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          AnimatedBuilder(
                            animation: _countAnim,
                            builder: (_, __) => Text(
                              "${_countAnim.value}",
                              style: TextStyle(
                                color: _scoreColor,
                                fontSize: 52,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1,
                              ),
                            ),
                          ),

                          // Stars based on score
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (i) {
                              final filled = (widget.score >= [3, 8, 15][i]);
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 3),
                                child: Text(
                                  filled ? "⭐" : "☆",
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: filled
                                        ? Colors.amber
                                        : Colors.white
                                            .withOpacity(0.2),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Retry button ──
                    _ActionButton(
                      label: "🔄  Try Again",
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4F8EF7), Color(0xFF1E3A8A)],
                      ),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GameScreen(
                              difficulty: widget.difficulty,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    // ── Home button ──
                    _ActionButton(
                      label: "🏠  Home",
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.08),
                          Colors.white.withOpacity(0.04),
                        ],
                      ),
                      textColor: Colors.white.withOpacity(0.7),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.1)),
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const HomeScreen()),
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStars(BuildContext context) {
    final rng = Random(7);
    final size = MediaQuery.of(context).size;
    return List.generate(30, (i) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final s = rng.nextDouble() * 2 + 1;
      return Positioned(
        left: x, top: y,
        child: Container(
          width: s, height: s,
          decoration: BoxDecoration(
            color:
                Colors.white.withOpacity(rng.nextDouble() * 0.35 + 0.05),
            shape: BoxShape.circle,
          ),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────
//  Reusable action button with press scale
// ─────────────────────────────────────────
class _ActionButton extends StatefulWidget {
  final String label;
  final Gradient gradient;
  final Color textColor;
  final Border? border;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.gradient,
    this.textColor = Colors.white,
    this.border,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 90));
    _scale = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(16),
            border: widget.border,
          ),
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: widget.textColor,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  Particle data class
// ─────────────────────────────────────────
class _Particle {
  final double angle;
  final double speed;
  final Color color;
  final double size;

  const _Particle({
    required this.angle,
    required this.speed,
    required this.color,
    required this.size,
  });
}