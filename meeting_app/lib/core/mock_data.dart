// ─────────────────────────────────────────────────────────────
// ECHOMIND — Mock Data Models and Provider
// ─────────────────────────────────────────────────────────────

class Participant {
  final String name;
  final String role;
  final String initials;

  const Participant({
    required this.name,
    required this.role,
    required this.initials,
  });
}

class ActionItem {
  final String assignedTo;
  final String description;
  final String dueDate;
  final bool isCompleted;

  const ActionItem({
    required this.assignedTo,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
  });
}

class TimelineEvent {
  final String label;
  final String time;
  final bool isCompleted;

  const TimelineEvent({
    required this.label,
    required this.time,
    this.isCompleted = true,
  });
}

class Meeting {
  final String id;
  final String title;
  final String date;
  final String time;
  final String duration;
  final String status; // completed, processing, transcribing, analyzing, uploaded
  final List<Participant> participants;
  final String executiveSummary;
  final List<String> keyMetrics;
  final List<ActionItem> actionItems;
  final List<String> decisions;
  final String transcriptSnippet;
  final List<TimelineEvent> timeline;

  const Meeting({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.duration,
    required this.status,
    required this.participants,
    required this.executiveSummary,
    required this.keyMetrics,
    required this.actionItems,
    required this.decisions,
    required this.transcriptSnippet,
    required this.timeline,
  });
}

class ChatMessageData {
  final String text;
  final bool isUser;
  final String time;

  const ChatMessageData({
    required this.text,
    required this.isUser,
    required this.time,
  });
}

// ─────────────────────────────────────────────────────────────
// MOCK DATA PROVIDER
// ─────────────────────────────────────────────────────────────

class MockDataProvider {
  static const String userName = 'Sujal Bandodkar';
  static const String userEmail = 'sujal.bandodkar@echomind.ai';
  static const String userInitials = 'SB';

  // ─── Meetings ────────────────────────────────────────────

