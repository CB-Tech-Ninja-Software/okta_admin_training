import 'package:flutter_test/flutter_test.dart';
import 'package:directory_dash/core/models/question.dart';
import 'package:directory_dash/core/models/flashcard.dart';
import 'package:directory_dash/core/models/scenario.dart';
import 'package:directory_dash/core/models/mock_exam.dart';
import 'package:directory_dash/core/models/user_profile.dart';

void main() {
  group('Question Model Tests', () {
    test('serialization and deserialization from JSON and Map', () {
      final json = {
        'id': 'q_test_1',
        'part': 'I',
        'domain': 'Active Directory Integration',
        'subtopic': 'Delegated Auth',
        'question': 'Test Question?',
        'options': ['Opt A', 'Opt B', 'Opt C', 'Opt D'],
        'correctIndex': 1,
        'explanation': 'Opt B is correct because test.',
      };

      final q = Question.fromJson(json);
      expect(q.id, 'q_test_1');
      expect(q.part, 'I');
      expect(q.domain, 'Active Directory Integration');
      expect(q.options.length, 4);
      expect(q.correctIndex, 1);
      expect(q.isCorrect(1), isTrue);
      expect(q.isCorrect(0), isFalse);

      final map = q.toMap();
      final qFromMap = Question.fromMap(map);
      expect(qFromMap.id, q.id);
      expect(qFromMap.options, q.options);
      expect(qFromMap.correctIndex, 1);
    });
  });

  group('Flashcard Model Tests', () {
    test('Leitner box progression logic', () {
      final card = Flashcard(
        id: 'fc_1',
        domain: 'Active Directory Integration',
        front: 'Term',
        back: 'Def',
        bucket: 1,
      );

      // Pass increments bucket
      final cardBox2 = card.copyWithReview(isCorrect: true);
      expect(cardBox2.bucket, 2);
      expect(cardBox2.reviewCount, 1);
      expect(cardBox2.correctCount, 1);

      final cardBox3 = cardBox2.copyWithReview(isCorrect: true);
      expect(cardBox3.bucket, 3);
      expect(cardBox3.reviewCount, 2);
      expect(cardBox3.correctCount, 2);

      // Capped at 3
      final cardBox3Max = cardBox3.copyWithReview(isCorrect: true);
      expect(cardBox3Max.bucket, 3);

      // Fail resets to Box 1
      final cardReset = cardBox3.copyWithReview(isCorrect: false);
      expect(cardReset.bucket, 1);
      expect(cardReset.reviewCount, 3);
      expect(cardReset.correctCount, 2);
    });
  });

  group('Scenario Model Tests', () {
    test('serialization and deserialization', () {
      final scenario = Scenario(
        id: 'sc_1',
        domain: 'Device Assurance',
        useCaseNumber: 3,
        title: 'Device Test',
        scenarioText: 'Scenario Details',
        question: 'What do you do next?',
        options: ['Choice 1', 'Choice 2'],
        correctIndex: 0,
        explanation: 'Choice 1 is correct.',
      );

      final map = scenario.toMap();
      final fromMap = Scenario.fromMap(map);
      expect(fromMap.id, 'sc_1');
      expect(fromMap.useCaseNumber, 3);
      expect(fromMap.options.length, 2);
      expect(fromMap.correctIndex, 0);
    });
  });

  group('MockExam Model Tests', () {
    test('DomainScore and MockExamResult serialization', () {
      final breakdown = {
        'Active Directory Integration': const DomainScore(
          domain: 'Active Directory Integration',
          totalQuestions: 7,
          correctAnswers: 6,
          percentage: 85.71,
        ),
      };

      final result = MockExamResult(
        id: 'mock_1',
        startedAt: DateTime.fromMillisecondsSinceEpoch(1000000),
        completedAt: DateTime.fromMillisecondsSinceEpoch(1001000),
        timeSpentSeconds: 1000,
        totalQuestions: 15,
        score: 12,
        percentage: 80.0,
        isPassed: true,
        domainBreakdown: breakdown,
        questionIds: ['q1', 'q2'],
        userAnswers: {'q1': 0, 'q2': 1},
      );

      final map = result.toMap();
      final fromMap = MockExamResult.fromMap(map);

      expect(fromMap.id, 'mock_1');
      expect(fromMap.score, 12);
      expect(fromMap.isPassed, isTrue);
      expect(fromMap.domainBreakdown['Active Directory Integration']?.correctAnswers, 6);
      expect(fromMap.userAnswers['q1'], 0);
    });
  });

  group('UserProfile Model Tests', () {
    test('XP level calculation and progress', () {
      expect(UserProfile.calculateLevel(0), 1);
      expect(UserProfile.calculateLevel(99), 1);
      expect(UserProfile.calculateLevel(100), 2);
      expect(UserProfile.calculateLevel(250), 3);

      const profile = UserProfile(xp: 250, level: 3);
      expect(profile.currentLevelXpProgress, 50);
      expect(profile.currentLevelProgressFraction, 0.5);
    });
  });
}
