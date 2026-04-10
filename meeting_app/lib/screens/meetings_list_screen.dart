import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/theme.dart';
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

  // Empty meetings list - no backend data
  final List<Map<String, dynamic>> _meetings = [];
  bool _isInitialLoading = false;

  String _formatDate(String? createdAt) {
    if (createdAt == null || createdAt.isEmpty) {
      return 'Unknown date';
    }

    final parsed = DateTime.tryParse(createdAt);
    if (parsed == null) {
      return createdAt;
    }

    const monthNames = [
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

    final local = parsed.toLocal();
    final month = monthNames[local.month - 1];
    final hour24 = local.hour;
    final minute = local.minute.toString().padLeft(2, '0');
    final suffix = hour24 >= 12 ? 'PM' : 'AM';
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;

    final day = local.day.toString().padLeft(2, '0');

    return '$month $day, ${local.year} • $hour12:$minute $suffix';
  }

  Widget _buildStatusBadge(String status) {
    if (status == 'uploaded') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.blue.withOpacity(0.45)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_upload, size: 14, color: Colors.blue),
            SizedBox(width: 6),
            Text(
              'Uploaded',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    if (status == 'transcribing') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.yellow.withOpacity(0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.yellow.withOpacity(0.45)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoActivityIndicator(radius: 7),
            SizedBox(width: 8),
            Text(
              'Transcribing',
              style: TextStyle(
                color: Colors.yellow,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    if (status == 'completed') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.green.withOpacity(0.45)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 14, color: Colors.green),
            SizedBox(width: 6),
            Text(
              'Completed',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.red.withOpacity(0.45)),
      ),
      child: const Text(
        'Failed',
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App Logo Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'EchoMind',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(
              'Your Meetings',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Text(
              'All your recorded meetings and summaries',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: _isInitialLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryPeach,
                    ),
                  )
                : _meetings.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.mic_none_rounded,
                          size: 64,
                          color: AppColors.textSecondary.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No meetings yet',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Record your first meeting to see it here',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    itemCount: _meetings.length,
                    itemBuilder: (context, index) {
                      final meeting = _meetings[index];
                      final title = (meeting['title'] ?? 'Untitled Meeting')
                          .toString();
                      final createdAt = meeting['created_at']?.toString();
                      final status = (meeting['status'] ?? 'uploaded')
                          .toString()
                          .toLowerCase();
                      final meetingId = meeting['id']?.toString();

                      return GestureDetector(
                        onTap: meetingId != null
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        SummaryScreen(meetingId: meetingId),
                                  ),
                                );
                              }
                            : null,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _formatDate(createdAt),
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _buildStatusBadge(status),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Icon(
                                  Icons.chevron_right,
                                  color: AppColors.textSecondary.withOpacity(0.5),
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