  static final List<Meeting> meetings = [
    Meeting(
      id: 'm1',
      title: 'Product Strategy Meeting – Amul Dairy Platform',
      date: 'Apr 07, 2026',
      time: '3:00 PM',
      duration: '47 min',
      status: 'completed',
      participants: const [
        Participant(name: 'Jacob', role: 'Frontend', initials: 'JC'),
        Participant(name: 'Sarah', role: 'Backend', initials: 'SA'),
        Participant(name: 'Jeremy', role: 'Data Analytics', initials: 'JR'),
        Participant(name: 'Suraj', role: 'Research', initials: 'SU'),
      ],
      executiveSummary:
          'The meeting focused on building a new website for Amul Milk and Dairy Products and analyzing annual revenue data to generate insights that can improve sales strategy and online reach. The team aligned on development timelines and decided to pursue a data-driven approach for the platform launch.',
      keyMetrics: const [
        'Annual revenue dataset reviewed',
        'Dairy product sales distribution analyzed',
        'Online vs offline revenue ratio: 35:65',
        'Monthly product demand growth: +12%',
      ],
      actionItems: const [
        ActionItem(
          assignedTo: 'Jacob',
          description: 'Work on the front end of the Amul Milk and Dairy Products website.',
          dueDate: 'Apr 14, 2026',
        ),
        ActionItem(
          assignedTo: 'Sarah',
          description: 'Build backend APIs and support frontend integration.',
          dueDate: 'Apr 14, 2026',
        ),
        ActionItem(
          assignedTo: 'Jeremy',
          description: 'Analyze annual revenue data and generate interactive plots.',
          dueDate: 'Apr 15, 2026',
        ),
        ActionItem(
          assignedTo: 'Suraj',
          description: 'Research competitive dairy brands and pricing models.',
          dueDate: 'Apr 16, 2026',
        ),
      ],
      decisions: const [
        'Build a new website for Amul Dairy Products.',
        'Analyze revenue data for strategic insights.',
        'Conduct follow-up meeting on April 17.',
        'Use React + Node.js stack for the platform.',
      ],
      transcriptSnippet:
          'Jacob: I think we should focus on the landing page first, then move on to the product catalog...\nSarah: Agreed. I can have the APIs ready by Thursday...',
      timeline: const [
        TimelineEvent(label: 'Transcribing', time: 'Apr 7, 3:11 PM'),
        TimelineEvent(label: 'Analyzing', time: 'Apr 7, 3:12 PM'),
        TimelineEvent(label: 'Completed', time: 'Apr 7, 3:12 PM'),
      ],
    ),
    Meeting(
      id: 'm2',
      title: 'Q1 Revenue Review – Finance Team',
      date: 'Apr 05, 2026',
      time: '11:00 AM',
      duration: '32 min',
      status: 'completed',
      participants: const [
        Participant(name: 'Ananya', role: 'CFO', initials: 'AN'),
        Participant(name: 'Rohan', role: 'Finance Lead', initials: 'RH'),
        Participant(name: 'Priya', role: 'Analyst', initials: 'PR'),
      ],
      executiveSummary:
          'Reviewed Q1 financial performance. Total revenue exceeded projections by 8%. The team identified key growth drivers in the dairy premium segment and flagged supply chain costs as a concern for Q2.',
      keyMetrics: const [
        'Q1 Revenue: ₹42.3 Cr (vs ₹39.1 Cr target)',
        'Gross margin: 34.2%',
        'Operating expenses up 5.1%',
        'Premium segment growth: +22%',
      ],
      actionItems: const [
        ActionItem(
          assignedTo: 'Rohan',
          description: 'Prepare Q2 budget forecast with adjusted cost projections.',
          dueDate: 'Apr 12, 2026',
        ),
        ActionItem(
          assignedTo: 'Priya',
          description: 'Build revenue breakdown dashboard for leadership.',
          dueDate: 'Apr 10, 2026',
        ),
      ],
      decisions: const [
        'Allocate 15% more budget to premium product marketing.',
        'Schedule quarterly supply chain review.',
        'Present Q1 results to board on April 20.',
      ],
      transcriptSnippet:
          'Ananya: The premium dairy line is outperforming expectations. Let us double down on marketing...',
      timeline: const [
        TimelineEvent(label: 'Transcribing', time: 'Apr 5, 11:35 AM'),
        TimelineEvent(label: 'Analyzing', time: 'Apr 5, 11:36 AM'),
        TimelineEvent(label: 'Completed', time: 'Apr 5, 11:36 AM'),
      ],
    ),
    Meeting(
      id: 'm3',
      title: 'Sprint 14 Retrospective – Engineering',
      date: 'Apr 03, 2026',
      time: '2:30 PM',
      duration: '28 min',
      status: 'completed',
      participants: const [
        Participant(name: 'Dev', role: 'Tech Lead', initials: 'DV'),
        Participant(name: 'Aarav', role: 'iOS Developer', initials: 'AR'),
        Participant(name: 'Meera', role: 'QA Engineer', initials: 'MR'),
        Participant(name: 'Kiran', role: 'DevOps', initials: 'KR'),
      ],
      executiveSummary:
          'Sprint 14 completed with 89% velocity. Two critical bugs were resolved. Team discussed improving automated test coverage and reducing deployment pipeline times.',
      keyMetrics: const [
        'Sprint velocity: 89%',
        'Bugs resolved: 12 (2 critical)',
        'Test coverage: 72% → 78%',
        'Deployment time: 18 min avg',
      ],
      actionItems: const [
        ActionItem(
          assignedTo: 'Meera',
          description: 'Increase unit test coverage to 85% by sprint end.',
          dueDate: 'Apr 17, 2026',
        ),
        ActionItem(
          assignedTo: 'Kiran',
          description: 'Optimize CI/CD pipeline to reduce build times by 30%.',
          dueDate: 'Apr 14, 2026',
        ),
      ],
      decisions: const [
        'Adopt trunk-based development for faster iterations.',
        'Introduce automated performance testing.',
      ],
      transcriptSnippet:
          'Dev: Overall a solid sprint. The payment gateway fix was a priority, glad it shipped on time...',
      timeline: const [
        TimelineEvent(label: 'Transcribing', time: 'Apr 3, 3:00 PM'),
        TimelineEvent(label: 'Analyzing', time: 'Apr 3, 3:01 PM'),
        TimelineEvent(label: 'Completed', time: 'Apr 3, 3:01 PM'),
      ],
    ),
    Meeting(
      id: 'm4',
      title: 'Design Review – Mobile App v2.0',
      date: 'Apr 09, 2026',
      time: '10:00 AM',
      duration: '15 min',
      status: 'transcribing',
      participants: const [
        Participant(name: 'Riya', role: 'UI Designer', initials: 'RY'),
        Participant(name: 'Arjun', role: 'Product Manager', initials: 'AJ'),
      ],
      executiveSummary: '',
      keyMetrics: const [],
      actionItems: const [],
      decisions: const [],
      transcriptSnippet: '',
      timeline: const [
        TimelineEvent(label: 'Transcribing', time: 'Apr 9, 10:18 AM'),
      ],
    ),
    Meeting(
      id: 'm5',
      title: 'Client Onboarding – Verma Industries',
      date: 'Apr 10, 2026',
      time: '9:30 AM',
      duration: '22 min',
      status: 'processing',
      participants: const [
        Participant(name: 'Nisha', role: 'Account Manager', initials: 'NS'),
        Participant(name: 'Vikram', role: 'Client Rep', initials: 'VK'),
        Participant(name: 'Sujal', role: 'Solutions Architect', initials: 'SB'),
      ],
      executiveSummary: '',
      keyMetrics: const [],
      actionItems: const [],
      decisions: const [],
      transcriptSnippet: '',
      timeline: const [
        TimelineEvent(label: 'Transcribing', time: 'Apr 10, 9:55 AM'),
        TimelineEvent(label: 'Analyzing', time: 'Apr 10, 9:56 AM'),
      ],
    ),
  ];

