import 'package:intl/intl.dart';
import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/domain/entities/discussion_post.dart';

class DiscussionMessage extends StatelessWidget {
  const new({required this.post, this.avatarRadius = 20, super.key});

  final DiscussionPost post;
  final double avatarRadius;

  static const List<Color> _avatarColors = [
    Color(0xFF8B5E3C),
    AppColors.accentBlue,
    AppColors.successGreen,
    Color(0xFFB8860B),
    Color(0xFFE6198C),
    Color(0xFF4A3B2A),
  ];

  String _timestamp(BuildContext context) {
    final time = post.createdAt;
    if (DateTime.now().difference(time).inMinutes < 1) {
      return context.l10n.communityJustNow;
    }
    final locale = Localizations.localeOf(context).languageCode;
    final clock = DateFormat.jm(locale).format(time).toLowerCase();
    return '$clock / ${DateFormat('d MMMM y', locale).format(time)}';
  }

  String? _roleLabel(BuildContext context) => switch (post.role) {
    DiscussionUserRole.educator => context.l10n.classDiscussionEducatorTag,
    DiscussionUserRole.admin => context.l10n.classDiscussionAdminTag,
    DiscussionUserRole.learner => null,
  };

  @override
  Widget build(BuildContext context) {
    final muted = context.textTheme.bodySmall?.copyWith(
      color: context.colors.onSurfaceVariant,
    );
    final name = post.senderName.trim();
    final initial = name.isEmpty ? '?' : name[0].toUpperCase();
    final role = _roleLabel(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: avatarRadius,
              backgroundColor:
                  _avatarColors[name.hashCode.abs() % _avatarColors.length],
              foregroundColor: Colors.white,
              child: Text(
                initial,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            const Gap(AppSpacing.s8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (role != null) ...[
                        const Gap(AppSpacing.s8),
                        _RoleTag(label: role),
                      ],
                    ],
                  ),
                  Text(
                    post.isEdited
                        ? '${_timestamp(context)} · '
                              '${context.l10n.classDiscussionEdited}'
                        : _timestamp(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: muted,
                  ),
                ],
              ),
            ),
          ],
        ),
        const Gap(AppSpacing.s8),
        _ExpandableText(text: post.content),
      ],
    );
  }
}

class _ExpandableText extends StatefulWidget {
  const new({required this.text});

  final String text;

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  static const int _collapsedLines = 6;

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final style = context.textTheme.bodyMedium;
    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: widget.text, style: style),
          maxLines: _collapsedLines,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(maxWidth: constraints.maxWidth);
        final overflows = painter.didExceedMaxLines;
        painter.dispose();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSize(
              duration: AppMotion.base,
              curve: AppMotion.standard,
              alignment: Alignment.topCenter,
              child: Text(
                widget.text,
                style: style,
                maxLines: _expanded ? null : _collapsedLines,
                overflow: _expanded ? null : TextOverflow.ellipsis,
              ),
            ),
            if (overflows)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  AppHaptics.selection();
                  setState(() => _expanded = !_expanded);
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.s4),
                  child: Text(
                    _expanded
                        ? context.l10n.classDiscussionSeeLess
                        : context.l10n.classDiscussionSeeMore,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: AppColors.accentBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _RoleTag extends StatelessWidget {
  const new({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s8,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.accentBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Text(
        label,
        style: context.textTheme.bodySmall?.copyWith(
          color: AppColors.accentBlue,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
