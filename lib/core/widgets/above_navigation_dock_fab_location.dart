import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Mantem a acao flutuante acima do dock interno e da navegacao do sistema.
class AboveNavigationDockFabLocation extends FloatingActionButtonLocation {
  const AboveNavigationDockFabLocation();

  static const double _espacoDoDock = 160;

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry geometry) {
    final x = geometry.scaffoldSize.width - geometry.minInsets.right -
        geometry.floatingActionButtonSize.width - kFloatingActionButtonMargin;
    final y = math.max(
      kFloatingActionButtonMargin,
      geometry.contentBottom - geometry.minInsets.bottom -
          geometry.floatingActionButtonSize.height - _espacoDoDock,
    );
    return Offset(x, y);
  }
}
