import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class CourseDetailScreen extends StatefulWidget {
  final int courseId;
  final Map<String, dynamic>? courseBasic;

  const CourseDetailScreen(
      {super.key, required this.courseId, this.courseBasic});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  Map<String, dynamic>? _details;
  bool _isLoading = true;
  bool _enrolling = false;
  bool _enrolled = false;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    try {
      final data = await ApiService.getCourseDetails(widget.courseId);
      if (mounted) setState(() { _details = data; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() { _details = widget.courseBasic; _isLoading = false; });
    }
  }

  Future<void> _enroll() async {
    final userId = Hive.box('authBox').get('user_id');
    if (userId == null) return;
    setState(() => _enrolling = true);
    try {
      final res = await ApiService.enroll(userId, widget.courseId);
      if (mounted) {
        if (res['success'] == true || res['message']?.toString().contains('enroll') == true) {
          setState(() => _enrolled = true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Successfully enrolled! 🎉'),
              backgroundColor: AppTheme.accent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res['message']?.toString() ?? 'Enrollment failed'),
              backgroundColor: Colors.red[700],
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connection error')),
        );
      }
    } finally {
      if (mounted) setState(() => _enrolling = false);
    }
  }

  Color _typeColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'bootcamp': return AppTheme.secondary;
      case 'competition': return AppTheme.warning;
      default: return AppTheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final course = _details ?? widget.courseBasic ?? {};
    final name = course['name'] ?? course['title'] ?? 'Program';
    final type = course['type']?.toString();
    final status = course['status']?.toString();
    final category = course['category']?.toString();
    final description = course['description']?.toString();
    final instructor = course['instructor']?.toString();
    final startDate = course['start_date']?.toString();
    final endDate = course['end_date']?.toString();
    final duration = course['duration']?.toString();
    final price = course['price']?.toString();
    final seats = course['seats']?.toString() ?? course['max_students']?.toString();
    final typeColor = _typeColor(type);

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: CustomScrollView(
        slivers: [
          // Hero header
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppTheme.bgCard,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.bgDark.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back_ios_rounded,
                    color: AppTheme.textPrimary, size: 18),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [typeColor.withOpacity(0.8), AppTheme.bgDark],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Opacity(
                        opacity: 0.1,
                        child: Icon(Icons.code_rounded, size: 200, color: typeColor),
                      ),
                    ),
                    Positioned(
                      bottom: 30,
                      left: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (type != null)
                            TagBadge(text: type.toUpperCase(), color: typeColor),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: MediaQuery.of(context).size.width - 80,
                            child: Text(
                              name,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: _isLoading
                ? const Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: TerminalLoader(message: 'Loading details...'),
                  )
                : Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status row
                        if (status != null || category != null)
                          Wrap(
                            spacing: 8,
                            children: [
                              if (status != null)
                                TagBadge(
                                  text: status.toUpperCase(),
                                  color: status == 'ongoing'
                                      ? AppTheme.accent
                                      : status == 'upcoming'
                                          ? AppTheme.primary
                                          : AppTheme.textMuted,
                                ),
                              if (category != null)
                                TagBadge(text: category, color: AppTheme.secondary),
                            ],
                          ),

                        if (description != null) ...[
                          const SizedBox(height: 20),
                          const Text(
                            'About This Program',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            description,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                              height: 1.6,
                            ),
                          ),
                        ],

                        const SizedBox(height: 20),
                        const Text(
                          'Program Details',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Detail cards
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppTheme.bgCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.borderColor),
                          ),
                          child: Column(
                            children: [
                              if (instructor != null)
                                _DetailRow(
                                    icon: Icons.person_outline_rounded,
                                    label: 'Instructor',
                                    value: instructor),
                              if (startDate != null)
                                _DetailRow(
                                    icon: Icons.calendar_today_outlined,
                                    label: 'Start Date',
                                    value: startDate),
                              if (endDate != null)
                                _DetailRow(
                                    icon: Icons.event_outlined,
                                    label: 'End Date',
                                    value: endDate),
                              if (duration != null)
                                _DetailRow(
                                    icon: Icons.timer_outlined,
                                    label: 'Duration',
                                    value: duration),
                              if (seats != null)
                                _DetailRow(
                                    icon: Icons.people_outline_rounded,
                                    label: 'Seats',
                                    value: seats),
                              if (price != null)
                                _DetailRow(
                                    icon: Icons.attach_money_rounded,
                                    label: 'Fee',
                                    value: price,
                                    isLast: true),
                              if (instructor == null &&
                                  startDate == null &&
                                  duration == null &&
                                  seats == null)
                                const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    'Detailed information coming soon.',
                                    style: TextStyle(color: AppTheme.textMuted),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),
                        _enrolled
                            ? Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppTheme.accent.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: AppTheme.accent.withOpacity(0.4)),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_circle_rounded,
                                        color: AppTheme.accent, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Successfully Enrolled!',
                                      style: TextStyle(
                                        color: AppTheme.accent,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : GradientButton(
                                text: 'ENROLL NOW',
                                onPressed: _enroll,
                                isLoading: _enrolling,
                                icon: Icons.school_rounded,
                              ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.textMuted, size: 18),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(height: 1, color: AppTheme.borderColor, indent: 16, endIndent: 16),
      ],
    );
  }
}
