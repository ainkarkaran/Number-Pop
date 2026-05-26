import '../models/question.dart';
import '../models/difficulty.dart';
import '../services/question_generator.dart';

class GameController {
  int score = 0;
  late Question currentQuestion;

  final Difficulty difficulty;
  final QuestionGenerator _generator = QuestionGenerator();

  GameController(this.difficulty);

  void startGame() {
    score = 0;
    nextQuestion();
  }

  void nextQuestion() {
    currentQuestion = _generator.generate(difficulty);
  }

  bool checkAnswer(int selectedAnswer) {
    if (selectedAnswer == currentQuestion.answer) {
      score++;
      nextQuestion();
      return true;
    } else {
      return false; // Game Over
    }
  }
}