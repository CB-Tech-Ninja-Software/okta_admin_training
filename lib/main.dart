import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:directory_dash/core/constants/exam_constants.dart';
import 'package:directory_dash/core/database/app_database.dart';
import 'package:directory_dash/core/database/seed_importer.dart';
import 'package:directory_dash/core/models/user_profile.dart';
import 'package:directory_dash/core/services/gamification_service.dart';
import 'package:directory_dash/screens/checklist_screen.dart';
import 'package:directory_dash/screens/flashcard_screen.dart';
import 'package:directory_dash/screens/mock_exam_screen.dart';
import 'package:directory_dash/screens/progress_screen.dart';
import 'package:directory_dash/screens/quiz_screen.dart';
import 'package:directory_dash/screens/reference_screen.dart';
import 'package:directory_dash/screens/scenario_screen.dart';
import 'package:directory_dash/theme/app_theme.dart';
import 'package:directory_dash/widgets/exam_countdown.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Desktop platforms (Windows/Linux) have no sqflite plugin implementation;
  // route through sqflite_common_ffi's native SQLite binding instead.
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Initialize local SQLite database and seed initial JSON assets
  final db = AppDatabase.instance;
  await db.init();
  final importer = SeedImporter(db: db);
  await importer.seedFromAssets();

  runApp(const DirectoryDashApp());
}

class DirectoryDashApp extends StatelessWidget {
  final Widget? homeOverride;

  const DirectoryDashApp({super.key, this.homeOverride});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Directory Dash',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      home: homeOverride ?? const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final bool? initialLoading;
  final UserProfile? initialProfile;
  final int? initialQuestionCount;
  final int? initialFlashcardCount;
  final int? initialScenarioCount;

  const HomeScreen({
    super.key,
    this.initialLoading,
    this.initialProfile,
    this.initialQuestionCount,
    this.initialFlashcardCount,
    this.initialScenarioCount,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late UserProfile _profile;
  late int _questionCount;
  late int _flashcardCount;
  late int _scenarioCount;
  late bool _isLoading;

  @override
  void initState() {
    super.initState();
    _profile = widget.initialProfile ?? const UserProfile();
    _questionCount = widget.initialQuestionCount ?? 0;
    _flashcardCount = widget.initialFlashcardCount ?? 0;
    _scenarioCount = widget.initialScenarioCount ?? 0;
    _isLoading = widget.initialLoading ?? true;

    if (widget.initialLoading == null) {
      _loadData();
    }
  }

  String get _targetExamDateLabel {
    final str = ExamConstants.targetExamDateIso;
    if (str == null || str.isEmpty) return 'Not scheduled';
    final date = DateTime.tryParse(str);
    if (date == null) return 'Not scheduled';
    return '${date.month}/${date.day}/${date.year}';
  }

  Future<void> _loadData() async {
    final db = AppDatabase.instance;
    final gamification = GamificationService(db: db);

    final profile = await gamification.getProfile();
    final questions = await db.getAllQuestions();
    final flashcards = await db.getAllFlashcards();
    final scenarios = await db.getAllScenarios();

    if (mounted) {
      setState(() {
        _profile = profile;
        _questionCount = questions.length;
        _flashcardCount = flashcards.length;
        _scenarioCount = scenarios.length;
        _isLoading = false;
      });
    }
  }

  Future<void> _openMode(Widget screen) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Directory Dash'),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Icon(Icons.local_fire_department, color: Colors.orange),
                const SizedBox(width: 4),
                Text(
                  '${_profile.streakDays}d streak',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.stars, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  'Lvl ${_profile.level} (${_profile.xp} XP)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + AppTheme.safeBottomInset(context)),
                children: [
                  const ExamCountdown(),
                  const SizedBox(height: 16),

                  // Header Card with Exam Countdown
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.school, size: 28, color: Color(0xFF007DC1)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      ExamConstants.examTitle,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Exam Code: ${ExamConstants.examCode} • Target: $_targetExamDateLabel',
                                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem('Questions', '$_questionCount'),
                              _buildStatItem('Flashcards', '$_flashcardCount'),
                              _buildStatItem('Scenarios', '$_scenarioCount'),
                              _buildStatItem('Mock Exams', '${_profile.totalMockExamsTaken}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Study Modes
                  const Text(
                    'Study Modes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  _buildModeCard(
                    title: 'Weighted Quiz Mode',
                    subtitle: 'Domain-weighted questions across all Part I domains',
                    icon: Icons.quiz,
                    color: Colors.blue,
                    onTap: () => _openMode(const QuizScreen()),
                  ),
                  const SizedBox(height: 8),

                  _buildModeCard(
                    title: 'Flashcards & Spaced Repetition',
                    subtitle: 'Leitner 3-box system prioritizing shaky concepts',
                    icon: Icons.style,
                    color: Colors.teal,
                    onTap: () => _openMode(const FlashcardScreen()),
                  ),
                  const SizedBox(height: 8),

                  _buildModeCard(
                    title: 'Part I Mock Exam',
                    subtitle: '${ExamConstants.mockExamQuestionCount} Questions • '
                        '${ExamConstants.mockExamTimeLimitSeconds ~/ 60} Min Timer • Hard Sequential Lock',
                    icon: Icons.timer,
                    color: Colors.deepPurple,
                    onTap: () => _openMode(const MockExamScreen()),
                  ),
                  const SizedBox(height: 8),

                  _buildModeCard(
                    title: 'Part II Scenario Walkthroughs',
                    subtitle: 'Use Case sequences & decision troubleshooting',
                    icon: Icons.alt_route,
                    color: Colors.indigo,
                    onTap: () => _openMode(const ScenarioListScreen()),
                  ),
                  const SizedBox(height: 8),

                  _buildModeCard(
                    title: 'Reference Library',
                    subtitle: 'Browsable summary notes by domain & topic',
                    icon: Icons.menu_book,
                    color: Colors.cyan,
                    onTap: () => _openMode(const ReferenceLibraryScreen()),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'You',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  _buildModeCard(
                    title: 'Progress Dashboard',
                    subtitle: 'Domain mastery, XP, streak & badges',
                    icon: Icons.bar_chart,
                    color: Colors.amber,
                    onTap: () => _openMode(const ProgressScreen()),
                  ),
                  const SizedBox(height: 8),

                  _buildModeCard(
                    title: 'Day-of-Exam Checklist',
                    subtitle: 'Guardian Browser, admin access, Okta Verify & more',
                    icon: Icons.checklist,
                    color: Colors.green,
                    onTap: () => _openMode(const ChecklistScreen()),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildModeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(35),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
