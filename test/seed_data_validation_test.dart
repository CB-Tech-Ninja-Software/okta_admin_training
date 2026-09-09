import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:directory_dash/core/constants/exam_constants.dart';
import 'package:directory_dash/core/database/app_database.dart';
import 'package:directory_dash/core/database/seed_importer.dart';
import 'package:directory_dash/core/services/question_engine.dart';
import 'package:directory_dash/core/services/spaced_repetition_engine.dart';
import 'package:directory_dash/core/services/mock_exam_engine.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Seed Data Validation & Scale Tests', () {
    late AppDatabase db;

    setUp(() async {
      db = AppDatabase.instance;
      final inMemoryDb = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      await db.init(dbOverride: inMemoryDb);
    });

    tearDown(() async {
      await db.close();
    });

    test('Validates and loads live assets/data files into SQLite without hardcoded count limits', () async {
      final questionsFile = File('assets/data/questions.json');
      final flashcardsFile = File('assets/data/flashcards.json');
      final scenariosFile = File('assets/data/scenarios.json');
      final referenceNotesFile = File('assets/data/reference_notes.json');

      expect(questionsFile.existsSync(), isTrue);
      expect(flashcardsFile.existsSync(), isTrue);
      expect(scenariosFile.existsSync(), isTrue);
      expect(referenceNotesFile.existsSync(), isTrue);

      final qJson = await questionsFile.readAsString();
      final fcJson = await flashcardsFile.readAsString();
      final scJson = await scenariosFile.readAsString();
      final rnJson = await referenceNotesFile.readAsString();

      final importer = SeedImporter(db: db);
      final summary = await importer.seedFromAssets(
        forceReload: true,
        questionsJsonOverride: qJson,
        flashcardsJsonOverride: fcJson,
        scenariosJsonOverride: scJson,
        referenceNotesJsonOverride: rnJson,
      );

      // Verify minimum expected baseline counts (allows Creed to scale to 150+ without test breakage)
      expect(summary.questionsCount, greaterThanOrEqualTo(70));
      expect(summary.flashcardsCount, greaterThanOrEqualTo(45));
      expect(summary.scenariosCount, greaterThanOrEqualTo(8));
      expect(summary.referenceNotesCount, greaterThanOrEqualTo(9));

      // Validate Questions Integrity
      final allQ = await db.getAllQuestions();
      expect(allQ.length, summary.questionsCount);
      for (final q in allQ) {
        expect(q.id.isNotEmpty, isTrue);
        expect(q.question.isNotEmpty, isTrue);
        expect(q.options.length, 4);
        expect(q.correctIndex, inInclusiveRange(0, 3));
        expect(q.explanation.isNotEmpty, isTrue);
      }

      // Validate Flashcards Integrity
      final allFc = await db.getAllFlashcards();
      expect(allFc.length, summary.flashcardsCount);
      for (final fc in allFc) {
        expect(fc.id.isNotEmpty, isTrue);
        expect(fc.front.isNotEmpty, isTrue);
        expect(fc.back.isNotEmpty, isTrue);
        expect(fc.bucket, inInclusiveRange(1, 3));
      }

      // Validate Scenarios Integrity
      final allSc = await db.getAllScenarios();
      expect(allSc.length, summary.scenariosCount);
      for (final sc in allSc) {
        expect(sc.id.isNotEmpty, isTrue);
        expect(sc.title.isNotEmpty, isTrue);
        expect(sc.scenarioText.isNotEmpty, isTrue);
        expect(sc.useCaseNumber, inInclusiveRange(1, 4));
        expect(sc.options.length, greaterThanOrEqualTo(2));
        expect(sc.correctIndex, inInclusiveRange(0, sc.options.length - 1));
      }

      // Validate Reference Notes Integrity
      final allNotes = await db.getAllReferenceNotes();
      expect(allNotes.length, summary.referenceNotesCount);
      for (final note in allNotes) {
        expect(note.id.isNotEmpty, isTrue);
        expect(note.domain.isNotEmpty, isTrue);
        expect(note.topic.isNotEmpty, isTrue);
        expect(note.title.isNotEmpty, isTrue);
        expect(note.body.isNotEmpty, isTrue);
      }

      // Test Reference Notes filtering & bookmarking
      final firstNote = allNotes.first;
      final domainNotes = await db.getAllReferenceNotes(domain: firstNote.domain);
      expect(domainNotes.isNotEmpty, isTrue);

      expect(firstNote.bookmarked, isFalse);

      await db.toggleReferenceNoteBookmark(firstNote.id, true);
      final bookmarkedNotes = await db.getAllReferenceNotes(bookmarkedOnly: true);
      expect(bookmarkedNotes.length, 1);
      expect(bookmarkedNotes.first.id, firstNote.id);

      await db.markReferenceNoteAsRead(firstNote.id);
      final readNote = await db.getReferenceNoteById(firstNote.id);
      expect(readNote?.lastReadAt, isNotNull);

      // Test QuestionEngine scales properly on dataset
      final qEngine = QuestionEngine(db: db);
      final quiz10 = await qEngine.pickWeightedQuestions(count: 10, part: 'I');
      expect(quiz10.length, 10);

      // Test MockExamEngine pulls exact mockExamQuestionCount (47) even on large datasets
      final mockEngine = MockExamEngine(db: db);
      final session = await mockEngine.startExam();
      expect(session.totalQuestions, ExamConstants.mockExamQuestionCount);
      expect(session.questions.length, ExamConstants.mockExamQuestionCount);

      // Test SpacedRepetitionEngine scales properly
      final srEngine = SpacedRepetitionEngine(db: db);
      final cards = await srEngine.pickFlashcardsForReview(count: 15);
      expect(cards.length, 15);
    });
  });
}
