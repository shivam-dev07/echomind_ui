import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'mock_data.dart';

class ProcessingEvent {
  final MeetingCardState state;
  final DateTime timestamp;

  const ProcessingEvent({required this.state, required this.timestamp});
}

class ProcessingSimulator {
  Stream<ProcessingEvent> simulate() async* {
    final plan = [
      (MeetingCardState.uploading, const Duration(milliseconds: 1100)),
      (MeetingCardState.transcribing, const Duration(milliseconds: 1800)),
      (MeetingCardState.analyzingInsights, const Duration(milliseconds: 1700)),
      (MeetingCardState.generatingSummary, const Duration(milliseconds: 1400)),
      (MeetingCardState.completed, const Duration(milliseconds: 900)),
    ];

    for (final entry in plan) {
      await Future.delayed(entry.$2);
      yield ProcessingEvent(state: entry.$1, timestamp: DateTime.now());
    }
  }
}

class MockMeetingService {
  int _draftIndex = 0;

  List<Meeting> loadInitialMeetings() {
    return MockDataProvider.initialMeetings();
  }

  ({Meeting meeting, MeetingDraft draft}) createRecordedMeeting({
    required Duration recordingDuration,
  }) {
    final draft = MockDataProvider.meetingDrafts[
      _draftIndex % MockDataProvider.meetingDrafts.length
    ];
    _draftIndex++;

    final now = DateTime.now();
    final startedAt = now.subtract(recordingDuration);
    final minutes = recordingDuration.inMinutes;
    final seconds = recordingDuration.inSeconds % 60;

    return (
      meeting: Meeting(
        id: 'live-${DateTime.now().microsecondsSinceEpoch}',
        title: draft.title,
        date: _formatDate(startedAt),
        time: _formatTime(startedAt),
        duration: '${minutes}m ${seconds.toString().padLeft(2, '0')}s',
        state: MeetingCardState.recording,
        participants: draft.participants,
        executiveSummary: '',
        keyMetrics: const [],
        actionItems: const [],
        decisions: const [],
        transcriptSnippet: '',
        processingTimeline: const [],
      ),
      draft: draft,
    );
  }

  Meeting applyCompletedData({
    required Meeting meeting,
    required MeetingDraft draft,
  }) {
    return meeting.copyWith(
      executiveSummary: draft.executiveSummary,
      keyMetrics: draft.keyMetrics,
      actionItems: draft.actionItems,
      decisions: draft.decisions,
      transcriptSnippet: draft.transcriptSnippet,
    );
  }

  String _formatDate(DateTime date) {
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

  String _formatTime(DateTime date) {
    final hour24 = date.hour;
    final period = hour24 >= 12 ? 'PM' : 'AM';
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour12:$minute $period';
  }
}

class MeetingsController extends ChangeNotifier {
  final MockMeetingService _meetingService;
  final ProcessingSimulator _simulator;

  MeetingsController({
    MockMeetingService? meetingService,
    ProcessingSimulator? simulator,
  })  : _meetingService = meetingService ?? MockMeetingService(),
        _simulator = simulator ?? ProcessingSimulator();

  final List<Meeting> _meetings = [];
  final Set<String> _newlyInsertedIds = <String>{};
  final Map<String, MeetingDraft> _pendingDraftData = {};
  final Map<String, StreamSubscription<ProcessingEvent>> _subscriptions = {};

  List<Meeting> get meetings => List.unmodifiable(_meetings);

  Future<void> init() async {
    _meetings
      ..clear()
      ..addAll(_meetingService.loadInitialMeetings());
    notifyListeners();
  }

  Meeting? meetingById(String id) {
    for (final meeting in _meetings) {
      if (meeting.id == id) return meeting;
    }
    return null;
  }

  bool isNewlyInserted(String meetingId) => _newlyInsertedIds.contains(meetingId);

  void addRecordedMeeting(Duration recordingDuration) {
    final seed = _meetingService.createRecordedMeeting(
      recordingDuration: recordingDuration,
    );

    _pendingDraftData[seed.meeting.id] = seed.draft;
    _newlyInsertedIds.add(seed.meeting.id);
    _meetings.insert(0, seed.meeting);
    notifyListeners();

    Future<void>.delayed(const Duration(milliseconds: 80), () {
      _newlyInsertedIds.remove(seed.meeting.id);
      notifyListeners();
    });

    _startProcessing(seed.meeting.id);
  }

  void _startProcessing(String meetingId) {
    _subscriptions[meetingId]?.cancel();

    final subscription = _simulator.simulate().listen((event) {
      final idx = _meetings.indexWhere((m) => m.id == meetingId);
      if (idx == -1) return;
      final existing = _meetings[idx];
      final timeline = List<ProcessingTimelineItem>.from(existing.processingTimeline);

      if (event.state != MeetingCardState.recording) {
        timeline.add(
          ProcessingTimelineItem(state: event.state, timestamp: event.timestamp),
        );
      }

      var next = existing.copyWith(state: event.state, processingTimeline: timeline);

      if (event.state == MeetingCardState.completed) {
        final draft = _pendingDraftData.remove(meetingId);
        if (draft != null) {
          next = _meetingService.applyCompletedData(meeting: next, draft: draft);
        }
      }

      _meetings[idx] = next;
      notifyListeners();
    });

    _subscriptions[meetingId] = subscription;
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }
    super.dispose();
  }
}

class MeetingsStateProvider extends StatelessWidget {
  final Widget child;

  const MeetingsStateProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MeetingsController>(
      create: (_) => MeetingsController()..init(),
      child: child,
    );
  }
}
