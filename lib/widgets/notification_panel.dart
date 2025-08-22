import 'package:flutter/material.dart';
import '../utils/theme.dart';

class NotificationPanel extends StatefulWidget {
  final VoidCallback onClose;

  const NotificationPanel({
    super.key,
    required this.onClose,
  });

  @override
  State<NotificationPanel> createState() => _NotificationPanelState();
}

class _NotificationPanelState extends State<NotificationPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _closePanel() {
    _animationController.reverse().then((_) {
      widget.onClose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              // Backdrop
              Positioned.fill(
                child: GestureDetector(
                  onTap: _closePanel,
                  child: Container(
                    color: Colors.black.withOpacity(0.5 * _fadeAnimation.value),
                  ),
                ),
              ),

              // Notification Panel Content
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Transform.translate(
                  offset: Offset(0, MediaQuery.of(context).size.height * _slideAnimation.value * 0.6),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.6,
                    decoration: const BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Handle Bar
                        Container(
                          margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 12),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),

                        // Header
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Notifications',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: AppTheme.textColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      // Clear all notifications
                                    },
                                    icon: const Icon(
                                      Icons.clear_all,
                                      color: AppTheme.textColor,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: _closePanel,
                                    icon: const Icon(
                                      Icons.close,
                                      color: AppTheme.textColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Notifications List
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            children: [
                              _buildNotificationItem(
                                'Gmail',
                                'New email from John Doe',
                                'Subject: Meeting Tomorrow',
                                '2 minutes ago',
                                Icons.email,
                                Colors.red,
                                isUnread: true,
                              ),
                              _buildNotificationItem(
                                'WhatsApp',
                                'Sarah sent you a message',
                                'Hey! Are you free for coffee later?',
                                '5 minutes ago',
                                Icons.chat,
                                Colors.green,
                                isUnread: true,
                              ),
                              _buildNotificationItem(
                                'Instagram',
                                'New follower',
                                '@tech_enthusiast started following you',
                                '15 minutes ago',
                                Icons.camera_alt,
                                Colors.purple,
                                isUnread: false,
                              ),
                              _buildNotificationItem(
                                'Calendar',
                                'Meeting reminder',
                                'Team standup in 30 minutes',
                                '1 hour ago',
                                Icons.calendar_today,
                                Colors.blue,
                                isUnread: false,
                              ),
                              _buildNotificationItem(
                                'Spotify',
                                'New playlist',
                                'Discover Weekly is ready',
                                '2 hours ago',
                                Icons.music_note,
                                Colors.green,
                                isUnread: false,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationItem(
    String appName,
    String title,
    String message,
    String time,
    IconData icon,
    Color color, {
    bool isUnread = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread 
            ? AppTheme.surfaceColor.withOpacity(0.8)
            : AppTheme.surfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnread ? color.withOpacity(0.3) : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // App Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),

          const SizedBox(width: 16),

          // Notification Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      appName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textColor,
                      ),
                    ),
                    if (isUnread) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textColor.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondaryColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Action Button
          IconButton(
            onPressed: () {
              // Dismiss notification
            },
            icon: const Icon(
              Icons.close,
              color: AppTheme.textSecondaryColor,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}
