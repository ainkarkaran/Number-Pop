import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/difficulty.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showInfo = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: Stack(
        children: [

          // ===== MAIN CONTENT =====
          SafeArea(
            child: Column(
              children: [

                // ===== HEADER =====
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF4F8EF7), Color(0xFF1E3A8A)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/logo.png',
                        height: 80,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "SOLVR",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Think. Solve. Level Up.",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Choose Your Level",
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      levelCard("Easy", "Warm-up puzzles", const Color(0xFF22C55E),Difficulty.easy),
                      const SizedBox(height: 14),
                      levelCard("Medium", "Challenge mode", const Color(0xFFFBBF24),Difficulty.medium),
                      const SizedBox(height: 14),
                      levelCard("Hard", "Brain breaker", const Color(0xFFEF4444),Difficulty.hard),
                    ],
                  ),
                ),

                const SizedBox(height: 60),
              ],
            ),
          ),

          // ===== HELP BUTTON =====
          Positioned(
            bottom: 25,
            right: 20,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  showInfo = true;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.help_outline,
                  color: Color(0xFF1E3A8A),
                  size: 26,
                ),
              ),
            ),
          ),

          // ===== BLUR INFO POPUP =====
          if (showInfo)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    showInfo = false;
                  });
                },
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    color: Colors.black.withOpacity(0.35),
                    child: Center(
                      child: GestureDetector(
                        // Prevent tapping inside popup from closing it
                        onTap: () {},
                        child: Container(
                          width: 320,
                          padding: const EdgeInsets.all(0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [

                              // ── Popup header ──
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 20),
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF4F8EF7),
                                      Color(0xFF1E3A8A)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(24),
                                    topRight: Radius.circular(24),
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    Text(
                                      "🎮",
                                      style: TextStyle(fontSize: 22),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "How To Play",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // ── Steps ──
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    20, 20, 20, 8),
                                child: Column(
                                  children: [
                                    _helpStep(
                                      emoji: "🔢",
                                      color: const Color(0xFF4F8EF7),
                                      title: "A maths question appears",
                                      desc:
                                          "Something like  \"5 + 3 = ?\"  shows up at the top of the screen.",
                                    ),
                                    const SizedBox(height: 14),
                                    _helpStep(
                                      emoji: "🫧",
                                      color: const Color(0xFF8B5CF6),
                                      title: "Bubbles float up",
                                      desc:
                                          "Four answer bubbles rise from the bottom. Each one has a different number inside.",
                                    ),
                                    const SizedBox(height: 14),
                                    _helpStep(
                                      emoji: "👆",
                                      color: const Color(0xFF22C55E),
                                      title: "Tap the right answer",
                                      desc:
                                          "Pop the bubble with the correct answer before it floats away!",
                                    ),
                                    const SizedBox(height: 14),
                                    _helpStep(
                                      emoji: "💥",
                                      color: const Color(0xFFEF4444),
                                      title: "Wrong answer = Game Over",
                                      desc:
                                          "One wrong tap and it's over. Stay sharp — no second chances!",
                                    ),
                                    const SizedBox(height: 14),
                                    _helpStep(
                                      emoji: "⭐",
                                      color: const Color(0xFFFBBF24),
                                      title: "Score as high as you can",
                                      desc:
                                          "Every correct bubble adds to your score. How far can you go?",
                                    ),
                                  ],
                                ),
                              ),

                              // ── Difficulty hint ──
                              Container(
                                margin: const EdgeInsets.fromLTRB(
                                    20, 8, 20, 0),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F4FF),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFF4F8EF7)
                                        .withOpacity(0.25),
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    Text("💡",
                                        style: TextStyle(fontSize: 16)),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        "Start with Easy to warm up, then try Hard when you feel brave!",
                                        style: TextStyle(
                                          color: Color(0xFF1E3A8A),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // ── Close button ──
                              const SizedBox(height: 16),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    showInfo = false;
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.fromLTRB(
                                      20, 0, 20, 20),
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF4F8EF7),
                                        Color(0xFF1E3A8A),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Text(
                                    "Got it, let's play!",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Help step widget ──
  Widget _helpStep({
    required String emoji,
    required Color color,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 18)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                desc,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

Widget levelCard(String title, String subtitle, Color color, Difficulty difficulty) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GameScreen(difficulty: difficulty),
        ),
      );
    },
    child: Container(
      width: 270,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            color: Color(0xFF9CA3AF),
            size: 16,
          ),
        ],
      ),
    ),
  );
}
}