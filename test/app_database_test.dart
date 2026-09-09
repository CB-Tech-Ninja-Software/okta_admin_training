import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:directory_dash/core/database/app_database.dart';
import 'package:directory_dash/core/database/seed_importer.dart';
import 'package:directory_dash/core/models/question.dart';
import 'package:directory_dash/core/models/flashcard.dart';
import 'package:directory_dash/core/models/scenario.dart';
import 'package:directory_dash/core/models/question_attempt.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('AppDatabase and SeedImporter Tests', () {
    late AppDatabase db;

    setUp(() async {
      db = AppDatabase.instance;
      final inMemoryDb = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      await db.init(dbOverride: inMemoryDb);
    });

    tearDown(() async {
      await db.close();
    });

    test('Questions CRUD and querying', () async {
      final q1 = Question(
        id: 'q1',
        part: 'I',
        domain: 'Active Directory Integration',
        question: 'AD Q1',
        options: ['A', 'B'],
        correctIndex: 0,
        explanation: 'Exp 1',
      );
      final q2 = Question(
        id: 'q2',
        part: 'I',
        domain: 'Profiles, Sourcing & Write-Back Concepts',
        question: 'Profiles Q2',
        options: ['A', 'B'],
        correctIndex: 1,
        explanation: 'Exp 2',
      );

      await db.batchInsertQuestions([q1, q2]);

      final allQuestions = await db.getAllQuestions();
      expect(allQuestions.length, 2);

      final adQuestions = await db.getAllQuestions(domain: 'Active Directory Integration');
      expect(adQuestions.length, 1);
      expect(adQuestions.first.id, 'q1');

      final queriedQ1 = await db.getQuestionById('q1');
      expect(queriedQ1, isNotNull);
      expect(queriedQ1!.question, 'AD Q1');
    });

    test('Flashcards CRUD and querying', () async {
      final fc1 = Flashcard(
        id: 'fc1',
        domain: 'Active Directory Integration',
        front: 'Front 1',
        back: 'Back 1',
        bucket: 1,
      );

      await db.batchInsertFlashcards([fc1]);

      final allCards = await db.getAllFlashcards();
      expect(allCards.length, 1);
      expect(allCards.first.bucket, 1);

      final updated = fc1.copyWithReview(isCorrect: true);
      await db.updateFlashcard(updated);

      final cardsAfterUpdate = await db.getAllFlashcards();
      expect(cardsAfterUpdate.first.bucket, 2);
    });

    test('Scenarios CRUD and querying', () async {
      final sc1 = Scenario(
        id: 'sc1',
        domain: 'Custom Application Integration',
        useCaseNumber: 1,
        title: 'Use Case 1',
        scenarioText: 'Scenario Details',
        question: 'Next step?',
        options: ['A', 'B'],
        correctIndex: 0,
        explanation: 'Exp',
      );

      await db.batchInsertScenarios([sc1]);

      final scenarios = await db.getAllScenarios(useCaseNumber: 1);
      expect(scenarios.length, 1);
      expect(scenarios.first.title, 'Use Case 1');
    });

    test('Question attempts and domain stats calculation', () async {
      final q1 = Question(
        id: 'q1',
        part: 'I',
        domain: 'Active Directory Integration',
        question: 'AD Q1',
        options: ['A', 'B'],
        correctIndex: 0,
        explanation: 'Exp 1',
      );
      await db.batchInsertQuestions([q1]);

      final a1 = QuestionAttempt(
        questionId: 'q1',
        selectedIndex: 0,
        isCorrect: true,
        attemptedAt: DateTime.now(),
        mode: 'quiz',
      );
      final a2 = QuestionAttempt(
        questionId: 'q1',
        selectedIndex: 1,
        isCorrect: false,
        attemptedAt: DateTime.now(),
        mode: 'quiz',
      );

      await db.recordAttempt(a1);
      await db.recordAttempt(a2);

      final stats = await db.getDomainStats();
      expect(stats.containsKey('Active Directory Integration'), isTrue);
      expect(stats['Active Directory Integration']!['total'], 2);
      expect(stats['Active Directory Integration']!['correct'], 1);
      expect(stats['Active Directory Integration']!['accuracy'], 50.0);
    });

    test('SeedImporter populates tables from JSON overrides', () async {
      final importer = SeedImporter(db: db);
      final summary = await importer.seedFromAssets(
        questionsJsonOverride: '''
        [
          {
            "id": "q_override_1",
            "part": "I",
            "domain": "Active Directory Integration",
            "question": "Import test?",
            "options": ["A", "B"],
            "correctIndex": 0,
            "explanation": "Exp"
          }
        ]
        ''',
        flashcardsJsonOverride: '''
        [
          {
            "id": "fc_override_1",
            "domain": "Active Directory Integration",
            "front": "Front",
            "back": "Back"
          }
        ]
        ''',
        scenariosJsonOverride: '''
        [
          {
            "id": "sc_override_1",
            "domain": "Custom Application Integration",
            "useCaseNumber": 1,
            "title": "Title",
            "scenarioText": "Text",
            "question": "Question",
            "options": ["A", "B"],
            "correctIndex": 0,
            "explanation": "Exp"
          }
        ]
        ''',
      );

      expect(summary.questionsCount, 1);
      expect(summary.flashcardsCount, 1);
      expect(summary.scenariosCount, 1);
      expect(await db.isSeeded(), isTrue);

      final questions = await db.getAllQuestions();
      expect(questions.length, 1);
      expect(questions.first.id, 'q_override_1');
    });
  });
}
