enum MeetingCardState {
  recording,
  uploading,
  transcribing,
  analyzingInsights,
  generatingSummary,
  completed,
}

extension MeetingCardStateX on MeetingCardState {
  String get cardLabel {
    switch (this) {
      case MeetingCardState.recording:
        return 'Recording';
      case MeetingCardState.uploading:
        return 'Uploading Audio';
      case MeetingCardState.transcribing:
        return 'Transcribing Meeting';
      case MeetingCardState.analyzingInsights:
        return 'Analyzing Insights';
      case MeetingCardState.generatingSummary:
        return 'Generating Summary';
      case MeetingCardState.completed:
        return 'Completed';
    }
  }

  String get timelineLabel {
    switch (this) {
      case MeetingCardState.recording:
        return 'Recording';
      case MeetingCardState.uploading:
        return 'Uploading Audio';
      case MeetingCardState.transcribing:
        return 'Transcribing Meeting';
      case MeetingCardState.analyzingInsights:
        return 'Extracting Insights';
      case MeetingCardState.generatingSummary:
        return 'Generating Summary';
      case MeetingCardState.completed:
        return 'Completed';
    }
  }

  double get progress {
    switch (this) {
      case MeetingCardState.recording:
        return 0.08;
      case MeetingCardState.uploading:
        return 0.25;
      case MeetingCardState.transcribing:
        return 0.5;
      case MeetingCardState.analyzingInsights:
        return 0.72;
      case MeetingCardState.generatingSummary:
        return 0.9;
      case MeetingCardState.completed:
        return 1.0;
    }
  }

  bool get isProcessing => this != MeetingCardState.completed;
}

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

class ProcessingTimelineItem {
  final MeetingCardState state;
  final DateTime timestamp;

  const ProcessingTimelineItem({
    required this.state,
    required this.timestamp,
  });
}

class Meeting {
  final String id;
  final String title;
  final String date;
  final String time;
  final String duration;
  final MeetingCardState state;
  final List<Participant> participants;
  final String executiveSummary;
  final List<String> keyMetrics;
  final List<ActionItem> actionItems;
  final List<String> decisions;
  final String transcriptSnippet;
  final List<ProcessingTimelineItem> processingTimeline;

  const Meeting({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.duration,
    required this.state,
    required this.participants,
    required this.executiveSummary,
    required this.keyMetrics,
    required this.actionItems,
    required this.decisions,
    required this.transcriptSnippet,
    required this.processingTimeline,
  });

  Meeting copyWith({
    String? id,
    String? title,
    String? date,
    String? time,
    String? duration,
    MeetingCardState? state,
    List<Participant>? participants,
    String? executiveSummary,
    List<String>? keyMetrics,
    List<ActionItem>? actionItems,
    List<String>? decisions,
    String? transcriptSnippet,
    List<ProcessingTimelineItem>? processingTimeline,
  }) {
    return Meeting(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      time: time ?? this.time,
      duration: duration ?? this.duration,
      state: state ?? this.state,
      participants: participants ?? this.participants,
      executiveSummary: executiveSummary ?? this.executiveSummary,
      keyMetrics: keyMetrics ?? this.keyMetrics,
      actionItems: actionItems ?? this.actionItems,
      decisions: decisions ?? this.decisions,
      transcriptSnippet: transcriptSnippet ?? this.transcriptSnippet,
      processingTimeline: processingTimeline ?? this.processingTimeline,
    );
  }
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

class MeetingDraft {
  final String title;
  final List<Participant> participants;
  final String executiveSummary;
  final List<String> keyMetrics;
  final List<ActionItem> actionItems;
  final List<String> decisions;
  final String transcriptSnippet;

  const MeetingDraft({
    required this.title,
    required this.participants,
    required this.executiveSummary,
    required this.keyMetrics,
    required this.actionItems,
    required this.decisions,
    required this.transcriptSnippet,
  });
}

class MockDataProvider {
  static const String userName = 'Sujal Bandodkar';
  static const String userEmail = 'sujal.bandodkar@echomind.ai';
  static const String userInitials = 'SB';

  static List<Meeting> initialMeetings() {
    final now = DateTime.now();
    return [
      _completedMeeting(
        id: 'm1',
        startedAt: now.subtract(const Duration(days: 3, hours: 2)),
        duration: '42 min',
        draft: meetingDrafts[0],
      ),
      _completedMeeting(
        id: 'm2',
        startedAt: now.subtract(const Duration(days: 2, hours: 4)),
        duration: '38 min',
        draft: meetingDrafts[1],
      ),
      _completedMeeting(
        id: 'm3',
        startedAt: now.subtract(const Duration(days: 2, hours: 22)),
        duration: '29 min',
        draft: meetingDrafts[2],
      ),
      _completedMeeting(
        id: 'm4',
        startedAt: now.subtract(const Duration(days: 1, hours: 6)),
        duration: '47 min',
        draft: meetingDrafts[3],
      ),
      _completedMeeting(
        id: 'm5',
        startedAt: now.subtract(const Duration(hours: 8)),
        duration: '26 min',
        draft: meetingDrafts[4],
      ),
    ];
  }

