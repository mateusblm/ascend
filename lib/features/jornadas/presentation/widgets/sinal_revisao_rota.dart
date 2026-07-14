import 'package:ascend/core/theme/app_colors.dart';
import 'package:ascend/features/jornadas/domain/jornada.dart';
import 'package:flutter/material.dart';

class SinalRevisaoRota extends StatelessWidget {
  const SinalRevisaoRota({
    super.key,
    required this.revisao,
    required this.onTap,
  });
  final RevisaoRotaJornada revisao;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.alt_route_rounded, size: 16, color: AppColors.amber),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${revisao.totalDeAjustes} ajuste${revisao.totalDeAjustes == 1 ? '' : 's'} na rota',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const Text(
            'REVISAR',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.amber,
            ),
          ),
        ],
      ),
    ),
  );
}
