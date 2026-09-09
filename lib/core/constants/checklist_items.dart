class ChecklistItem {
  final String id;
  final String title;
  final String detail;

  const ChecklistItem({required this.id, required this.title, required this.detail});
}

class ChecklistItems {
  static const List<ChecklistItem> items = [
    ChecklistItem(
      id: 'guardian_browser',
      title: 'Guardian Browser installed',
      detail: 'Download and install it before exam day — it is required to launch the exam.',
    ),
    ChecklistItem(
      id: 'equipment_test',
      title: 'Equipment test run',
      detail: 'Run the ProctorU equipment test in the same room/setup you\'ll use for the exam.',
    ),
    ChecklistItem(
      id: 'login_memorized',
      title: 'Login memorized or written down',
      detail: 'Password managers and autofill do not work inside Guardian — have your credential '
          'manager login memorized or written on paper you can read (not type from).',
    ),
    ChecklistItem(
      id: 'admin_access',
      title: 'Administrative access to your computer',
      detail: 'Guardian needs admin rights on the machine to run its checks.',
    ),
    ChecklistItem(
      id: 'okta_verify',
      title: 'Okta Verify installed & phone charged',
      detail: 'At least one Part II task requires Okta Verify live on your phone. Charge it and keep it nearby.',
    ),
    ChecklistItem(
      id: 'network_check',
      title: 'Network/port requirements reviewed',
      detail: 'Confirm your network doesn\'t block anything Guardian or the proctor session needs.',
    ),
    ChecklistItem(
      id: 'same_room',
      title: 'Testing in the actual exam room/setup',
      detail: 'Use the same room, desk, and lighting you tested with — don\'t improvise on exam day.',
    ),
    ChecklistItem(
      id: 'order_confirmed',
      title: 'Exam order details confirmed',
      detail: 'Double-check your order confirmation email for the exact date, time, and reserved '
          'duration once the exam is booked.',
    ),
  ];
}
