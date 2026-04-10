import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecordingController extends ChangeNotifier {
  static const String _isRecordingKey = 'recording_is_active';
  static const String _recordingStartKey = 'recording_start_ms';

  bool _isRecording = false;
  DateTime? _recordingStartTime;
  Timer? _ticker;

  bool get isRecording => _isRecording;
  DateTime? get recordingStartTime => _recordingStartTime;

  Duration get recordingDuration {
    if (!_isRecording || _recordingStartTime == null) {
      return Duration.zero;
    }
    return DateTime.now().difference(_recordingStartTime!);
  }

  String get formattedDuration {
    final duration = recordingDuration;
    final hours = duration.inHours;
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final isRecording = prefs.getBool(_isRecordingKey) ?? false;
    final startMs = prefs.getInt(_recordingStartKey);

    if (isRecording && startMs != null) {
      _isRecording = true;
      _recordingStartTime = DateTime.fromMillisecondsSinceEpoch(startMs);
      _startTicker();
      notifyListeners();
    }
  }

  Future<void> startRecording() async {
    if (_isRecording) return;
    _isRecording = true;
    _recordingStartTime = DateTime.now();
    _startTicker();
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isRecordingKey, true);
    await prefs.setInt(
      _recordingStartKey,
      _recordingStartTime!.millisecondsSinceEpoch,
    );
  }

  Future<Duration> stopRecording() async {
    if (!_isRecording || _recordingStartTime == null) {
      return Duration.zero;
    }

    final elapsed = DateTime.now().difference(_recordingStartTime!);
    _isRecording = false;
    _recordingStartTime = null;
    _ticker?.cancel();
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isRecordingKey, false);
    await prefs.remove(_recordingStartKey);

    return elapsed;
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isRecording) {
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

class RecordingStateProvider extends StatelessWidget {
  final Widget child;

  const RecordingStateProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RecordingController>(
      create: (_) => RecordingController()..init(),
      child: child,
    );
  }
}
