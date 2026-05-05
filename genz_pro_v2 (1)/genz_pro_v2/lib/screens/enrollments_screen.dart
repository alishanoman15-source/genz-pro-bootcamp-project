import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'course_detail_screen.dart';

class EnrollmentsScreen extends StatefulWidget {
  const EnrollmentsScreen({super.key});

  @override
  State<EnrollmentsScreen> createState() => _EnrollmentsScreenState();
}

class _EnrollmentsScreenState extends State<EnrollmentsScreen> {
  List<dynamic> _enrollments = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchEnrollments();
  }

  Future<void> _fetchEnrollments() async {
    final userId = Hive.box('authBox').get('user_id');
    if (userId == null) {
      setState(() { _isLoading = false; _error = 'Not logged in'; });
      return;
    }
    try {
      final data = await ApiService.myEnrollments(userId);
      if (mounted) setState(() { _enrollments = data; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Enrollments',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (!_isLoading && _enrollments.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.secondary.withOpacity(0.4)),
                    ),
                    child: Text(
                      '${_enrollments.length} enrolled',
                      style: const TextStyle(
                        color: AppTheme.secondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const TerminalLoader(message: 'Loading your enrollments...')
                : _enrollments.isEmpty
                    ? _EmptyEnrollments()
                    : RefreshIndicator(
                        color: AppTheme.primary,
                        backgroundColor: AppTheme.bgCard,
                        onRefresh: _fetchEnrollments,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                          itemCount: _enrollments.length,
                          itemBuilder: (ctx, i) {
                            final e = _enrollments[i];
                            final courseName = e['course_name'] ??
                                e['name'] ??
                                e['program_name'] ??
                                'Program';
                            final enrollDate = e['enrolled_at'] ??
                                e['enrollment_date'] ??
                                e['created_at'];
                            final status = e['status']?.toString();
                            final courseId = e['course_id'] ?? e['id'];

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.bgCard,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppTheme.borderColor),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      gradient: AppTheme.primaryGradient,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${i + 1}',
                                        style: const TextStyle(
                                          color: AppTheme.bgDark,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          courseName.toString(),
                                          style: const TextStyle(
                                            color: AppTheme.textPrimary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (enrollDate != null) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            'Enrolled: $enrollDate',
                                            style: const TextStyle(
                                              color: AppTheme.textMuted,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                        if (status != null) ...[
                                          const SizedBox(height: 6),
                                          TagBadge(
                                            text: status.toUpperCase(),
                                            color: status == 'approved'
                                                ? AppTheme.accent
                                                : status == 'pending'
                                                    ? AppTheme.warning
                                                    : AppTheme.textMuted,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  if (courseId != null)
                                    GestureDetector(
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => CourseDetailScreen(
                                            courseId: int.parse(courseId.toString()),
                                            courseBasic: e,
                                          ),
                                        ),
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.open_in_new_rounded,
                                          color: AppTheme.primary,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _EmptyEnrollments extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: const Icon(Icons.school_outlined,
                size: 52, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Enrollments Yet',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Explore programs and enroll\nto start your learning journey',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textMuted, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}
