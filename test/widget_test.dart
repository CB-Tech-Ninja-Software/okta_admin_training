import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:directory_dash/core/models/user_profile.dart';
import 'package:directory_dash/main.dart';

void main() {
  testWidgets('Directory Dash HomeScreen smoke test', (WidgetTester tester) async {
    // Set standard mobile device viewport size (1080 x 2400)
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const DirectoryDashApp(
        homeOverride: HomeScreen(
          initialLoading: false,
          initialProfile: UserProfile(
            streakDays: 3,
            level: 2,
            xp: 150,
          ),
          initialQuestionCount: 15,
          initialFlashcardCount: 10,
          initialScenarioCount: 4,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Directory Dash'), findsOneWidget);
    expect(find.text('3d streak'), findsOneWidget);
    expect(find.text('Lvl 2 (150 XP)'), findsOneWidget);
    expect(find.text('Study Modes'), findsOneWidget);
    expect(find.text('Weighted Quiz Mode'), findsOneWidget);
    expect(find.text('Flashcards & Spaced Repetition'), findsOneWidget);
    expect(find.text('Part I Mock Exam'), findsOneWidget);
    expect(find.text('Part II Scenario Walkthroughs'), findsOneWidget);
  });
}
