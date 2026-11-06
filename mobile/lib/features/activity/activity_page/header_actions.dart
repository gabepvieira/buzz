part of '../activity_page.dart';

class _ActivityMenuButton<T> extends StatelessWidget {
  const _ActivityMenuButton({
    required this.value,
    required this.options,
    required this.onChanged,
    required this.controlKey,
    required this.popoverKey,
    required this.semanticLabel,
    required this.active,
  });
  final T value;
  final Map<T, String> options;
  final ValueChanged<T> onChanged;
  final String controlKey, popoverKey, semanticLabel;
  final bool active;
  String get label => options[value]!;

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final textScaler = MediaQuery.textScalerOf(context);
      final height = max(48.0, textScaler.scale(16) * 1.4 + 16);
      final labelWidth = (TextPainter(
        text: TextSpan(
          text: label,
          style: filterChipTextStyle.copyWith(fontWeight: FontWeight.w600),
        ),
        textScaler: textScaler,
        textDirection: Directionality.of(context),
      )..layout()).width;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: IosMessageCreateButton(
          key: ValueKey(controlKey),
          label: label,
          labelFontSize: textScaler.scale(16),
          icon: 'chevronDown',
          showIconWithLabel: true,
          eagerGestures: false,
          accessibilityLabel: semanticLabel,
          width: labelWidth + 56,
          height: height - 8,
          plain: false,
          fillWidth: true,
          deferMenuActions: false,
          selectedIndex: options.keys.toList().indexOf(value),
          actions: [
            for (final entry in options.entries)
              (
                label: entry.value,
                symbol: '',
                onPressed: () => onChanged(entry.key),
              ),
          ],
        ),
      );
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 160),
      child: Builder(
        builder: (buttonContext) => TextButton(
          key: ValueKey(controlKey),
          style: TextButton.styleFrom(
            minimumSize: const Size(48, 48),
            foregroundColor: !active
                ? context.colors.onSurface
                : context.colors.primary,
            backgroundColor: !active
                ? context.controlSurface
                : context.colors.primaryContainer,
          ),
          onPressed: () async {
            final selected = await showAnchoredPopover<T>(
              context: buttonContext,
              width: 240,
              alignment: AnchoredPopoverAlignment.start,
              surfaceKey: ValueKey(popoverKey),
              items: [
                for (final entry in options.entries)
                  PopupMenuItem(
                    value: entry.key,
                    height: Grid.xl,
                    child: Row(
                      children: [
                        Expanded(child: Text(entry.value)),
                        if (value == entry.key)
                          const Icon(BuzzIcons.check, size: 16),
                      ],
                    ),
                  ),
              ],
            );
            if (buttonContext.mounted && selected != null) onChanged(selected);
          },
          child: Semantics(
            label: semanticLabel,
            selected: active,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: Grid.quarter),
                const Icon(BuzzIcons.chevronDown, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Overflow menu for bulk read actions.
class _InboxOptionsButton extends StatelessWidget {
  final int unreadCount;
  final VoidCallback onMarkAllRead;

  const _InboxOptionsButton({
    required this.unreadCount,
    required this.onMarkAllRead,
  });

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return IosMessageCreateButton(
        key: const ValueKey('activity-options-menu'),
        icon: 'more',
        accessibilityLabel: 'Activity options',
        width: 44,
        height: 44,
        plain: false,
        deferMenuActions: false,
        actions: [
          (
            label: 'Mark all as read',
            symbol: '',
            onPressed: unreadCount > 0 ? onMarkAllRead : null,
          ),
        ],
      );
    }
    return Builder(
      builder: (buttonContext) => IconButton(
        key: const ValueKey('activity-options-menu'),
        tooltip: 'Activity options',
        color: navigationPrimaryForeground(context),
        padding: const EdgeInsets.symmetric(horizontal: Grid.xxs),
        constraints: const BoxConstraints.tightFor(
          width: Grid.xl,
          height: Grid.xl,
        ),
        icon: const Icon(BuzzIcons.ellipsis, size: 20),
        onPressed: () async {
          final selected = await showAnchoredPopover<String>(
            context: buttonContext,
            width: 216,
            alignment: AnchoredPopoverAlignment.end,
            surfaceKey: const ValueKey('activity-options-popover'),
            items: [
              PopupMenuItem(
                value: 'mark-all-read',
                enabled: unreadCount > 0,
                child: Row(
                  children: [
                    const Expanded(child: Text('Mark all as read')),
                    if (unreadCount > 0)
                      Text(
                        '$unreadCount',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
          if (!buttonContext.mounted || selected == null) return;
          if (selected == 'mark-all-read') onMarkAllRead();
        },
      ),
    );
  }
}

class _UnreadFilterButton extends StatelessWidget {
  const _UnreadFilterButton({required this.selected, required this.onPressed});
  final bool selected;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final scaler = MediaQuery.textScalerOf(context);
      final height = max(48.0, scaler.scale(16) * 1.4 + 16);
      final width =
          (TextPainter(
            text: TextSpan(
              text: 'Unread',
              style: filterChipTextStyle.copyWith(fontWeight: FontWeight.w600),
            ),
            textScaler: scaler,
            textDirection: Directionality.of(context),
          )..layout()).width +
          32;
      return IosGlassNavigationButton(
        key: const ValueKey('activity-unread-filter'),
        icon: IosGlassNavigationIcon.more,
        label: 'Unread',
        semanticLabel: 'Unread',
        isSelected: selected,
        onPressed: onPressed,
        width: width,
        height: height,
        controlSize: height - 8,
        fillWidth: true,
        foregroundColor: context.colors.primary,
      );
    }
    return FilterChip(
      key: const ValueKey('activity-unread-filter'),
      label: const Text('Unread'),
      selected: selected,
      showCheckmark: false,
      shape: const StadiumBorder(),
      side: BorderSide.none,
      onSelected: (_) => onPressed(),
    );
  }
}
