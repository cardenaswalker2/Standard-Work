import 'package:flutter/material.dart';
import '../../data/models/app_models.dart';

class ReprogrammingDialog extends StatefulWidget {
  final ActivityInstance instance;
  final Function(int toDay, String motivo) onConfirm;

  const ReprogrammingDialog({
    super.key,
    required this.instance,
    required this.onConfirm,
  });

  @override
  State<ReprogrammingDialog> createState() => _ReprogrammingDialogState();
}

class _ReprogrammingDialogState extends State<ReprogrammingDialog> {
  late int _selectedTargetDay;
  final TextEditingController _motivoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final List<Map<String, dynamic>> _days = [
    {'day': 1, 'name': 'Lunes'},
    {'day': 2, 'name': 'Martes'},
    {'day': 3, 'name': 'Miércoles'},
    {'day': 4, 'name': 'Jueves'},
    {'day': 5, 'name': 'Viernes'},
  ];

  @override
  void initState() {
    super.initState();
    // Seleccionar por defecto un día diferente al actual
    _selectedTargetDay = widget.instance.day < 5 ? widget.instance.day + 1 : 1;
  }

  @override
  void dispose() {
    _motivoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.instance.fija) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.lock_rounded, color: Color(0xFFDC2626)),
            SizedBox(width: 8),
            Text('Actividad Fija Inmutable'),
          ],
        ),
        content: const Text(
          'Esta actividad está catalogada como Estándar Fijo de Operación. Por directriz de planta, las actividades fijas no pueden ser reprogramadas.',
          style: TextStyle(fontSize: 14, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      );
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.edit_calendar_rounded, color: Color(0xFFF59E0B), size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Reprogramación Justificada',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            widget.instance.nombre,
            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Seleccionar nuevo día de ejecución:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _days.map((d) {
                  final dayNum = d['day'] as int;
                  final isCurrent = dayNum == widget.instance.day;
                  final isSelected = dayNum == _selectedTargetDay;

                  return ChoiceChip(
                    label: Text(d['name']),
                    selected: isSelected,
                    onSelected: isCurrent
                        ? null
                        : (val) {
                            if (val) {
                              setState(() => _selectedTargetDay = dayNum);
                            }
                          },
                    selectedColor: const Color(0xFF002F6C),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isCurrent ? Colors.grey.shade400 : const Color(0xFF1E293B)),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              const Text(
                'Motivo justificado (Requerido por supervisión):',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _motivoController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Explica claramente por qué se requiere mover esta actividad...',
                  hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF002F6C), width: 1.5),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                ),
                validator: (val) {
                  if (val == null || val.trim().length < 6) {
                    return 'El motivo debe tener al menos 6 caracteres.';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: Color(0xFF64748B))),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onConfirm(_selectedTargetDay, _motivoController.text.trim());
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF002F6C),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          child: const Text('Confirmar Reprogramación', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

