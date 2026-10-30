import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils_helper.dart';
import '../../data/models/app_models.dart';

class ActivityDetailModal extends StatefulWidget {
  final ActivityInstance instance;
  final int indicatorMonth;
  final int indicatorYear;
  final Function(String? obs, String? motivo) onSaveNotes;
  final Function(String newName, String newDesc)? onEdit;
  final VoidCallback? onArchive;

  const ActivityDetailModal({
    super.key,
    required this.instance,
    required this.indicatorMonth,
    required this.indicatorYear,
    required this.onSaveNotes,
    this.onEdit,
    this.onArchive,
  });

  @override
  State<ActivityDetailModal> createState() => _ActivityDetailModalState();
}

class _ActivityDetailModalState extends State<ActivityDetailModal> {
  late TextEditingController _obsController;
  late TextEditingController _motivoController;
  bool _isEditing = false;
  late TextEditingController _nameEditController;
  late TextEditingController _descEditController;

  @override
  void initState() {
    super.initState();
    _obsController = TextEditingController(text: widget.instance.observaciones ?? '');
    _motivoController = TextEditingController(text: widget.instance.motivoNoRealizada ?? '');
    _nameEditController = TextEditingController(text: widget.instance.nombre);
    _descEditController = TextEditingController(text: widget.instance.descripcion);
  }

  @override
  void dispose() {
    _obsController.dispose();
    _motivoController.dispose();
    _nameEditController.dispose();
    _descEditController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final act = widget.instance;
    final String diaNombre = DateUtilsHelper.diasCompletos[act.day - 1];

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera con Estado y Acciones
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: act.done ? AppColors.verdeBg : AppColors.rojoBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: act.done ? AppColors.verde : AppColors.rojo),
                    ),
                    child: Text(
                      act.done ? '✔ Realizada' : '✖ Pendiente',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: act.done ? AppColors.verde : AppColors.rojo,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      if (!act.fija && widget.onEdit != null)
                        IconButton(
                          icon: Icon(_isEditing ? Icons.close : Icons.edit, color: AppColors.azul, size: 20),
                          tooltip: _isEditing ? 'Cancelar edición' : 'Editar actividad',
                          onPressed: () {
                            setState(() => _isEditing = !_isEditing);
                          },
                        ),
                      if (!act.fija && widget.onArchive != null)
                        IconButton(
                          icon: const Icon(Icons.archive_outlined, color: AppColors.rojo, size: 20),
                          tooltip: 'Archivar actividad',
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('¿Archivar actividad?'),
                                content: Text('La actividad "${act.nombre}" dejará de aparecer en la programación futura.'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.rojo),
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      Navigator.pop(context);
                                      widget.onArchive?.call();
                                    },
                                    child: const Text('Archivar'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.gris),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Modo Edición vs Visualización
              if (_isEditing) ...[
                const Text('Editar Actividad', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.azul)),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameEditController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _descEditController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onEdit?.call(_nameEditController.text, _descEditController.text);
                      setState(() => _isEditing = false);
                    },
                    child: const Text('Guardar Cambios'),
                  ),
                ),
                const SizedBox(height: 16),
              ] else ...[
                Text(
                  act.nombre,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.txt),
                ),
                const SizedBox(height: 4),
                Text(
                  act.descripcion,
                  style: const TextStyle(fontSize: 13, color: AppColors.gris),
                ),
              ],

              const SizedBox(height: 16),

              // Metadatos
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _MetaRow(label: 'Día programado:', value: diaNombre),
                    _MetaRow(label: 'Tipo:', value: act.fija ? '📌 Fija Obligatoria Diaria' : 'Estándar Flexible'),
                    if (act.orig != act.day)
                      _MetaRow(label: 'Reprogramada desde:', value: DateUtilsHelper.diasCompletos[act.orig - 1]),
                    if (act.completedAt != null)
                      _MetaRow(label: 'Completada el:', value: act.completedAt.toString().substring(0, 16)),
                    _MetaRow(label: 'Indicador Mes:', value: '${widget.indicatorMonth}%'),
                    _MetaRow(label: 'Indicador Año:', value: '${widget.indicatorYear}%'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Registro de Observaciones y Motivo de Incumplimiento
              const Text(
                'Observaciones y Novedades de Planta',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.txt),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _obsController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Añadir notas operativas, hallazgos o comentarios...',
                ),
              ),
              const SizedBox(height: 10),
              if (!act.done) ...[
                const Text(
                  'Motivo de no ejecución (si aplica):',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.rojo),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _motivoController,
                  decoration: const InputDecoration(
                    hintText: 'Ej. Parada de línea, falta de insumos...',
                  ),
                ),
                const SizedBox(height: 12),
              ],

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Guardar Observaciones'),
                  onPressed: () {
                    widget.onSaveNotes(
                      _obsController.text.trim().isEmpty ? null : _obsController.text.trim(),
                      _motivoController.text.trim().isEmpty ? null : _motivoController.text.trim(),
                    );
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;
  const _MetaRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.gris)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.txt)),
        ],
      ),
    );
  }
}
