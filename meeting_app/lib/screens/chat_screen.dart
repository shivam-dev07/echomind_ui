import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/mock_data.dart';
import '../core/theme.dart';
import '../core/widgets.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Load sample chat history
    for (final msg in MockDataProvider.chatHistory) {
      _messages.add(ChatMessage(
        text: msg.text,
        isUser: msg.isUser,
        timestamp: DateTime.now(),
      ));
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isLoading) return;

    _messageController.clear();

    setState(() {
      _messages.add(ChatMessage(
        text: message,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });
    _scrollToBottom();

    // Simulate AI thinking delay
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    // Smart mock responses based on keywords
    String response;
    final lower = message.toLowerCase();

    if (lower.contains('suraj') || lower.contains('task')) {
      response = 'In the Product Strategy Meeting on April 7, you assigned Suraj the task of researching competitive dairy brands and pricing models. The due date is April 16, 2026.';
    } else if (lower.contains('when is the next meeting') ||
        lower.contains('next meeting')) {
      response =
          'Your next meeting is Regional Sales Forecast Sync on Apr 12 at 11:00 AM.';
    } else if (lower.contains('upcoming') || lower.contains('meeting') && lower.contains('list')) {
      response = 'Here are your upcoming meetings:\n\n• April 15 – Review interactive plots with Jeremy\n• April 16 – Review revenue insights with Priya\n• April 17 – Amul strategy follow-up meeting\n• April 20 – Q1 board presentation';
    } else if (lower.contains('revenue') || lower.contains('q1')) {
      response = 'Based on the Q1 Revenue Review (April 5):\n\n📊 Total Revenue: ₹42.3 Cr (8% above target)\n📈 Premium segment grew 22%\n💰 Gross margin: 34.2%\n⚠️ Operating expenses up 5.1%\n\nThe team recommended allocating 15% more budget to premium product marketing.';
    } else if (lower.contains('sprint') || lower.contains('engineering')) {
      response = 'Sprint 14 Retrospective (April 3):\n\n✅ Velocity: 89%\n🐛 12 bugs resolved (2 critical)\n🧪 Test coverage: 72% → 78%\n🚀 Deployment time: 18 min avg\n\nKey decisions: Adopt trunk-based development, introduce automated performance testing.';
    } else if (lower.contains('jacob') || lower.contains('frontend')) {
      response = 'Jacob was assigned to work on the front end of the Amul Milk and Dairy Products website. Due date: April 14, 2026. This was discussed in the Product Strategy Meeting on April 7.';
    } else if (lower.contains('decision') || lower.contains('amul')) {
      response = 'Key decisions from the Amul Product Strategy Meeting:\n\n1. Build a new website for Amul Dairy Products\n2. Analyze revenue data for strategic insights\n3. Conduct follow-up meeting on April 17\n4. Use React + Node.js stack for the platform';
    } else {
      response = 'Based on your meeting history, I can help with questions about:\n\n• Product Strategy (Amul Dairy Platform)\n• Q1 Revenue Review\n• Sprint 14 Retrospective\n• Design Review progress\n• Client Onboarding status\n\nWhat would you like to know more about?';
    }

    setState(() {
      _messages.add(ChatMessage(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      ));
      _isLoading = false;
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: const AppLogoHeader(),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Assistant', style: AppTypography.displayMedium),
                        const SizedBox(height: 4),
                        Text(
                          'Ask questions about your meetings',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // AI badge
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryPeach.withOpacity(0.15),
                          AppColors.secondaryBlue.withOpacity(0.08),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: AppColors.primaryPeach.withOpacity(0.15),
                      ),
                    ),
                    child: const GlowIcon(
                      icon: Icons.auto_awesome_rounded,
                      color: AppColors.primaryPeach,
                      size: 22,
                      glowRadius: 10,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isLoading) {
                    return _buildTypingIndicator();
                  }
                  return _buildMessageBubble(_messages[index]);
                },
              ),
            ),

            // Input
            _buildChatInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryPeach.withOpacity(0.15),
                    AppColors.secondaryBlue.withOpacity(0.08),
                  ],
                ),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.primaryPeach,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: AssistantMessageBubble(
              text: message.text,
              isUser: message.isUser,
              isError: message.isError,
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 10),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                color: AppColors.primaryPeach.withOpacity(0.15),
                border: Border.all(
                  color: AppColors.primaryPeach.withOpacity(0.1),
                ),
              ),
              child: Center(
                child: Text(
                  MockDataProvider.userInitials,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primaryPeach,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryPeach.withOpacity(0.15),
                  AppColors.secondaryBlue.withOpacity(0.08),
                ],
              ),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.primaryPeach,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryPeach.withOpacity(0.06),
                  AppColors.secondaryBlue.withOpacity(0.03),
                ],
              ),
              borderRadius: BorderRadius.circular(AppRadius.lg).copyWith(
                bottomLeft: const Radius.circular(4),
              ),
              border: Border.all(
                color: AppColors.primaryPeach.withOpacity(0.08),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Thinking',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(width: 8),
                const _AnimatedDots(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatInput() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.8),
            border: const Border(
              top: BorderSide(color: AppColors.glassBorder, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.glass,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: TextField(
                        controller: _messageController,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Ask about your meetings...',
                          hintStyle: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textTertiary.withOpacity(0.5),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _sendMessage,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _isLoading ? null : AppColors.primaryGradient,
                    color: _isLoading ? AppColors.surfaceElevated : null,
                    boxShadow: _isLoading
                        ? null
                        : AppShadows.glow(AppColors.primaryPeach),
                  ),
                  child: Icon(
                    Icons.arrow_upward_rounded,
                    color: _isLoading ? AppColors.textTertiary : Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedDots extends StatefulWidget {
  const _AnimatedDots();

  @override
  State<_AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<_AnimatedDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final value = ((_controller.value + delay) % 1.0);
            final opacity = value < 0.5 ? value * 2 : 2 - value * 2;
            return Container(
              margin: EdgeInsets.only(left: index > 0 ? 4 : 0),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryPeach.withOpacity(0.3 + opacity * 0.7),
                    AppColors.primaryPink.withOpacity(0.2 + opacity * 0.5),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
  });
}
