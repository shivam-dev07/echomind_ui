import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/mock_data.dart';
import '../core/theme.dart';
import '../core/widgets.dart';

class SummaryScreen extends StatefulWidget {
  final String meetingId;

  const SummaryScreen({super.key, required this.meetingId});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen>
    with SingleTickerProviderStateMixin {
  late Meeting _meeting;
  bool _isLoading = true;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _loadMeeting();
  }

  Future<void> _loadMeeting() async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    final found = MockDataProvider.meetings.firstWhere(
      (m) => m.id == widget.meetingId,
      orElse: () => MockDataProvider.meetings.first,
    );

    setState(() {
      _meeting = found;
      _isLoading = false;
    });
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.glass,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary,
              size: 18,
            ),
          ),
        ),
        title: Text('Meeting Summary', style: AppTypography.titleLarge),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Ambient glow
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryPeach.withOpacity(0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Content
          _isLoading ? _buildLoadingState() : _buildContent(),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.primaryPeach,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Loading summary...',
            style: TextStyle(color: AppColors.textTertiary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    // Empty state for processing/transcribing meetings
    if (_meeting.executiveSummary.isEmpty) {
      return _buildProcessingState();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 80, 20, 32),
          children: [
            // Meeting title card
            _buildTitleCard(),
            const SizedBox(height: 16),

            // Participants
            _buildParticipantsCard(),
            const SizedBox(height: 16),

            // Bento grid row 1
            Row(
              children: [
                Expanded(child: _buildMetricTile('Duration', _meeting.duration, Icons.timer_outlined)),
                const SizedBox(width: 12),
                Expanded(child: _buildMetricTile('Participants', '${_meeting.participants.length}', Icons.group_rounded)),
                const SizedBox(width: 12),
                Expanded(child: _buildMetricTile('Actions', '${_meeting.actionItems.length}', Icons.task_alt_rounded)),
              ],
            ),
            const SizedBox(height: 16),

            // Executive Summary
            _buildSectionCard(
              title: 'Executive Summary',
              icon: Icons.article_rounded,
              child: Text(
                _meeting.executiveSummary,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Key Metrics
            _buildSectionCard(
              title: 'Key Metrics',
              icon: Icons.insights_rounded,
              child: Column(
                children: _meeting.keyMetrics.map((metric) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.primaryGradient,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            metric,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Action Items
            _buildSectionCard(
              title: 'Action Items',
              icon: Icons.task_alt_rounded,
              child: Column(
                children: _meeting.actionItems.asMap().entries.map((entry) {
                  final item = entry.value;
                  final index = entry.key;
                  return Container(
                    margin: EdgeInsets.only(
                      bottom: index < _meeting.actionItems.length - 1 ? 12 : 0,
                    ),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.glass,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _avatarColor(index).withOpacity(0.15),
                              ),
                              child: Center(
                                child: Text(
                                  item.assignedTo[0],
                                  style: AppTypography.caption.copyWith(
                                    color: _avatarColor(index),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.assignedTo,
                                    style: AppTypography.labelLarge.copyWith(
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    'Due: ${item.dueDate}',
                                    style: AppTypography.caption.copyWith(
                                      fontSize: 10,
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              item.isCompleted
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              size: 18,
                              color: item.isCompleted
                                  ? AppColors.success
                                  : AppColors.textTertiary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.description,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Decisions Made
            _buildSectionCard(
              title: 'Decisions Made',
              icon: Icons.gavel_rounded,
              child: Column(
                children: _meeting.decisions.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.success.withOpacity(0.1),
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.success,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Processing Timeline
            _buildSectionCard(
              title: 'Processing Timeline',
              icon: Icons.timeline_rounded,
              child: Column(
                children: _meeting.timeline.asMap().entries.map((entry) {
                  final event = entry.value;
                  final index = entry.key;
                  final isLast = index == _meeting.timeline.length - 1;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.success.withOpacity(0.12),
                              border: Border.all(
                                color: AppColors.success.withOpacity(0.3),
                              ),
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 12,
                              color: AppColors.success,
                            ),
                          ),
                          if (!isLast)
                            Container(
                              width: 1.5,
                              height: 28,
                              color: AppColors.success.withOpacity(0.2),
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                event.label,
                                style: AppTypography.labelLarge.copyWith(
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                event.time,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textTertiary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleCard() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _meeting.title,
            style: AppTypography.headlineMedium,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded,
                  size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 6),
              Text(_meeting.date, style: AppTypography.bodySmall),
              const SizedBox(width: 16),
              Icon(Icons.access_time_rounded,
                  size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text(_meeting.time, style: AppTypography.bodySmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsCard() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Participants', icon: Icons.group_rounded),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _meeting.participants.asMap().entries.map((entry) {
              final p = entry.value;
              final i = entry.key;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.glass,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _avatarColor(i),
                      ),
                      child: Center(
                        child: Text(
                          p.initials,
                          style: AppTypography.caption.copyWith(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          style: AppTypography.labelLarge.copyWith(fontSize: 12),
                        ),
                        Text(
                          p.role,
                          style: AppTypography.caption.copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      borderRadius: AppRadius.lg,
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryPeach, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.textPrimary,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.caption.copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: title, icon: icon),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildProcessingState() {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
            borderRadius: AppRadius.xxl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryPeach.withOpacity(0.1),
                        AppColors.secondaryBlue.withOpacity(0.05),
                      ],
                    ),
                    border: Border.all(
                      color: AppColors.primaryPeach.withOpacity(0.15),
                    ),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.primaryPeach,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  _meeting.status == 'transcribing'
                      ? 'Transcribing...'
                      : 'Processing...',
                  style: AppTypography.headlineMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  'Your meeting is being analyzed by\nour AI. This usually takes a few minutes.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                // Timeline for this meeting
                ...(_meeting.timeline.map((event) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 16,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          event.label,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          event.time,
                          style: AppTypography.caption.copyWith(
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  );
                })),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _avatarColor(int index) {
    const colors = [
      Color(0xFF6366F1),
      Color(0xFFEC4899),
      Color(0xFF14B8A6),
      Color(0xFFF59E0B),
      Color(0xFF8B5CF6),
    ];
    return colors[index % colors.length];
  }
}
