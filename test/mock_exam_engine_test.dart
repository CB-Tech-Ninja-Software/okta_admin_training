import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:directory_dash/core/constants/exam_constants.dart';
import 'package:directory_dash/core/database/app_database.dart';
import 'package:directory_dash/core/models/question.dart';
import 'package:directory_dash/core/services/mock_exam_engine.dart';
import 'package:directory_dash/core/services/gamification_service.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('MockExamEngine Tests', () {
    late AppDatabase db;
    late GamificationService gamification;
    late MockExamEngine engine;

    setUp(() async {
      db = AppDatabase.instance;
      final inMemoryDb = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      await db.init(dbOverride: inMemoryDb);
      gamification = GamificationService(db: db);
      engine = MockExamEngine(db: db, gamification: gamification);
    });

    tearDown(() async {
      await db.close();
    });

    test('startExam creates 47-question session with domain-weighted 8-domain distribution', () async {
      final List<Question> pool = [];
      // Generate 15 questions per domain across all 8 Part I domains
      for (final domain in ExamConstants.part1DomainWeights.keys) {
        for (int i = 0; i < 15; i++) {
          pool.add(Question(
            id: '${domain}_$i',
            part: 'I',
            domain: domain,
            question: '$domain Q $i',
            options: ['A', 'B', 'C', 'D'],
            correctIndex: 0,
            explanation: 'Exp',
          ));
        }
      }
      await db.batchInsertQuestions(pool);

      final session = await engine.startExam();
      expect(session.totalQuestions, ExamConstants.mockExamQuestionCount); // 47
      expect(session.timeLimitSeconds, ExamConstants.mockExamTimeLimitSeconds); // 4500
      expect(session.currentQuestionIndex, 0);

      // Verify exact target allocations for each domain
      for (final entry in ExamConstants.part1DomainWeights.entries) {
        final domainCount = session.questions.where((q) => q.domain == entry.key).length;
        final expectedCount = (ExamConstants.mockExamQuestionCount * entry.value).round();
        expect(domainCount, expectedCount, reason: 'Domain ${entry.key} should have $expectedCount questions');
      }
    });

    test('sequential answer locking and score computation', () async {
      final List<Question> pool = [];
      // Generate at least 10 questions per domain across all 8 Part I domains
      for (final domain in ExamConstants.part1DomainWeights.keys) {
        for (int i = 0; i < 10; i++) {
          pool.add(Question(
            id: 'q_${domain}_$i',
            part: 'I',
            domain: domain,
            question: '$domain Q $i',
            options: ['A', 'B'],
            correctIndex: 0, // Option 0 is always correct
            explanation: 'Exp',
          ));
        }
      }
      await db.batchInsertQuestions(pool);

      final session = await engine.startExam();
      final total = session.totalQuestions; // 47

      // Answer first 35 correctly (index 0), remaining 12 incorrectly (index 1) -> 35/47 = 74.47% (Pass)
      for (int i = 0; i < total; i++) {
        expect(session.currentQuestionIndex, i);
        final selected = (i < 35) ? 0 : 1;
        final ok = await engine.submitAnswer(session, selectedIndex: selected);
        expect(ok, isTrue);
      }

      expect(session.isFinished, isTrue);

      final result = await engine.completeExam(session, elapsedSecondsOverride: 2400);
      expect(result.totalQuestions, total);
      expect(result.score, 35);
      expect(result.percentage, closeTo(74.47, 0.1));
      expect(result.isPassed, isTrue); // >= 65% is passed

      // Verify all 8 domains appear in domain breakdown
      for (final domain in ExamConstants.part1DomainWeights.keys) {
        expect(result.domainBreakdown.containsKey(domain), isTrue, reason: 'Breakdown should include $domain');
      }

      final profile = await gamification.getProfile();
      // 100 XP for completion + 50 XP bonus for pass = 150 XP
      expect(profile.xp, 150);
      expect(profile.totalMockExamsTaken, 1);
    });
  });
}

