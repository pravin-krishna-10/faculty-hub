import 'package:flutter/material.dart';
import '../models/posting.dart';
import '../services/auth_service.dart';
import '../services/postings_service.dart';
import '../utils/theme.dart';
import '../widgets/posting_card.dart';
import 'login_screen.dart';
import 'posting_detail_screen.dart';
import '../models/posting_filters.dart';
import '../widgets/filter_bar.dart';
import '../widgets/segment_toggle.dart';
import '../widgets/feed_search_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PostingFilters _filters = const PostingFilters();
  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final postingsService = PostingsService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'FacultyHub',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textSecondary),
            tooltip: 'Sign out',
            onPressed: () async {
              await authService.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          FeedSearchBar(
            initialValue: _filters.searchQuery,
            onChanged: (value) {
              setState(() {
                _filters = _filters.copyWith(
                  searchQuery: value,
                  clearSearch: value == null,
                );
              });
            },
          ),
          SegmentToggle(
            selected: _filters.segment,
            onChanged: (newSegment) {
              setState(() {
                _filters = _filters.copyWith(segment: newSegment);
              });
            },
          ),
          FilterBar(
            filters: _filters,
            onFiltersChanged: (newFilters) {
              setState(() => _filters = newFilters);
            },
          ),
          Expanded(
            child: StreamBuilder<List<Posting>>(
              stream: postingsService.watchActivePostings(filters: _filters),
              builder: (context, snapshot) {
                // Loading state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Error state
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Could not load openings.\n${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final allPostings = snapshot.data ?? [];
                final postings = _filters
                    .applySearch(allPostings)
                    .cast<Posting>();

                // Empty state
                if (postings.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 48,
                            color: AppColors.textTertiary,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No openings match your filters.',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Loaded state
                return ListView.builder(
                  itemCount: postings.length,
                  itemBuilder: (context, index) {
                    return PostingCard(
                      posting: postings[index],
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                PostingDetailScreen(posting: postings[index]),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
