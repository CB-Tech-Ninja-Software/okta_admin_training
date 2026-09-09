/// Represents an unlockable gamification badge.
class AppBadge {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final String category; // 'domain', 'streak', 'exam', 'level'

  const AppBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.category,
  });

  static const List<AppBadge> predefinedBadges = [
    AppBadge(
      id: 'domain_master',
      title: 'Domain Master',
      description: 'Achieve 90%+ accuracy on any domain with at least 10 attempts.',
      iconName: 'folder_shared',
      category: 'domain',
    ),
    AppBadge(
      id: 'mock_champion',
      title: 'Mock Champion',
      description: 'Pass a full 47-question Mock Exam under the 75-minute time limit.',
      iconName: 'emoji_events',
      category: 'exam',
    ),
    AppBadge(
      id: 'streak_warrior',
      title: 'Streak Warrior',
      description: 'Maintain a 3-day active study streak.',
      iconName: 'local_fire_department',
      category: 'streak',
    ),
    AppBadge(
      id: 'directory_legend',
      title: 'Directory Legend',
      description: 'Reach Level 5 in Directory Dash (500+ XP).',
      iconName: 'military_tech',
      category: 'level',
    ),
    AppBadge(
      id: 'flashcard_fiend',
      title: 'Flashcard Fiend',
      description: 'Review 25 flashcards across any domain.',
      iconName: 'style',
      category: 'study',
    ),
  ];
}
