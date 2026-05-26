import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../logic/game_controller.dart';
import '../models/difficulty.dart';
import 'game_over_screen.dart';

// ─────────────────────────────────────────
//  Bubble speed config per difficulty
// ─────────────────────────────────────────
extension DifficultySpeed on Difficulty {
  /// Total duration for a bubble to travel from bottom to top
  Duration get bubbleDuration {
    switch (this) {
      case Difficulty.easy:
        return const Duration(seconds: 5);
      case Difficulty.medium:
        return const Duration(seconds: 7);
      case Difficulty.hard:
        return const Duration(seconds: 8);
    }
  }

  /// Stagger delay between each bubble launching
  Duration get staggerDelay {
    switch (this) {
      case Difficulty.easy:
        return const Duration(milliseconds: 600);
      case Difficulty.medium:
        return const Duration(milliseconds: 600);
      case Difficulty.hard:
        return const Duration(milliseconds: 600);
    }
  }

  String get label {
    switch (this) {
      case Difficulty.easy:
        return "EASY";
      case Difficulty.medium:
        return "MEDIUM";
      case Difficulty.hard:
        return "HARD";
    }
  }

  Color get color {
    switch (this) {
      case Difficulty.easy:
        return const Color(0xFF22C55E);
      case Difficulty.medium:
        return const Color(0xFFFBBF24);
      case Difficulty.hard:
        return const Color(0xFFEF4444);
    }
  }
}

// ─────────────────────────────────────────
//  Bubble colours (4 distinct per question)
// ─────────────────────────────────────────
const List<List<Color>> _bubbleGradients = [
  [Color(0xFF6EE7F7), Color(0xFF3B82F6)],  // cyan → blue
  [Color(0xFFA78BFA), Color(0xFF7C3AED)],  // violet → purple
  [Color(0xFF6EE7B7), Color(0xFF059669)],  // mint → green
  [Color(0xFFFDA4AF), Color(0xFFE11D48)],  // pink → rose
];

// ─────────────────────────────────────────
//  GameScreen
// ─────────────────────────────────────────
class GameScreen extends StatefulWidget {
  final Difficulty difficulty;

  const GameScreen({super.key, required this.difficulty});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameController controller;

  /// Each bubble gets its own animation controller
  final List<AnimationController> _bubbleControllers = [];
  final List<Animation<double>> _bubbleAnimations = [];

  /// Track which bubbles are still alive (not tapped, not off-screen)
  final List<bool> _bubbleActive = [true, true, true, true];

  /// Guard against answering twice
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    controller = GameController(widget.difficulty);
    controller.startGame();
    _launchBubbles();
  }

  // ── Launch all 4 bubbles with staggered start ──
  void _launchBubbles() {
    _clearBubbleControllers();
    _answered = false;
    for (int i = 0; i < 4; i++) {
      _bubbleActive[i] = true;
    }

    for (int i = 0; i < 4; i++) {
      final ac = AnimationController(
        vsync: Navigator.of(context),   // use ticker from navigator overlay
        duration: widget.difficulty.bubbleDuration,
      );

      // 0.0 = bottom, 1.0 = top (fully off screen)
      final anim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: ac, curve: Curves.linear),
      );

      _bubbleControllers.add(ac);
      _bubbleAnimations.add(anim);

      // When any bubble reaches the top without being tapped → game over
      anim.addStatusListener((status) {
        if (status == AnimationStatus.completed && !_answered) {
          if (mounted) _triggerGameOver();
        }
      });

      // Stagger the start of each bubble
      Future.delayed(widget.difficulty.staggerDelay * i, () {
        if (mounted) ac.forward();
      });
    }
  }

  void _clearBubbleControllers() {
    for (final ac in _bubbleControllers) {
      ac.dispose();
    }
    _bubbleControllers.clear();
    _bubbleAnimations.clear();
  }

  // ── User tapped a bubble ──
  void _handleAnswer(int index, int value) {
    if (_answered) return;
    _answered = true;

    // Stop all bubbles
    for (final ac in _bubbleControllers) {
      ac.stop();
    }

    setState(() {
      _bubbleActive[index] = false; // hide tapped bubble
    });

    final correct = controller.checkAnswer(value);

    if (correct) {
      // Short delay so the "pop" feels satisfying, then next question
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted) {
          setState(() {});
          _launchBubbles();
        }
      });
    } else {
      _triggerGameOver();
    }
  }

  void _triggerGameOver() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => GameOverScreen(
                score: controller.score,
                difficulty: widget.difficulty,
              ),
      ),
    );
  }

  @override
  void dispose() {
    _clearBubbleControllers();
    super.dispose();
  }

  // ─────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final q = controller.currentQuestion;
    final screenH = MediaQuery.of(context).size.height;
    final screenW = MediaQuery.of(context).size.width;

    // Bubble positions (x offset from left, percentage of width)
    final List<double> xPositions = [0.05, 0.28, 0.52, 0.72];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E3A5F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [

              // ── Background stars ──
              ..._buildStars(screenW, screenH),

              // ── Top bar: score + difficulty badge ──
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _buildTopBar(),
              ),

              // ── Question card ──
              Positioned(
                top: 70,
                left: 20,
                right: 20,
                child: _buildQuestionCard(q.text),
              ),

              // ── Floating bubbles ──
              if (_bubbleAnimations.isNotEmpty)
                ...List.generate(4, (i) {
                  if (!_bubbleActive[i]) return const SizedBox.shrink();
                  return AnimatedBuilder(
                    animation: _bubbleAnimations[i],
                    builder: (context, child) {
                      // y: starts at bottom, ends above top
                      final t = _bubbleAnimations[i].value;
                      final yPos = screenH - 80 - (t * (screenH + 120));
                      final xPos = xPositions[i] * screenW;

                      return Positioned(
                        left: xPos,
                        top: yPos,
                        child: _BubbleTile(
                          value: q.options[i],
                          gradientColors: _bubbleGradients[i],
                          onTap: () => _handleAnswer(i, q.options[i]),
                        ),
                      );
                    },
                  );
                }),

              // ── Bottom hint ──
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    "Tap the correct bubble before it escapes! 🫧",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Top bar ──
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Score pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                const Text("⭐ ", style: TextStyle(fontSize: 14)),
                Text(
                  "${controller.score}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Difficulty badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: widget.difficulty.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: widget.difficulty.color.withOpacity(0.5),
              ),
            ),
            child: Text(
              widget.difficulty.label,
              style: TextStyle(
                color: widget.difficulty.color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Question card ──
  Widget _buildQuestionCard(String questionText) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          Text(
            "What is",
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 13,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "$questionText = ?",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Decorative background stars ──
  List<Widget> _buildStars(double w, double h) {
    final rng = Random(42);
    return List.generate(28, (i) {
      final x = rng.nextDouble() * w;
      final y = rng.nextDouble() * h * 0.6;
      final size = rng.nextDouble() * 2.5 + 1;
      return Positioned(
        left: x,
        top: y,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(rng.nextDouble() * 0.4 + 0.1),
            shape: BoxShape.circle,
          ),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────
//  Bubble tile widget
// ─────────────────────────────────────────
class _BubbleTile extends StatefulWidget {
  final int value;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _BubbleTile({
    required this.value,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  State<_BubbleTile> createState() => _BubbleTileState();
}

class _BubbleTileState extends State<_BubbleTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _scaleController.forward();
  void _onTapUp(_) {
    _scaleController.reverse();
    widget.onTap();
  }
  void _onTapCancel() => _scaleController.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: widget.gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.gradientColors[1].withOpacity(0.55),
                blurRadius: 16,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.25),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              widget.value.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}