  static Meeting _completedMeeting({
    required String id,
    required DateTime startedAt,
    required String duration,
    required MeetingDraft draft,
  }) {
    return Meeting(
      id: id,
      title: draft.title,
      date: _formatDate(startedAt),
      time: _formatTime(startedAt),
      duration: duration,
      state: MeetingCardState.completed,
      participants: draft.participants,
      executiveSummary: draft.executiveSummary,
      keyMetrics: draft.keyMetrics,
      actionItems: draft.actionItems,
      decisions: draft.decisions,
      transcriptSnippet: draft.transcriptSnippet,
      processingTimeline: [
        ProcessingTimelineItem(
          state: MeetingCardState.uploading,
          timestamp: startedAt.add(const Duration(minutes: 42, seconds: 6)),
        ),
        ProcessingTimelineItem(
          state: MeetingCardState.transcribing,
          timestamp: startedAt.add(const Duration(minutes: 42, seconds: 25)),
        ),
        ProcessingTimelineItem(
          state: MeetingCardState.analyzingInsights,
          timestamp: startedAt.add(const Duration(minutes: 42, seconds: 44)),
        ),
        ProcessingTimelineItem(
          state: MeetingCardState.generatingSummary,
          timestamp: startedAt.add(const Duration(minutes: 43, seconds: 5)),
        ),
        ProcessingTimelineItem(
          state: MeetingCardState.completed,
          timestamp: startedAt.add(const Duration(minutes: 43, seconds: 22)),
        ),
      ],
    );
  }

