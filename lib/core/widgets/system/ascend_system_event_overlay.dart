import 'dart:async';

import 'package:ascend/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum AscendSystemEventKind { reward, levelUp, trialUnlocked, bossDefeated, alert }

class AscendSystemEvent {
  const AscendSystemEvent({
    required this.kind,
    required this.title,
    required this.message,
    this.detail,
    this.autoDismissAfter = const Duration(milliseconds: 1600),
  });

  final AscendSystemEventKind kind;
  final String title;
  final String message;
  final String? detail;
  final Duration? autoDismissAfter;
}

Future<void> showAscendSystemEventOverlay(
  BuildContext context, {
  required AscendSystemEvent event,
  bool reduceMotion = false,
  bool hapticsEnabled = true,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Fechar evento do Sistema',
    barrierColor: Colors.black.withValues(alpha: .42),
    transitionDuration: reduceMotion ? Duration.zero : const Duration(milliseconds: 180),
    pageBuilder: (dialogContext, _, __) => AscendSystemEventOverlay(
      event: event,
      hapticsEnabled: hapticsEnabled,
      onDismiss: () => Navigator.of(dialogContext).pop(),
    ),
    transitionBuilder: (_, animation, __, child) => FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
      child: ScaleTransition(
        scale: Tween<double>(begin: .96, end: 1).animate(animation),
        child: child,
      ),
    ),
  );
}

class AscendSystemEventOverlay extends StatefulWidget {
  const AscendSystemEventOverlay({
    super.key,
    required this.event,
    required this.onDismiss,
    this.hapticsEnabled = true,
  });

  final AscendSystemEvent event;
  final VoidCallback onDismiss;
  final bool hapticsEnabled;

  @override
  State<AscendSystemEventOverlay> createState() => _AscendSystemEventOverlayState();
}

class _AscendSystemEventOverlayState extends State<AscendSystemEventOverlay> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final delay = widget.event.autoDismissAfter;
    if (delay != null) _timer = Timer(delay, widget.onDismiss);
    if (widget.hapticsEnabled) {
      unawaited(HapticFeedback.mediumImpact());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final presentation = _presentationFor(widget.event.kind);
    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: Center(
          child: Semantics(
            liveRegion: true,
            label: '${widget.event.title}. ${widget.event.message}',
            child: Container(
              width: 312,
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
              decoration: BoxDecoration(
                color: AppColors.panelCore,
                border: Border(
                  top: BorderSide(color: presentation.color, width: 2),
                  left: BorderSide(color: AppColors.systemCyan.withValues(alpha: .78), width: 2),
                  right: BorderSide(color: presentation.color.withValues(alpha: .28)),
                  bottom: BorderSide(color: presentation.color.withValues(alpha: .28)),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(presentation.icon, color: presentation.color, size: 25),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.event.title.toUpperCase(),
                          style: TextStyle(color: presentation.color, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: .6),
                        ),
                        const SizedBox(height: 7),
                        Text(widget.event.message, style: Theme.of(context).textTheme.titleMedium),
                        if (widget.event.detail?.isNotEmpty == true) ...[
                          const SizedBox(height: 5),
                          Text(widget.event.detail!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Fechar evento',
                    onPressed: widget.onDismiss,
                    icon: const Icon(Icons.close_rounded, size: 18),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

_EventPresentation _presentationFor(AscendSystemEventKind kind) => switch (kind) {
  AscendSystemEventKind.reward => const _EventPresentation(Icons.workspace_premium_rounded, AppColors.rewardGold),
  AscendSystemEventKind.levelUp => const _EventPresentation(Icons.trending_up_rounded, AppColors.systemCyan),
  AscendSystemEventKind.trialUnlocked => const _EventPresentation(Icons.auto_awesome_rounded, AppColors.energyViolet),
  AscendSystemEventKind.bossDefeated => const _EventPresentation(Icons.shield_rounded, AppColors.successGreen),
  AscendSystemEventKind.alert => const _EventPresentation(Icons.warning_amber_rounded, AppColors.dangerRed),
};

class _EventPresentation {
  const _EventPresentation(this.icon, this.color);
  final IconData icon;
  final Color color;
}
