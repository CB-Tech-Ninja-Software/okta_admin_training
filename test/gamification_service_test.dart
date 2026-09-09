import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:directory_dash/core/database/app_database.dart';
import 'package:directory_dash/core/models/question.dart';
import 'package:directory_dash/core/models/question_attempt.dart';
import 'package:directory_dash/core/services/gamification_service.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('GamificationService Tests', () {
    late AppDatabase db;
    late GamificationService service;

    setUp(() async {
      db = AppDatabase.instance;
      final inMemoryDb = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      await db.init(dbOverride: inMemoryDb);
      service = GamificationService(db: db);
    });

    tearDown(() async {
      await db.close();
    });

    test('XP awards and level progression', () async {
      var profile = await service.getProfile();
      expect(profile.xp, 0);
      expect(profile.level, 1);

      profile = await service.awardXp(50);
      expect(profile.xp, 50);
      expect(profile.level, 1);

      profile = await service.awardXp(60);
      expect(profile.xp, 110);
      expect(profile.level, 2); // 110 XP -> Level 2
    });

    test('Active streak calculation across dates', () async {
      final day1 = DateTime(2026, 8, 29);
      final day2 = DateTime(2026, 8, 30);
      final day3 = DateTime(2026, 8, 31);
      final day5 = DateTime(2026, 9, 2); // 1 day gap

      var profile = await service.recordActivity(nowOverride: day1);
      expect(profile.streakDays, 1);
      expect(profile.lastActiveDate, '2026-08-29');

      // Same day activity doesn't double-increment
      profile = await service.recordActivity(nowOverride: day1);
      expect(profile.streakDays, 1);

      // Day 2 (consecutive)
      profile = await service.recordActivity(nowOverride: day2);
      expect(profile.streakDays, 2);
      expect(profile.lastActiveDate, '2026-08-30');

      // Day 3 (consecutive) -> unlocks streak_warrior badge!
      profile = await service.recordActivity(nowOverride: day3);
      expect(profile.streakDays, 3);
      expect(profile.unlockedBadgeIds.contains('streak_warrior'), isTrue);

      // Day 5 (broken streak) -> resets to 1
      profile = await service.recordActivity(nowOverride: day5);
      expect(profile.streakDays, 1);
      expect(profile.lastActiveDate, '2026-09-02');
    });

    test('Badge unlock for domain mastery', () async {
      // Create 10 questions for an OKCON1 domain
      const testDomain = 'Implementing Advanced Sourcing';
      final questions = List.generate(
        10,
        (i) => Question(
          id: 'q_sourcing_$i',
          part: 'I',
          domain: testDomain,
          question: 'Q',
          options: ['A', 'B'],
          correctIndex: 0,
          explanation: 'Exp',
        ),
      );
      await db.batchInsertQuestions(questions);

      // Record 10 successful attempts (100% accuracy)
      for (final q in questions) {
        await db.recordAttempt(QuestionAttempt(
          questionId: q.id,
          selectedIndex: 0,
          isCorrect: true,
          attemptedAt: DateTime.now(),
          mode: 'quiz',
        ));
      }

      final profile = await service.getProfile();
      final awarded = await service.checkAndAwardBadges(profile);

      expect(awarded.any((b) => b.id == 'domain_master'), isTrue);
      final updatedProfile = await service.getProfile();
      expect(updatedProfile.unlockedBadgeIds.contains('domain_master'), isTrue);
    });
  });
}
