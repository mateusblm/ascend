import 'package:ascend/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/quest_model.dart';
import '../quest_controller.dart';

class AddQuestModal extends ConsumerStatefulWidget {
  const AddQuestModal({super.key});

  @override
  ConsumerState<AddQuestModal> createState() => _AddQuestModalState();
}

class _AddQuestModalState extends ConsumerState<AddQuestModal> {
  final _controller = TextEditingController();
  AttributeType _selectedAttribute = AttributeType.strength;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20, left: 20, right: 20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("NOVA MISSÃO", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)),
          const SizedBox(height: 20),
          
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: "NOME DA MISSÃO",
              labelStyle: TextStyle(color: Colors.white38),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.neonBlue)),
            ),
          ),
          
          const SizedBox(height: 20),
          
          const Text("ATRIBUTO DE RECOMPENSA", style: TextStyle(fontSize: 12, color: Colors.white38)),
          DropdownButton<AttributeType>(
            value: _selectedAttribute,
            isExpanded: true,
            dropdownColor: AppColors.background,
            items: AttributeType.values.map((attr) {
              return DropdownMenuItem(
                value: attr,
                child: Text(attr.name.toUpperCase(), style: const TextStyle(color: AppColors.neonBlue)),
              );
            }).toList(),
            onChanged: (val) => setState(() => _selectedAttribute = val!),
          ),
          
          const SizedBox(height: 30),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonBlue),
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  ref.read(questProvider.notifier).addQuest(
                    _controller.text, 
                    _selectedAttribute, 
                    30 // XP padrão por quest criada
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text("ADICIONAR AO SISTEMA", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