  static const List<MeetingDraft> meetingDrafts = [
    MeetingDraft(
      title: 'Amul Dairy Strategy Meeting',
      participants: [
        Participant(name: 'Jacob', role: 'Frontend', initials: 'JC'),
        Participant(name: 'Sarah', role: 'Backend', initials: 'SA'),
        Participant(name: 'Jeremy', role: 'Data Analytics', initials: 'JR'),
        Participant(name: 'Suraj', role: 'Research', initials: 'SU'),
      ],
      executiveSummary:
          'Discussion focused on building a digital platform for Amul Dairy Products and analyzing historical revenue data to generate strategic insights.',
      keyMetrics: [
        'Online demand trend analyzed across 18 months',
        'High-margin SKUs identified for Q2 campaigns',
        'D2C conversion opportunity estimated at +14%',
      ],
      actionItems: [
        ActionItem(
          assignedTo: 'Jacob',
          description: 'Build the frontend website.',
          dueDate: 'Apr 14, 2026',
        ),
        ActionItem(
          assignedTo: 'Sarah',
          description: 'Develop backend APIs.',
          dueDate: 'Apr 14, 2026',
        ),
        ActionItem(
          assignedTo: 'Jeremy',
          description: 'Analyze revenue data.',
          dueDate: 'Apr 15, 2026',
        ),
        ActionItem(
          assignedTo: 'Suraj',
          description: 'Research competitor dairy brands.',
          dueDate: 'Apr 16, 2026',
        ),
      ],
      decisions: [
        'Launch MVP in 4 weeks with focused SKU catalog',
        'Review cohort retention metrics in weekly standup',
        'Prioritize revenue dashboard for leadership',
      ],
      transcriptSnippet:
          'Jacob: We can move faster by shipping the top-selling categories first. Sarah: Agreed, API contracts can be finalized by Thursday.',
    ),
    MeetingDraft(
      title: 'Regional Sales Forecast Sync',
      participants: [
        Participant(name: 'Neha', role: 'Sales Lead', initials: 'NH'),
        Participant(name: 'Rohan', role: 'Finance', initials: 'RH'),
        Participant(name: 'Maya', role: 'Ops', initials: 'MY'),
      ],
      executiveSummary:
          'Team aligned on regional demand forecasts and identified inventory pressure in the West zone for the next two cycles.',
      keyMetrics: [
        'Forecast accuracy improved to 87%',
        'West region shortfall risk at 11%',
        'Repeat order growth +9% month-over-month',
      ],
      actionItems: [
        ActionItem(
          assignedTo: 'Neha',
          description: 'Share revised zone-level sales plan.',
          dueDate: 'Apr 12, 2026',
        ),
        ActionItem(
          assignedTo: 'Maya',
          description: 'Coordinate inventory rebalancing for West zone.',
          dueDate: 'Apr 13, 2026',
        ),
      ],
      decisions: [
        'Increase buffer stock for premium yogurt SKUs',
        'Track variance weekly instead of bi-weekly',
      ],
      transcriptSnippet:
          'Neha: Pune and Ahmedabad are outperforming our assumptions. Rohan: We should lock revised numbers before Friday close.',
    ),
    MeetingDraft(
      title: 'Engineering Sprint Retrospective',
      participants: [
        Participant(name: 'Aarav', role: 'Mobile', initials: 'AR'),
        Participant(name: 'Meera', role: 'QA', initials: 'ME'),
        Participant(name: 'Kiran', role: 'DevOps', initials: 'KI'),
      ],
      executiveSummary:
          'The squad closed 91% sprint scope, reduced build failures, and agreed on stricter definition-of-done for stories entering QA.',
      keyMetrics: [
        'Sprint completion: 91%',
        'CI failure rate reduced from 14% to 6%',
        'Regression test cycle reduced by 22 minutes',
      ],
      actionItems: [
        ActionItem(
          assignedTo: 'Meera',
          description: 'Expand automated regression suite.',
          dueDate: 'Apr 18, 2026',
        ),
        ActionItem(
          assignedTo: 'Kiran',
          description: 'Add flaky-test detector in CI.',
          dueDate: 'Apr 17, 2026',
        ),
      ],
      decisions: [
        'Adopt release freeze 24h before deployment',
        'Run short QA triage after each feature merge',
      ],
      transcriptSnippet:
          'Aarav: Let us keep stories smaller so QA gets predictable windows. Meera: That would cut context switching significantly.',
    ),
    MeetingDraft(
      title: 'Client Onboarding - Verma Industries',
      participants: [
        Participant(name: 'Nisha', role: 'Account Manager', initials: 'NI'),
        Participant(name: 'Vikram', role: 'Client Rep', initials: 'VI'),
        Participant(name: 'Sujal', role: 'Solutions', initials: 'SB'),
      ],
      executiveSummary:
          'Kickoff call covered rollout milestones, stakeholder access, and reporting cadence for the first 30 days of onboarding.',
      keyMetrics: [
        'Target go-live date locked for Apr 24',
        '7 stakeholders mapped to role permissions',
        'Weekly status cadence finalized',
      ],
      actionItems: [
        ActionItem(
          assignedTo: 'Nisha',
          description: 'Send onboarding checklist and dependencies.',
          dueDate: 'Apr 11, 2026',
        ),
        ActionItem(
          assignedTo: 'Sujal',
          description: 'Prepare architecture handoff deck.',
          dueDate: 'Apr 12, 2026',
        ),
      ],
      decisions: [
        'Use phased rollout across 2 business units',
        'Enable executive dashboard in week 2',
      ],
      transcriptSnippet:
          'Vikram: We need clear owners for every milestone. Nisha: I will circulate an ownership matrix after this call.',
    ),
    MeetingDraft(
      title: 'Design Critique - Mobile v2.1',
      participants: [
        Participant(name: 'Riya', role: 'UI Design', initials: 'RI'),
        Participant(name: 'Arjun', role: 'Product', initials: 'AJ'),
        Participant(name: 'Tanmay', role: 'UX Research', initials: 'TA'),
      ],
      executiveSummary:
          'The team finalized interaction polish for navigation flows and agreed on accessibility improvements for low-contrast components.',
      keyMetrics: [
        'Task completion score: 4.5/5 in prototype test',
        'Navigation error rate dropped by 31%',
        'Accessibility issues reduced from 12 to 4',
      ],
      actionItems: [
        ActionItem(
          assignedTo: 'Riya',
          description: 'Deliver revised component specs.',
          dueDate: 'Apr 13, 2026',
        ),
        ActionItem(
          assignedTo: 'Tanmay',
          description: 'Run one more usability validation session.',
          dueDate: 'Apr 15, 2026',
        ),
      ],
      decisions: [
        'Ship revised nav transitions in next beta build',
        'Keep card density compact on meetings screen',
      ],
      transcriptSnippet:
          'Arjun: The tighter hierarchy reads much better now. Riya: Great, I will push final specs by Monday morning.',
    ),
  ];

  static const List<ChatMessageData> chatHistory = [
    ChatMessageData(
      text: "Hi! I am your EchoMind assistant. Ask me anything about your meetings.",
      isUser: false,
      time: '3:15 PM',
    ),
    ChatMessageData(
      text: 'What task did I assign Suraj?',
      isUser: true,
      time: '3:16 PM',
    ),
    ChatMessageData(
      text:
          'You assigned Suraj to research competitor dairy brands in the Amul Dairy Strategy Meeting. Due date: Apr 16, 2026.',
      isUser: false,
      time: '3:16 PM',
    ),
    ChatMessageData(
      text: 'When is the next meeting?',
      isUser: true,
      time: '3:17 PM',
    ),
    ChatMessageData(
      text:
          'Your next meeting is Regional Sales Forecast Sync on Apr 12 at 11:00 AM.',
      isUser: false,
      time: '3:17 PM',
    ),
    ChatMessageData(
      text: 'What were the key decisions from the Amul meeting?',
      isUser: true,
      time: '3:18 PM',
    ),
    ChatMessageData(
      text:
          'Key decisions: ship an MVP in 4 weeks, track retention metrics weekly, and prioritize the revenue dashboard for leadership.',
      isUser: false,
      time: '3:18 PM',
    ),
  ];

  static String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}';
  }

  static String _formatTime(DateTime date) {
    final hour24 = date.hour;
    final period = hour24 >= 12 ? 'PM' : 'AM';
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour12:$minute $period';
  }
}
