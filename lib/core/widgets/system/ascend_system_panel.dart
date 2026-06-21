import 'package:ascend/core/theme/app_colors.dart';
import 'package:ascend/core/theme/ascend_design_tokens.dart';
import 'package:flutter/material.dart';

class AscendSystemPanel extends StatelessWidget {
  const AscendSystemPanel({
    super.key,
    required this.child,
    this.accent = AscendDesignTokens.systemLine,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final Color accent;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AscendDesignTokens.radiusPanel),
        border: Border.all(color: accent.withValues(alpha: 0.26)),
        boxShadow: AscendDesignTokens.elevatedSystemShadow(accent),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.075),
            AppColors.surface.withValues(alpha: 0.98),
            AppColors.background.withValues(alpha: 0.98),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                width: 92,
                height: 1,
                color: accent.withValues(alpha: 0.34),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                width: 1,
                height: 92,
                color: accent.withValues(alpha: 0.18),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
