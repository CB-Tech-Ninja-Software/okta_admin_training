import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:directory_dash/core/constants/exam_constants.dart';
import 'package:directory_dash/core/database/app_database.dart';
import 'package:directory_dash/core/models/question.dart';
import 'package:directory_dash/core/services/question_engine.dart';
import 'package:directory_dash/core/services/gamification_service.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('QuestionEngine Tests', () {
    late AppDatabase db;
    late GamificationService gamification;
    late QuestionEngine engine;

    setUp(() async {
      db = AppDatabase.instance;
      final inMemoryDb = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      await db.init(dbOverride: inMemoryDb);
      gamification = GamificationService(db: db);
      engine = QuestionEngine(db: db, gamification: gamification);
    });

    tearDown(() async {
      await db.close();
    });

    test('pickWeightedQuestions allocates domain distribution accurately across 8 domains', () async {
      // Build a pool of 10 questions for each of the 8 Part I domains
      final List<Question> pool = [];
      for (final domain in ExamConstants.part1DomainWeights.keys) {
        for (int i = 0; i < 10; i++) {
          pool.add(Question(
            id: '${domain}_$i',
            part: 'I',
            domain: domain,
            question: '$domain Question $i',
            options: ['A', 'B', 'C', 'D'],
            correctIndex: 0,
            explanation: 'Exp',
          ));
        }
      }

      await db.batchInsertQuestions(pool);

      final selected = await engine.pickWeightedQuestions(count: 47, part: 'I');
      expect(selected.length, 47);

      // Verify each domain received its targeted count
      for (final entry in ExamConstants.part1DomainWeights.entries) {
        final count = selected.where((q) => q.domain == entry.key).length;
        final target = (47 * entry.value).round();
        expect(count, inInclusiveRange(target - 1, target + 1),
            reason: 'Domain ${entry.key} count ($count) should match target ($target)');
      }
    });

    test('submitAnswer evaluates correctness and awards XP', () async {
      final q = Question(
        id: 'q_test',
        part: 'I',
        domain: 'Active Directory Integration',
        question: 'Test Q',
        options: ['Wrong', 'Right'],
        correctIndex: 1,
        explanation: 'Right is index 1',
      );
      await db.batchInsertQuestions([q]);

      // Correct answer
      final res1 = await engine.submitAnswer(
        question: q,
        selectedIndex: 1,
        timeSpentSeconds: 5,
        mode: 'quiz',
      );
      expect(res1.isCorrect, isTrue);
      expect(res1.xpEarned, 10);

      final profileAfterCorrect = await gamification.getProfile();
      expect(profileAfterCorrect.xp, 10);

      // Incorrect answer
      final res2 = await engine.submitAnswer(
        question: q,
        selectedIndex: 0,
        timeSpentSeconds: 5,
        mode: 'quiz',
      );
      expect(res2.isCorrect, isFalse);
      expect(res2.xpEarned, 0);

      final profileAfterIncorrect = await gamification.getProfile();
      expect(profileAfterIncorrect.xp, 10); // No XP added for wrong answer
    });
  });
}
