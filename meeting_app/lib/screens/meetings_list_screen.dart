import 'dart:ui';

import 'package:flutter/material.dart';

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

  final List<Meeting> _meetings = MockDataProvider.meetings;

  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    IconData badgeIcon;
    String label;
    bool showSpinner = false;

    switch (status) {
      case 'uploaded':
        badgeColor = AppColors.info;
        badgeIcon = Icons.cloud_upload_rounded;
        label = 'Uploaded';
        break;
      case 'transcribing':
        badgeColor = AppColors.warning;
        badgeIcon = Icons.hourglass_top_rounded;
        label = 'Transcribing';
        showSpinner = true;
        break;
      case 'processing':
        badgeColor = AppColors.secondaryBlue;
        badgeIcon = Icons.auto_awesome_rounded;
        label = 'Processing';
        showSpinner = true;
        break;
      case 'completed':
        badgeColor = AppColors.success;
        badgeIcon = Icons.check_circle_rounded;
        label = 'Completed';
        break;
      default:
        badgeColor = AppColors.error;
        badgeIcon = Icons.error_rounded;
        label = 'Failed';
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
                    '${_meetings.length}',
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
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
      itemCount: _meetings.length,
      itemBuilder: (context, index) {
        final meeting = _meetings[index];
        return Padding(
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
            accentColor: _getStatusColor(meeting.status),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + arrow
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status dot
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getStatusColor(meeting.status),
                        boxShadow: [
                          BoxShadow(
                            color: _getStatusColor(meeting.status).withOpacity(0.5),
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

                // Date, time, duration row
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          size: 12, color: AppColors.textTertiary),
                      const SizedBox(width: 6),
                      Text(
                        meeting.date,
                        style: AppTypography.caption,
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.access_time_rounded,
                          size: 12, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        meeting.time,
                        style: AppTypography.caption,
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.timer_outlined,
                          size: 12, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        meeting.duration,
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Summary preview (only for completed)
                if (meeting.executiveSummary.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      meeting.executiveSummary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                        height: 1.4,
                      ),
                    ),
                  ),

                const SizedBox(height: 12),

                // Bottom: participants + status badge
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Row(
                    children: [
                      // Participant avatars (stacked)
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
                                      style: AppTypography.caption.copyWith(
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
                      _buildStatusBadge(meeting.status),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'uploaded':
        return AppColors.info;
      case 'transcribing':
        return AppColors.warning;
      case 'processing':
        return AppColors.secondaryBlue;
      case 'completed':
        return AppColors.success;
      default:
        return AppColors.error;
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
