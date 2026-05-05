import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'course_detail_screen.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> _allCourses = [];
  List<dynamic> _filtered = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedType;
  String? _selectedStatus;
  late TabController _tabController;

  final List<String> _types = ['All', 'course', 'bootcamp', 'competition'];
  final List<String> _statuses = ['All', 'upcoming', 'ongoing', 'completed'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _types.length, vsync: this);
    _tabController.addListener(() {
      final type =
          _tabController.index == 0 ? null : _types[_tabController.index];
      setState(() => _selectedType = type);
      _filter();
    });
    _fetchCourses();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchCourses() async {
    try {
      final courses = await ApiService.getCourses();
      if (mounted) {
        setState(() {
          _allCourses = courses;
          _filtered = courses;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filter() {
    setState(() {
      _filtered = _allCourses.where((c) {
        final name =
            (c['name'] ?? c['title'] ?? '').toString().toLowerCase();
        final matchSearch =
            _searchQuery.isEmpty || name.contains(_searchQuery.toLowerCase());
        final matchType = _selectedType == null ||
            (c['type']?.toString().toLowerCase() ==
                _selectedType!.toLowerCase());
        final matchStatus = _selectedStatus == null ||
            (c['status']?.toString().toLowerCase() ==
                _selectedStatus!.toLowerCase());
        return matchSearch && matchType && matchStatus;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Programs',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppTheme.primary.withOpacity(0.4)),
                  ),
                  child: Text(
                    '${_filtered.length} found',
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              onChanged: (v) {
                _searchQuery = v;
                _filter();
              },
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Search programs...',
                prefixIcon: Icon(Icons.search_rounded, size: 20),
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Type tabs
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            indicatorColor: AppTheme.primary,
            indicatorWeight: 2,
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textMuted,
            labelStyle: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 13),
            unselectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            tabs: _types
                .map((t) => Tab(text: t == 'All' ? 'All' : _capitalize(t)))
                .toList(),
          ),
          // Status filter
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _statuses
                    .map((s) => _StatusChip(
                          label: s == 'All' ? 'All Status' : _capitalize(s),
                          selected: (s == 'All' && _selectedStatus == null) ||
                              _selectedStatus == s,
                          onTap: () {
                            setState(
                                () => _selectedStatus = s == 'All' ? null : s);
                            _filter();
                          },
                        ))
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // List
          Expanded(
            child: _isLoading
                ? const TerminalLoader(message: 'Loading programs...')
                : _filtered.isEmpty
                    ? _EmptyState()
                    : RefreshIndicator(
                        color: AppTheme.primary,
                        backgroundColor: AppTheme.bgCard,
                        onRefresh: _fetchCourses,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
                          itemCount: _filtered.length,
                          itemBuilder: (ctx, i) => CourseCard(
                            course: _filtered[i],
                            onTap: () {
                              final id = _filtered[i]['id'];
                              if (id != null) {
                                Navigator.push(
                                  ctx,
                                  MaterialPageRoute(
                                    builder: (_) => CourseDetailScreen(
                                      courseId: int.parse(id.toString()),
                                      courseBasic: _filtered[i],
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _StatusChip(
      {required this.label,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primary.withOpacity(0.15)
              : AppTheme.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.borderColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppTheme.primary : AppTheme.textSecondary,
            fontSize: 12,
            fontWeight:
                selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_off_rounded,
                size: 48, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 16),
          const Text(
            'No programs found',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try adjusting your filters',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
