import 'package:ascend/core/theme/app_colors.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:ascend/features/quests/presentation/quest_controller.dart';
import 'package:ascend/features/jornadas/presentation/jornada_controller.dart';
import 'package:ascend/features/jornadas/domain/jornada.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddQuestModal extends ConsumerStatefulWidget {
  const AddQuestModal({super.key});

  @override
  ConsumerState<AddQuestModal> createState() => _AddQuestModalState();
}

class _AddQuestModalState extends ConsumerState<AddQuestModal> {
  final _controller = TextEditingController();
  AttributeType _selectedAttribute = AttributeType.strength;
  String? _jornadaSelecionada;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jornadas = ref.watch(jornadaProvider).jornadas
        .where((jornada) => jornada.estaAtiva)
        .toList(growable: false);
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.backgroundElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Nova quest',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Crie uma missao simples para manter o ritmo de hoje.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          _buildPersonalForm(jornadas),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                if (_controller.text.trim().isEmpty) return;
                ref
                    .read(questProvider.notifier)
                    .addPersonalQuest(
                      _controller.text.trim(),
                      _selectedAttribute,
                      personalQuestDefaultXp,
                      jornadaId: _jornadaSelecionada,
                    );
                Navigator.pop(context);
              },
              child: const Text('Criar quest'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalForm(List<Jornada> jornadas) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          decoration: const InputDecoration(
            labelText: 'Nome da quest',
            hintText: 'Ex.: treino de 30 minutos',
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Atributo de recompensa',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Cada quest concluida da XP e reforca um atributo do personagem.',
          style: TextStyle(
            fontSize: 12.5,
            color: AppColors.textSecondary,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<AttributeType>(
          initialValue: _selectedAttribute,
          dropdownColor: AppColors.backgroundElevated,
          items: AttributeType.values.map((attr) {
            return DropdownMenuItem(
              value: attr,
              child: Text(attr.name.toUpperCase()),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedAttribute = val!),
          decoration: const InputDecoration(labelText: 'Atributo'),
        ),
        if (jornadas.isNotEmpty) ...[
          const SizedBox(height: 16),
          DropdownButtonFormField<String?>(
            initialValue: _jornadaSelecionada,
            dropdownColor: AppColors.backgroundElevated,
            decoration: const InputDecoration(labelText: 'Vincular a Jornada'),
            items: [
              const DropdownMenuItem<String?>(value: null, child: Text('Sem Jornada')),
              ...jornadas.map(
                (jornada) => DropdownMenuItem<String?>(
                  value: jornada.id,
                  child: Text(jornada.titulo),
                ),
              ),
            ],
            onChanged: (valor) => setState(() => _jornadaSelecionada = valor),
          ),
        ],
      ],
    );
  }
}