  // ─── Chat Messages ───────────────────────────────────────

  static const List<ChatMessageData> chatHistory = [
    ChatMessageData(
      text: "Hi! I'm your EchoMind assistant. Ask me anything about your meetings — like \"What did we discuss with the marketing team?\" or \"When is the next review?\"",
      isUser: false,
      time: '3:15 PM',
    ),
    ChatMessageData(
      text: 'What task did I assign Suraj?',
      isUser: true,
      time: '3:16 PM',
    ),
    ChatMessageData(
      text: 'In the Product Strategy Meeting on April 7, you assigned Suraj the task of researching competitive dairy brands and pricing models. The due date is April 16, 2026.',
      isUser: false,
      time: '3:16 PM',
    ),
    ChatMessageData(
      text: 'List upcoming meetings.',
      isUser: true,
      time: '3:17 PM',
    ),
    ChatMessageData(
      text: 'Here are your upcoming meetings:\n\n• April 15 – Review interactive plots with Jeremy\n• April 16 – Review revenue insights with Priya\n• April 17 – Amul strategy follow-up meeting\n• April 20 – Q1 board presentation',
      isUser: false,
      time: '3:17 PM',
    ),
    ChatMessageData(
      text: 'Summarize Q1 revenue performance.',
      isUser: true,
      time: '3:18 PM',
    ),
    ChatMessageData(
      text: 'Based on the Q1 Revenue Review meeting on April 5:\n\n📊 Total Revenue: ₹42.3 Cr (8% above target)\n📈 Premium segment grew 22%\n💰 Gross margin: 34.2%\n⚠️ Operating expenses increased 5.1%\n\nThe team recommended allocating 15% more budget to premium product marketing and scheduling a quarterly supply chain review.',
      isUser: false,
      time: '3:18 PM',
    ),
  ];

  // ─── Processing Steps ────────────────────────────────────

  static const List<String> processingSteps = [
    'Uploading audio',
    'Transcribing conversation',
    'Extracting insights',
    'Generating summary',
    'Identifying action items',
    'Creating meeting report',
  ];
}
