import 'package:flutter/material.dart';
import '../models/posting.dart';
import '../utils/posting_constants.dart';
import '../utils/theme.dart';

/// A single card in the home feed representing one posting.
///
/// Shows position title, institute, location, deadline, employment type,
/// salary if available, source badge (Official/Heard), and poster footer.
class PostingCard extends StatelessWidget {
  final Posting posting;
  final VoidCallback? onTap;

  const PostingCard({super.key, required this.posting, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.border, width: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + Source badge row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    _buildTitle(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _SourceBadge(source: posting.source),
              ],
            ),
            const SizedBox(height: 4),

            // Institute · City line
            Text(
              '${posting.instituteName} · ${posting.city}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),

            // Employment type line (e.g. "Full-time permanent", "Part-time · 2 days/week")
            Text(
              _buildEmploymentLine(),
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF3C3489), // purple-ish accent
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),

            // Deadline + salary line
            Text(
              _buildDeadlineSalary(),
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 8),

            // Divider before footer
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 6),

            // Posted-by footer
            Text(
              _buildPostedByLine(),
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the main title, e.g. "Assistant Professor, Computer Science"
  String _buildTitle() {
    final position = PositionType.displayLabel(posting.positionType);
    return '$position, ${posting.discipline}';
  }

  /// Builds the employment line.
  /// For permanent: "Full-time permanent"
  /// For others with duration: "Part-time · 2 days/week, 1 semester"
  String _buildEmploymentLine() {
    final employment = EmploymentType.displayLabel(posting.employmentType);
    if (posting.duration != null && posting.duration!.isNotEmpty) {
      return '$employment · ${posting.duration}';
    }
    return employment;
  }

  /// Builds deadline + salary string.
  /// e.g. "30 Nov · 8-12 LPA"
  String _buildDeadlineSalary() {
    final deadlineStr = _formatDate(posting.deadline);
    if (posting.salaryRange != null && posting.salaryRange!.isNotEmpty) {
      return '$deadlineStr · ${posting.salaryRange}';
    }
    return deadlineStr;
  }

  /// Builds the "Posted by" footer line.
  /// e.g. "By IIIT Delhi HR · 2d ago" or "By Dr. R. Mehta, IIT Bombay · 1d ago"
  String _buildPostedByLine() {
    final timeAgo = _timeAgo(posting.createdAt);
    if (posting.postedByRole == PosterRole.recruiter) {
      // Recruiter: just show the institute HR/team name
      return 'By ${posting.postedByName} · $timeAgo';
    } else {
      // Faculty: show name and institute
      return 'By ${posting.postedByName}, ${posting.postedByInstitute} · $timeAgo';
    }
  }

  /// Formats a date as "30 Nov" (no year, since deadlines are near-term).
  String _formatDate(DateTime date) {
    const months = [
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
    return '${date.day} ${months[date.month - 1]}';
  }

  /// Returns a human-readable "time ago" string.
  /// e.g. "3h ago", "2d ago", "1w ago"
  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }
}

/// Small green or amber pill showing whether the posting is Official or Heard.
class _SourceBadge extends StatelessWidget {
  final String source;
  const _SourceBadge({required this.source});

  @override
  Widget build(BuildContext context) {
    final isOfficial = source == PostingSource.official;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isOfficial ? const Color(0xFFEAF3DE) : const Color(0xFFFAEEDA),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        isOfficial ? 'Official' : 'Heard',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: isOfficial ? const Color(0xFF27500A) : const Color(0xFF633806),
        ),
      ),
    );
  }
}
