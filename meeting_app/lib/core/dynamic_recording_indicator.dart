import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/main_layout.dart';
import 'recording_controller.dart';
import 'theme.dart';

class DynamicRecordingIndicator extends StatefulWidget {
  final VoidCallback onTap;
  final bool hideWhenOnRecordTab;

  const DynamicRecordingIndicator({
    super.key,
    required this.onTap,
    this.hideWhenOnRecordTab = true,
  });

  @override
  State<DynamicRecordingIndicator> createState() =>
      _DynamicRecordingIndicatorState();
}

class _DynamicRecordingIndicatorState extends State<DynamicRecordingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RecordingController>(
      builder: (context, recording, child) {
        final currentState = MainLayout.globalKey.currentState;
        final isOnRecordTab = currentState?.currentIndex == 0;
        final visible =
            recording.isRecording && (!widget.hideWhenOnRecordTab || !isOnRecordTab);
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 280),
          opacity: visible ? 1 : 0,
          child: IgnorePointer(
            ignoring: !visible,
            child: AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOut,
              child: visible
                  ? GestureDetector(
                      onTap: widget.onTap,
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 210),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: AppColors.glass,
                          border: Border.all(
                            color: AppColors.primaryPeach.withOpacity(0.28),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryPeach.withOpacity(0.16),
                              blurRadius: 24,
                              spreadRadius: -6,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(26),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildLiveDot(),
                                const SizedBox(width: 8),
                                Text(
                                  'Recording',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  recording.formattedDuration,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.primaryPeach,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                _buildWaveform(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLiveDot() {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFFF4D4D),
        boxShadow: AppShadows.glow(const Color(0xFFFF4D4D)),
      ),
    );
  }

  Widget _buildWaveform() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return SizedBox(
          width: 38,
          height: 16,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(5, (index) {
              final phase = (_waveController.value * 2 * pi) + index;
              final h = 4.0 + (8.0 * ((sin(phase) + 1) / 2));
              return Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    height: h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: AppColors.primaryGradient,
                    ),
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
