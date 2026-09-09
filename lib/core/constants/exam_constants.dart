/// Constants for the Okta Certified Consultant (OKCON1) Exam Study App.
class ExamConstants {
  // Exam Identification & Logistics
  static const String examTitle = 'Okta Certified Consultant Hands-On Configuration Exam';
  static const String examCode = 'OKCON1';
  static const String? targetExamDateIso = null;

  // Part I Domains & Weights
  static const String domainAdvancedSourcing = 'Implementing Advanced Sourcing';
  static const String domainAdvancedSso = 'Implementing Advanced SSO Strategies';
  static const String domainCustomConfiguration = 'Implementing Custom Configuration Options with Okta';
  static const String domainDirectorySolutions = 'Implementing Directory Solutions';
  static const String domainInboundFederation = 'Implementing Inbound Federation with Okta';
  static const String domainOktaPolicies = 'Implementing Okta Policies';
  static const String domainOktaApis = 'Working with Okta APIs';
  static const String domainApiAccessManagement = 'Working with API Access Management';

  static const double weightAdvancedSourcing = 0.08;
  static const double weightAdvancedSso = 0.15;
  static const double weightCustomConfiguration = 0.19;
  static const double weightDirectorySolutions = 0.13;
  static const double weightInboundFederation = 0.13;
  static const double weightOktaPolicies = 0.15;
  static const double weightOktaApis = 0.06;
  static const double weightApiAccessManagement = 0.11;

  static const Map<String, double> part1DomainWeights = {
    domainAdvancedSourcing: weightAdvancedSourcing,
    domainAdvancedSso: weightAdvancedSso,
    domainCustomConfiguration: weightCustomConfiguration,
    domainDirectorySolutions: weightDirectorySolutions,
    domainInboundFederation: weightInboundFederation,
    domainOktaPolicies: weightOktaPolicies,
    domainOktaApis: weightOktaApis,
    domainApiAccessManagement: weightApiAccessManagement,
  };

  // Part II Use Cases & Weights
  static const String useCaseAppIntegrations = 'App Integrations';
  static const String useCaseCustomAdmin = 'Creating a Custom Admin';
  static const String useCaseConfiguringPolicies = 'Configuring Policies';
  static const String useCaseRoutingRules = 'Creating Routing Rules';

  static const double weightAppIntegrations = 0.25;
  static const double weightCustomAdmin = 0.25;
  static const double weightConfiguringPolicies = 0.25;
  static const double weightRoutingRules = 0.25;

  static const Map<String, double> part2DomainWeights = {
    useCaseAppIntegrations: weightAppIntegrations,
    useCaseCustomAdmin: weightCustomAdmin,
    useCaseConfiguringPolicies: weightConfiguringPolicies,
    useCaseRoutingRules: weightRoutingRules,
  };

  // All Domains
  static const List<String> allDomains = [
    domainAdvancedSourcing,
    domainAdvancedSso,
    domainCustomConfiguration,
    domainDirectorySolutions,
    domainInboundFederation,
    domainOktaPolicies,
    domainOktaApis,
    domainApiAccessManagement,
    useCaseAppIntegrations,
    useCaseCustomAdmin,
    useCaseConfiguringPolicies,
    useCaseRoutingRules,
  ];

  // Legacy OKADM2 domain aliases (deprecated, kept for backwards compatibility)
  @Deprecated('Legacy OKADM2 domain')
  static const String domainActiveDirectory = 'Active Directory Integration';
  @Deprecated('Legacy OKADM2 domain')
  static const String domainProfilesSourcing = 'Profiles, Sourcing & Write-Back Concepts';
  @Deprecated('Legacy OKADM2 use case')
  static const String domainCustomAppIntegration = 'Custom Application Integration';
  @Deprecated('Legacy OKADM2 use case')
  static const String domainBehaviorDetection = 'Behavior Detection';
  @Deprecated('Legacy OKADM2 use case')
  static const String domainDeviceAssurance = 'Device Assurance';
  @Deprecated('Legacy OKADM2 use case')
  static const String domainMonitoringTroubleshooting = 'Monitoring & Troubleshooting';

  // Mock Exam Specifications
  static const int mockExamQuestionCount = 47;
  static const int mockExamTimeLimitSeconds = 4500; // 75 minutes (4500s)
  static const double mockExamPassingScorePercentage = 65.0; // 65% passing threshold

  // Spaced Repetition (Leitner Box) Configuration
  static const int leitnerMinBox = 1;
  static const int leitnerMaxBox = 3;
  static const String box1Label = 'Still Shaky';
  static const String box2Label = 'Reviewing';
  static const String box3Label = 'Mastered';

  // Selection probability weights for Leitner boxes
  static const double box1SelectionWeight = 0.60;
  static const double box2SelectionWeight = 0.30;
  static const double box3SelectionWeight = 0.10;

  // Gamification XP Rewards
  static const int xpQuestionCorrect = 10;
  static const int xpFlashcardReviewed = 5;
  static const int xpScenarioCompleted = 25;
  static const int xpMockExamCompleted = 100;
  static const int xpMockExamPassedBonus = 50;
  static const int xpPerLevel = 100; // 100 XP per level
}

