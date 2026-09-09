import 'dart:math';
import 'package:directory_dash/core/constants/exam_constants.dart';
import 'package:directory_dash/core/database/app_database.dart';
import 'package:directory_dash/core/models/question.dart';
import 'package:directory_dash/core/models/question_attempt.dart';
import 'package:directory_dash/core/services/gamification_service.dart';

/// Engine responsible for domain-weighted question selection and quiz evaluations.
class QuestionEngine {
  final AppDatabase database;
  final GamificationService gamificationService;
  final Random _random;

  QuestionEngine({
    AppDatabase? db,
    GamificationService? gamification,
    Random? random,
  })  : database = db ?? AppDatabase.instance,
        gamificationService = gamification ?? GamificationService(db: db ?? AppDatabase.instance),
        _random = random ?? Random();

  /// Picks [count] questions weighted by domain percentages.
  /// If [part] is 'I', weights Part I domains (8 domains for OKCON1).
  /// If [part] is 'II', weights Part II use cases (4 use cases, 25% each).
  Future<List<Question>> pickWeightedQuestions({
    int count = 10,
    String? part = 'I',
    List<Question>? questionsPool,
  }) async {
    final pool = questionsPool ?? await database.getAllQuestions(part: part);
    if (pool.isEmpty) return [];
    if (pool.length <= count) {
      final shuffled = List<Question>.from(pool)..shuffle(_random);
      return shuffled;
    }

    final Map<String, double> weights = (part == 'II')
        ? ExamConstants.part2DomainWeights
        : ExamConstants.part1DomainWeights;

    // Group questions by domain
    final Map<String, List<Question>> byDomain = {};
    for (final q in pool) {
      byDomain.putIfAbsent(q.domain, () => []).add(q);
    }
    // Shuffle each bucket
    byDomain.forEach((key, list) => list.shuffle(_random));

    final List<Question> selected = [];
    final Set<String> selectedIds = {};

    // 1. First pass: Allocate integer targets based on domain weights
    int remainingCount = count;
    final Map<String, int> targetCounts = {};

    weights.forEach((domain, weight) {
      int domainTarget = (count * weight).round();
      if (domainTarget > remainingCount) domainTarget = remainingCount;
      targetCounts[domain] = domainTarget;
    });

    // Make sure sum of targets doesn't exceed count
    int sumTargets = targetCounts.values.fold(0, (a, b) => a + b);
    while (sumTargets > count) {
      final largestKey = targetCounts.keys.reduce((a, b) => targetCounts[a]! > targetCounts[b]! ? a : b);
      targetCounts[largestKey] = targetCounts[largestKey]! - 1;
      sumTargets--;
    }

    // Pull targeted counts from each domain
    targetCounts.forEach((domain, target) {
      final available = byDomain[domain] ?? [];
      final toTake = min(target, available.length);
      for (int i = 0; i < toTake; i++) {
        final q = available[i];
        selected.add(q);
        selectedIds.add(q.id);
      }
    });

    // 2. Second pass: If still under [count], sample remaining from pool using weighted random rolls
    final remainingPool = pool.where((q) => !selectedIds.contains(q.id)).toList()..shuffle(_random);

    while (selected.length < count && remainingPool.isNotEmpty) {
      // Pick domain by weighted roll
      final domain = _rollDomain(weights);
      final matchIndex = remainingPool.indexWhere((q) => q.domain == domain);

      if (matchIndex != -1) {
        final q = remainingPool.removeAt(matchIndex);
        selected.add(q);
        selectedIds.add(q.id);
      } else {
        // Domain empty in remaining pool, take next available
        final q = remainingPool.removeAt(0);
        selected.add(q);
        selectedIds.add(q.id);
      }
    }

    selected.shuffle(_random);
    return selected;
  }

  /// Evaluates an answer, writes attempt to database, and awards XP.
  Future<QuestionAnswerResult> submitAnswer({
    required Question question,
    required int selectedIndex,
    int timeSpentSeconds = 0,
    String mode = 'quiz',
  }) async {
    final isCorrect = question.isCorrect(selectedIndex);

    final attempt = QuestionAttempt(
      questionId: question.id,
      selectedIndex: selectedIndex,
      isCorrect: isCorrect,
      attemptedAt: DateTime.now(),
      timeSpentSeconds: timeSpentSeconds,
      mode: mode,
    );

    await database.recordAttempt(attempt);

    int xpEarned = 0;
    if (isCorrect) {
      xpEarned = ExamConstants.xpQuestionCorrect;
      await gamificationService.awardXp(xpEarned);
    }
    await gamificationService.recordActivity();

    return QuestionAnswerResult(
      isCorrect: isCorrect,
      correctIndex: question.correctIndex,
      explanation: question.explanation,
      xpEarned: xpEarned,
    );
  }

  String _rollDomain(Map<String, double> weights) {
    final totalWeight = weights.values.fold(0.0, (a, b) => a + b);
    final roll = _random.nextDouble() * totalWeight;
    double cumulative = 0.0;
    for (final entry in weights.entries) {
      cumulative += entry.value;
      if (roll <= cumulative) {
        return entry.key;
      }
    }
    return weights.keys.first;
  }
}

class QuestionAnswerResult {
  final bool isCorrect;
  final int correctIndex;
  final String explanation;
  final int xpEarned;

  const QuestionAnswerResult({
    required this.isCorrect,
    required this.correctIndex,
    required this.explanation,
    required this.xpEarned,
  });
}
