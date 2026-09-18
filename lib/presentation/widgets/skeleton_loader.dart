import 'package:flutter/material.dart';
import 'package:planpal/core/constants/app_colors.dart';
import 'package:planpal/core/constants/app_sizes.dart';

/// A fluid, GPU-accelerated Shimmer effect container.
/// Wrap any subtree with [Shimmer] to animate child skeleton elements.
class Shimmer extends StatefulWidget {
  const Shimmer({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1400),
  });

  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultBase = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : const Color(0xFFE2E8F0);
    final defaultHighlight = isDark
        ? Colors.white.withValues(alpha: 0.16)
        : const Color(0xFFF8FAFC);

    final base = widget.baseColor ?? defaultBase;
    final highlight = widget.highlightColor ?? defaultHighlight;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: const Alignment(-2.0, -0.3),
              end: const Alignment(2.0, 0.3),
              colors: [base, highlight, base],
              stops: const [0.1, 0.5, 0.9],
              transform: _SlidingGradientTransform(_controller.value),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform(this.slidePercent);
  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * (slidePercent * 2 - 1), 0, 0);
  }
}

/// A generic rounded rectangular skeleton placeholder box.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8.0,
  });

  final double? width;
  final double? height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// A circular skeleton placeholder (e.g. for avatars and circular icons).
class SkeletonCircle extends StatelessWidget {
  const SkeletonCircle({
    super.key,
    required this.diameter,
  });

  final double diameter;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
        shape: BoxShape.circle,
      ),
    );
  }
}

/// A horizontal rounded line skeleton (e.g. for text titles and captions).
class SkeletonLine extends StatelessWidget {
  const SkeletonLine({
    super.key,
    this.width,
    this.height = 12.0,
    this.borderRadius = 6.0,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(
      width: width,
      height: height,
      borderRadius: borderRadius,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pre-built Screen Skeletons
// ─────────────────────────────────────────────────────────────────────────────

/// Skeleton task row mimicking [TaskListItem].
class SkeletonTaskCard extends StatelessWidget {
  const SkeletonTaskCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: const Row(
        children: [
          // Checkbox skeleton
          SkeletonBox(width: 22, height: 22, borderRadius: 6),
          SizedBox(width: 14),
          // Title and Subtitle skeleton
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLine(width: 160, height: 14),
                SizedBox(height: 8),
                Row(
                  children: [
                    SkeletonLine(width: 65, height: 10),
                    SizedBox(width: 10),
                    SkeletonLine(width: 50, height: 10),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          // Priority badge skeleton
          SkeletonBox(width: 56, height: 22, borderRadius: 12),
        ],
      ),
    );
  }
}

/// Skeleton list of task cards with Shimmer.
class SkeletonTaskList extends StatelessWidget {
  const SkeletonTaskList({super.key, this.count = 5});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        itemCount: count,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, _) => const SkeletonTaskCard(),
      ),
    );
  }
}

/// Skeleton member tile mimicking [_MemberTile] in WorkspaceHubScreen.
class SkeletonMemberTile extends StatelessWidget {
  const SkeletonMemberTile({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: const Row(
        children: [
          SkeletonCircle(diameter: 40),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLine(width: 110, height: 14),
                SizedBox(height: 6),
                SkeletonLine(width: 150, height: 11),
              ],
            ),
          ),
          SkeletonBox(width: 50, height: 20, borderRadius: 10),
        ],
      ),
    );
  }
}

/// Skeleton list of workspace members with Shimmer.
class SkeletonMemberList extends StatelessWidget {
  const SkeletonMemberList({super.key, this.count = 3});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Column(
        children: List.generate(
          count,
          (_) => const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: SkeletonMemberTile(),
          ),
        ),
      ),
    );
  }
}

/// Skeleton conversation row mimicking [ConversationItem].
class SkeletonConversationItem extends StatelessWidget {
  const SkeletonConversationItem({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: isDark ? AppColors.darkBackground : Colors.white,
      child: const Row(
        children: [
          SkeletonCircle(diameter: 48),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonLine(width: 120, height: 14),
                    SkeletonLine(width: 40, height: 10),
                  ],
                ),
                SizedBox(height: 8),
                SkeletonLine(width: 200),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton list of conversations with Shimmer.
class SkeletonConversationList extends StatelessWidget {
  const SkeletonConversationList({super.key, this.count = 6});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: count,
        separatorBuilder: (_, _) => const Divider(height: 1, indent: 76),
        itemBuilder: (_, _) => const SkeletonConversationItem(),
      ),
    );
  }
}

/// Skeleton document card mimicking documents in [DocumentsNotesSheet].
class SkeletonDocCard extends StatelessWidget {
  const SkeletonDocCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: const Row(
        children: [
          SkeletonBox(width: 38, height: 38, borderRadius: 10),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLine(width: 170, height: 14),
                SizedBox(height: 6),
                SkeletonLine(width: 100, height: 11),
              ],
            ),
          ),
          SkeletonBox(width: 16, height: 16, borderRadius: 4),
        ],
      ),
    );
  }
}

/// Skeleton document list with Shimmer.
class SkeletonDocList extends StatelessWidget {
  const SkeletonDocList({super.key, this.count = 4});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: count,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (_, _) => const SkeletonDocCard(),
      ),
    );
  }
}

/// Skeleton activity item mimicking [ActivityItemWidget].
class SkeletonActivityTile extends StatelessWidget {
  const SkeletonActivityTile({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: const Row(
        children: [
          SkeletonCircle(diameter: 32),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLine(width: 160, height: 13),
                SizedBox(height: 6),
                SkeletonLine(width: 80, height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton profile view with Shimmer.
class SkeletonProfileView extends StatelessWidget {
  const SkeletonProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Shimmer(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(height: 40),
            // Avatar
            Center(child: SkeletonCircle(diameter: 88)),
            SizedBox(height: 16),
            // Name
            Center(child: SkeletonLine(width: 140, height: 18)),
            SizedBox(height: 8),
            // Role
            Center(child: SkeletonLine(width: 100)),
            SizedBox(height: 28),
            // 3 Stat cards
            Row(
              children: [
                Expanded(child: SkeletonBox(height: 68, borderRadius: 12)),
                SizedBox(width: 12),
                Expanded(child: SkeletonBox(height: 68, borderRadius: 12)),
                SizedBox(width: 12),
                Expanded(child: SkeletonBox(height: 68, borderRadius: 12)),
              ],
            ),
            SizedBox(height: 32),
            // Activity section header
            Align(
              alignment: Alignment.centerLeft,
              child: SkeletonLine(width: 120, height: 16),
            ),
            SizedBox(height: 12),
            // Activity items
            SkeletonBox(height: 52, borderRadius: 12),
            SizedBox(height: 8),
            SkeletonBox(height: 52, borderRadius: 12),
            SizedBox(height: 8),
            SkeletonBox(height: 52, borderRadius: 12),
          ],
        ),
      ),
    );
  }
}

/// Skeleton list of chat bubbles for [ConversationDetailScreen].
class SkeletonChatBubbleList extends StatelessWidget {
  const SkeletonChatBubbleList({super.key, this.count = 6});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: count,
        itemBuilder: (_, i) {
          final isOwn = i % 2 == 1;
          return Align(
            alignment: isOwn ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkSurface
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment:
                    isOwn ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  SkeletonLine(
                    width: (i % 3 == 0) ? 180 : ((i % 3 == 1) ? 120 : 220),
                    height: 14,
                  ),
                  const SizedBox(height: 6),
                  const SkeletonLine(width: 45, height: 9),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
