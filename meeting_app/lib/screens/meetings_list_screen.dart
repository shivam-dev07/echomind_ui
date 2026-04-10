import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/meeting_state.dart';
import '../core/mock_data.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import 'summary_screen.dart';

class MeetingsListScreen extends StatefulWidget {
  const MeetingsListScreen({super.key});

  @override
  State<MeetingsListScreen> createState() => MeetingsListScreenState();
}

class MeetingsListScreenState extends State<MeetingsListScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Widget _buildStatusBadge(MeetingCardState state) {
    Color badgeColor;
    IconData badgeIcon;
    String label;
    bool showSpinner = false;

    switch (state) {
      case MeetingCardState.recording:
        badgeColor = const Color(0xFFFF4D4D);
        badgeIcon = Icons.mic_rounded;
        label = 'Recording';
        break;
      case MeetingCardState.uploading:
        badgeColor = AppColors.info;
        badgeIcon = Icons.cloud_upload_rounded;
        label = 'Uploading';
        break;
      case MeetingCardState.transcribing:
        badgeColor = AppColors.warning;
        badgeIcon = Icons.hourglass_top_rounded;
        label = 'Transcribing';
        showSpinner = true;
        break;
      case MeetingCardState.analyzingInsights:
        badgeColor = AppColors.secondaryBlue;
        badgeIcon = Icons.auto_awesome_rounded;
        label = 'Analyzing';
        showSpinner = true;
        break;
      case MeetingCardState.generatingSummary:
        badgeColor = AppColors.primaryPeach;
        badgeIcon = Icons.notes_rounded;
        label = 'Summary';
        showSpinner = true;
        break;
      case MeetingCardState.completed:
        badgeColor = AppColors.success;
        badgeIcon = Icons.check_circle_rounded;
        label = 'Completed';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: badgeColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showSpinner) ...[
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: badgeColor,
              ),
            ),
          ] else ...[
            Icon(badgeIcon, size: 12, color: badgeColor),
          ],
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final meetings = context.watch<MeetingsController>().meetings;

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: const AppLogoHeader(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Your Meetings', style: AppTypography.displayMedium),
                // Count badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPeach.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(
                      color: AppColors.primaryPeach.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    '${meetings.length}',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.primaryPeach,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
            child: Text(
              'All your recorded meetings and summaries',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ),
          Expanded(child: _buildMeetingsList()),
        ],
      ),
    );
  }

  Widget _buildMeetingsList() {
    return Consumer<MeetingsController>(
      builder: (context, meetingsController, child) {
        final meetings = meetingsController.meetings;
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
          itemCount: meetings.length,
          itemBuilder: (context, index) {
            final meeting = meetings[index];
            final inserted = meetingsController.isNewlyInserted(meeting.id);

            return AnimatedSlide(
              duration: const Duration(milliseconds: 420),
              curve: Curves.easeOutCubic,
              offset: inserted ? const Offset(0, 0.2) : Offset.zero,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 420),
                opacity: inserted ? 0.0 : 1.0,
                curve: Curves.easeOut,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: BentoTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SummaryScreen(meetingId: meeting.id),
                        ),
                      );
                    },
                    accentColor: _getStatusColor(meeting.state),
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 5),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _getStatusColor(meeting.state),
                                boxShadow: [
                                  BoxShadow(
                                    color: _getStatusColor(meeting.state)
                                        .withOpacity(0.5),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                meeting.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.titleMedium,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: AppColors.textTertiary.withOpacity(0.4),
                              size: 14,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today_rounded,
                                  size: 12, color: AppColors.textTertiary),
                              const SizedBox(width: 6),
                              Text(meeting.date, style: AppTypography.caption),
                              const SizedBox(width: 12),
                              Icon(Icons.access_time_rounded,
                                  size: 12, color: AppColors.textTertiary),
                              const SizedBox(width: 4),
                              Text(meeting.time, style: AppTypography.caption),
                              const SizedBox(width: 12),
                              Icon(Icons.timer_outlined,
                                  size: 12, color: AppColors.textTertiary),
                              const SizedBox(width: 4),
                              Text(meeting.duration, style: AppTypography.caption),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: meeting.state == MeetingCardState.completed
                                ? Text(
                                    meeting.executiveSummary,
                                    key: const ValueKey('summary'),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textTertiary,
                                      height: 1.4,
                                    ),
                                  )
                                : _buildProcessingContent(meeting),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Row(
                            children: [
                              SizedBox(
                                width: meeting.participants.length * 22.0 + 4,
                                height: 28,
                                child: Stack(
                                  children: List.generate(
                                    meeting.participants.length > 4
                                        ? 4
                                        : meeting.participants.length,
                                    (i) {
                                      return Positioned(
                                        left: i * 18.0,
                                        child: Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: _avatarColor(i),
                                            border: Border.all(
                                              color: AppColors.background,
                                              width: 2,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              meeting.participants[i].initials,
                                              style:
                                                  AppTypography.caption.copyWith(
                                                color: Colors.white,
                                                fontSize: 9,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const Spacer(),
                              _buildStatusBadge(meeting.state),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProcessingContent(Meeting meeting) {
    return Column(
      key: const ValueKey('processing'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          meeting.state.cardLabel,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.primaryPeach,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            minHeight: 7,
            value: meeting.state.progress,
            backgroundColor: AppColors.glass,
            color: AppColors.primaryPeach,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(MeetingCardState state) {
    switch (state) {
      case MeetingCardState.recording:
        return const Color(0xFFFF4D4D);
      case MeetingCardState.uploading:
        return AppColors.info;
      case MeetingCardState.transcribing:
        return AppColors.warning;
      case MeetingCardState.analyzingInsights:
        return AppColors.secondaryBlue;
      case MeetingCardState.generatingSummary:
        return AppColors.primaryPeach;
      case MeetingCardState.completed:
        return AppColors.success;
    }
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
