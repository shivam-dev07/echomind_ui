import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/mock_data.dart';
import '../core/theme.dart';
import '../core/widgets.dart';

class ProcessingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const ProcessingScreen({super.key, required this.onComplete});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  final int _totalSteps = MockDataProvider.processingSteps.length;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late AnimationController _waveController;

  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _startProcessing();
  }

  Future<void> _startProcessing() async {
    for (int i = 0; i < _totalSteps; i++) {
      await Future.delayed(Duration(milliseconds: 1200 + (i * 200)));
      if (!mounted) return;
      setState(() => _currentStep = i + 1);
      _progressController.forward(from: 0);
    }

    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) widget.onComplete();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _buildAmbientGlow(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 60),

                  // AI processing icon
                  _buildProcessingOrb(),

                  const SizedBox(height: 40),

                  // Title
                  Text(
                    'Analyzing Meeting',
                    style: AppTypography.displayMedium,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Our AI is extracting insights from\nyour conversation',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 48),

                  // Waveform
                  _buildAiWaveform(),

                  const SizedBox(height: 48),

                  // Progress timeline
                  Expanded(
                    child: _buildProgressTimeline(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmbientGlow() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, _) {
        return Stack(
          children: [
            Positioned(
              top: -100,
              left: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primaryPeach.withOpacity(0.08 * _pulseAnimation.value),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              right: -60,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.secondaryBlue.withOpacity(0.06 * _pulseAnimation.value),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProcessingOrb() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, _) {
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPeach.withOpacity(0.2 * _pulseAnimation.value),
                blurRadius: 50,
                spreadRadius: 10,
              ),
              BoxShadow(
                color: AppColors.secondaryBlue.withOpacity(0.1 * _pulseAnimation.value),
                blurRadius: 80,
                spreadRadius: 20,
              ),
            ],
          ),
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primaryPeach.withOpacity(0.2),
                      AppColors.secondaryBlue.withOpacity(0.1),
                      AppColors.glass,
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.primaryPeach.withOpacity(0.2),
                  ),
                ),
                child: const Center(
                  child: GlowIcon(
                    icon: Icons.auto_awesome_rounded,
                    color: AppColors.primaryPeach,
                    size: 40,
                    glowRadius: 20,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAiWaveform() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, _) {
        return SizedBox(
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(32, (index) {
              final phase = (_waveController.value * 2 * pi) + (index * 0.25);
              final h = 6 + 22 * ((sin(phase) + 1) / 2) * (0.5 + 0.5 * sin(index * 0.5 + _waveController.value * pi));
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                width: 2.5,
                height: h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primaryPeach.withOpacity(0.9),
                      AppColors.secondaryBlue.withOpacity(0.5),
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

  Widget _buildProgressTimeline() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _totalSteps,
      itemBuilder: (context, index) {
        final isCompleted = index < _currentStep;
        final isActive = index == _currentStep - 1;


        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          margin: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              // Step indicator
              SizedBox(
                width: 36,
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted
                            ? AppColors.success.withOpacity(0.15)
                            : isActive
                                ? AppColors.primaryPeach.withOpacity(0.15)
                                : AppColors.glass,
                        border: Border.all(
                          color: isCompleted
                              ? AppColors.success.withOpacity(0.4)
                              : isActive
                                  ? AppColors.primaryPeach.withOpacity(0.4)
                                  : AppColors.glassBorder,
                          width: 1.5,
                        ),
                        boxShadow: isActive
                            ? AppShadows.glow(AppColors.primaryPeach)
                            : null,
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(
                                Icons.check_rounded,
                                size: 14,
                                color: AppColors.success,
                              )
                            : isActive
                                ? SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                      color: AppColors.primaryPeach,
                                    ),
                                  )
                                : Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.textTertiary.withOpacity(0.3),
                                    ),
                                  ),
                      ),
                    ),
                    if (index < _totalSteps - 1)
                      Container(
                        width: 1.5,
                        height: 16,
                        color: isCompleted
                            ? AppColors.success.withOpacity(0.3)
                            : AppColors.glassBorder,
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 14),

              // Step label
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    MockDataProvider.processingSteps[index],
                    style: AppTypography.bodyMedium.copyWith(
                      color: isCompleted
                          ? AppColors.textPrimary
                          : isActive
                              ? AppColors.primaryPeach
                              : AppColors.textTertiary,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),

              // Completion indicator
              if (isCompleted)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    '✓',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
