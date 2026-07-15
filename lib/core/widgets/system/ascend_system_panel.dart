import 'package:ascend/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AscendSystemPanel extends StatelessWidget {
  const AscendSystemPanel({
    super.key,
    required this.child,
    this.accent = AppColors.ascension,
    this.padding = const EdgeInsets.all(16),
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderStrong),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                width: 28,
                height: 2,
                color: accent,
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                width: 1,
                height: 28,
                color: AppColors.borderStrong,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
