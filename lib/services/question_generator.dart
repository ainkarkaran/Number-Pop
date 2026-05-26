import 'dart:math';
import '../models/question.dart';
import '../models/difficulty.dart';

class QuestionGenerator {
  final Random _random = Random();

  Question generate(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return _generateEasy();
      case Difficulty.medium:
        return _generateMedium();
      case Difficulty.hard:
        return _generateHard();
    }
  }

  // ================= EASY =================
  Question _generateEasy() {
    int a = _random.nextInt(10) + 1;
    int b = _random.nextInt(10) + 1;

    String op = _random.nextBool() ? '+' : '-';

    int answer;
    String text;

    if (op == '+') {
      answer = a + b;
      text = "$a + $b";
    } else {
      if (a < b) {
        int temp = a;
        a = b;
        b = temp;
      }
      answer = a - b;
      text = "$a - $b";
    }

    return _buildQuestion(text, answer);
  }

  // ================= MEDIUM =================
  Question _generateMedium() {
    int a = _random.nextInt(20) + 1;
    int b = _random.nextInt(20) + 1;

    List<String> ops = ['+', '-', '×'];
    String op = ops[_random.nextInt(ops.length)];

    int answer;
    String text;

    switch (op) {
      case '+':
        answer = a + b;
        text = "$a + $b";
        break;

      case '-':
        if (a < b) {
          int temp = a;
          a = b;
          b = temp;
        }
        answer = a - b;
        text = "$a - $b";
        break;

      case '×':
        answer = a * b;
        text = "$a × $b";
        break;

      default:
        answer = 0;
        text = "";
    }

    return _buildQuestion(text, answer);
  }

  // ================= HARD =================
  Question _generateHard() {
    List<String> ops = ['+', '-', '×', '÷'];
    String op = ops[_random.nextInt(ops.length)];

    int a, b, answer;
    String text;

    switch (op) {
      case '+':
        a = _random.nextInt(50) + 10;
        b = _random.nextInt(50) + 10;
        answer = a + b;
        text = "$a + $b";
        break;

      case '-':
        a = _random.nextInt(100) + 20;
        b = _random.nextInt(50) + 10;
        if (a < b) {
          int temp = a;
          a = b;
          b = temp;
        }
        answer = a - b;
        text = "$a - $b";
        break;

      case '×':
        a = _random.nextInt(12) + 2;
        b = _random.nextInt(12) + 2;
        answer = a * b;
        text = "$a × $b";
        break;

      case '÷':
        b = _random.nextInt(11) + 2;
        answer = _random.nextInt(12) + 1;
        a = b * answer; // ensures clean division
        text = "$a ÷ $b";
        break;

      default:
        a = b = answer = 0;
        text = "";
    }

    return _buildQuestion(text, answer);
  }

  // ================= OPTIONS BUILDER =================
  Question _buildQuestion(String text, int correctAnswer) {
    Set<int> options = {correctAnswer};

    while (options.length < 4) {
      int variation = _random.nextInt(10) + 1;
      int wrong;

      if (_random.nextBool()) {
        wrong = correctAnswer + variation;
      } else {
        wrong = correctAnswer - variation;
      }

      if (wrong >= 0) {
        options.add(wrong);
      }
    }

    List<int> shuffled = options.toList()..shuffle();

    return Question(
      text: text,
      answer: correctAnswer,
      options: shuffled,
    );
  }
}