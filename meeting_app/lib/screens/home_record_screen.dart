import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/meeting_state.dart';
import '../core/recording_controller.dart';
import '../core/theme.dart';
import '../core/widgets.dart';

class HomeRecordScreen extends StatefulWidget {
  final VoidCallback onMeetingCreated;

  const HomeRecordScreen({super.key, required this.onMeetingCreated});

  @override
  State<HomeRecordScreen> createState() => _HomeRecordScreenState();
}

class _HomeRecordScreenState extends State<HomeRecordScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late AnimationController _ringController;
  late Animation<double> _ringRotation;

  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _ringRotation = Tween<double>(begin: 0, end: 2 * pi).animate(_ringController);

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _ringController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    final recordingController = context.read<RecordingController>();
    final meetingsController = context.read<MeetingsController>();

    if (recordingController.isRecording) {
      final elapsed = await recordingController.stopRecording();
      if (!mounted) return;
      meetingsController.addRecordedMeeting(elapsed);
      widget.onMeetingCreated();
    } else {
      await recordingController.startRecording();
    }
  }

  @override
  Widget build(BuildContext context) {
    final recording = context.watch<RecordingController>();
    final isRecording = recording.isRecording;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppLogoHeader(),

            const SizedBox(height: 32),

            Text(
              'Start your\nmeeting',
              style: AppTypography.displayLarge.copyWith(height: 1.05),
            ),

            const SizedBox(height: 12),

            Text(
              'Bring your team together and let AI\nhandle the documentation.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
            ),

            const Spacer(),

            // Microphone Orb
            Center(child: _buildMicrophoneOrb()),

            const SizedBox(height: 24),

            // Recording timer
            if (isRecording)
              Center(
                child: Text(
                  recording.formattedDuration,
                  style: AppTypography.displayMedium.copyWith(
                    color: AppColors.primaryPeach,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),

            const SizedBox(height: 12),

            // Status pill
            Center(child: _buildStatusPill()),

            const SizedBox(height: 24),

            // Wave visualization
            if (isRecording) _buildWaveVisualization(),

            const Spacer(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildMicrophoneOrb() {
    final isRecording = context.watch<RecordingController>().isRecording;

    return GestureDetector(
      onTap: _toggleRecording,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseAnimation, _ringRotation]),
        builder: (context, child) {
          return SizedBox(
            width: 220,
            height: 220,
            child: Stack(
              alignment: Alignment.center,
                children: [
                if (isRecording) ...[
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryPeach.withOpacity(
                          0.1 * _pulseAnimation.value,
                        ),
                        width: 1,
                      ),
                    ),
                  ),
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryPeach.withOpacity(
                          0.15 * _pulseAnimation.value,
                        ),
                        width: 1.5,
                      ),
                    ),
                  ),
                ],

                if (isRecording)
                  Transform.rotate(
                    angle: _ringRotation.value,
                    child: Container(
                      width: 185,
                      height: 185,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: [
                            AppColors.primaryPeach.withOpacity(0.6),
                            AppColors.primaryPink.withOpacity(0.3),
                            AppColors.secondaryBlue.withOpacity(0.2),
                            Colors.transparent,
                            AppColors.primaryPeach.withOpacity(0.6),
                          ],
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.background,
                        ),
                      ),
                    ),
                  ),

                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      if (isRecording)
                        BoxShadow(
                          color: AppColors.primaryPeach.withOpacity(
                            0.35 * _pulseAnimation.value,
                          ),
                          blurRadius: 50,
                          spreadRadius: 10 * _pulseAnimation.value,
                        ),
                    ],
                  ),
                  child: ClipOval(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: isRecording
                              ? RadialGradient(
                                  colors: [
                                    AppColors.primaryPeach.withOpacity(0.8),
                                    AppColors.primaryPink.withOpacity(0.6),
                                    AppColors.primaryPeach.withOpacity(0.3),
                                  ],
                                  stops: const [0.0, 0.5, 1.0],
                                )
                              : const RadialGradient(
                                  colors: [
                                    AppColors.surfaceElevated,
                                    AppColors.surface,
                                  ],
                                ),
                          border: Border.all(
                            color: isRecording
                                ? AppColors.primaryPeach.withOpacity(0.5)
                                : AppColors.glassBorder,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            isRecording
                                ? Icons.stop_rounded
                                : Icons.mic_none_rounded,
                            size: 56,
                            color:
                                isRecording ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusPill() {
    final isRecording = context.watch<RecordingController>().isRecording;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: isRecording
                ? AppColors.primaryPeach.withOpacity(0.1)
                : AppColors.glass,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
              color: isRecording
                  ? AppColors.primaryPeach.withOpacity(0.3)
                  : AppColors.glassBorder,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isRecording) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryPeach,
                    boxShadow: AppShadows.glow(AppColors.primaryPeach),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Text(
                isRecording
                    ? 'Listening to meeting...'
                    : 'Tap to begin recording',
                style: AppTypography.bodySmall.copyWith(
                  color: isRecording
                      ? AppColors.primaryPeach
                      : AppColors.textTertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWaveVisualization() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return Container(
          height: 48,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(24, (index) {
              final phase = (_waveController.value * 2 * pi) + (index * 0.3);
              final height = 8 + 20 * ((sin(phase) + 1) / 2);
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 3,
                height: height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primaryPeach.withOpacity(0.8),
                      AppColors.primaryPink.withOpacity(0.4),
                    ],
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
