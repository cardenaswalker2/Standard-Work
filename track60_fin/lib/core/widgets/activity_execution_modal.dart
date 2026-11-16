import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../data/models/app_models.dart';
import '../../data/services/standard_work_provider.dart';
import 'action_plan_dialog.dart';
import 'activity_subtasks_modal.dart';

class ActivityExecutionModal extends StatefulWidget {
  final ActivityInstance instance;

  const ActivityExecutionModal({super.key, required this.instance});

  static Future<bool?> show({
    required BuildContext context,
    required ActivityInstance instance,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: ActivityExecutionModal(instance: instance),
      ),
    );
  }

  @override
  State<ActivityExecutionModal> createState() => _ActivityExecutionModalState();
}

class _ActivityExecutionModalState extends State<ActivityExecutionModal> {
  final _commentCtrl = TextEditingController();
  String? _photoPath;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.instance.observaciones != null) {
      _commentCtrl.text = widget.instance.observaciones!;
    }
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(source: source, imageQuality: 85);
      if (file != null) {
        setState(() => _photoPath = file.path);
      }
    } catch (e) {
      // Fallback para entornos web o pruebas sin cámara física
      setState(() => _photoPath = 'assets/images/fotos_track60/1F.jpg');
    }
  }

  Widget _buildPhotoThumbnail() {
    if (_photoPath == null) return const SizedBox.shrink();

    Widget img;
    if (kIsWeb || _photoPath!.startsWith('assets/')) {
      img = Image.asset(
        _photoPath!.startsWith('assets/') ? _photoPath! : 'assets/images/fotos_track60/1F.jpg',
        fit: BoxFit.cover,
      );
    } else {
      img = Image.file(File(_photoPath!), fit: BoxFit.cover);
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(width: 64, height: 64, child: img),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Fotografía adjunta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF002F6C))),
                Text(
                  _photoPath!.length > 30 ? '...${_photoPath!.substring(_photoPath!.length - 28)}' : _photoPath!,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF0284C7)),
            tooltip: 'Reemplazar fotografía',
            onPressed: () => _pickPhoto(ImageSource.camera),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
            tooltip: 'Eliminar fotografía',
            onPressed: () => setState(() => _photoPath = null),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StandardWorkProvider>(context);
    final inst = widget.instance;

    // Validación de plan de acción
    ProPlanModel? relatedPlan;
    if (inst.requierePlanAccion || inst.planAccionObligatorio) {
      try {
        relatedPlan = provider.proPlans.firstWhere(
          (p) => p.activityInstanceId == inst.id || (p.activityId != null && p.activityId == inst.activityId),
        );
      } catch (_) {
        relatedPlan = null;
      }
    }

    final bool isPlanFulfilled = relatedPlan != null && (relatedPlan.estado == 'Cumplido' || relatedPlan.porcentajeAvance >= 1.0);
    final bool isPhotoFulfilled = !inst.reqFoto || (_photoPath != null && _photoPath!.isNotEmpty);
    final bool canComplete = (!inst.planAccionObligatorio || isPlanFulfilled) && isPhotoFulfilled;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.90),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // INDICADOR SUPERIOR APPLE
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 44,
              height: 5,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
            ),
          ),

          // HEADER MODAL
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFF002F6C).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.task_alt_rounded, color: Color(0xFF002F6C), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(inst.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF002F6C))),
                      Text('${inst.timeStart} - ${inst.timeEnd} · Área: ${inst.area}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
              ],
            ),
          ),
          const Divider(height: 1),

          // CUERPO SCROLLABLE
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // BADGES DE REQUISITOS
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      if (inst.reqFoto)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFFDE68A))),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.camera_alt_rounded, size: 13, color: Color(0xFFB45309)),
                              SizedBox(width: 4),
                              Text('Foto Obligatoria', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFB45309))),
                            ],
                          ),
                        ),
                      if (inst.planAccionObligatorio)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFFECACA))),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.warning_amber_rounded, size: 13, color: Color(0xFFB91C1C)),
                              SizedBox(width: 4),
                              Text('Plan Obligatorio', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFB91C1C))),
                            ],
                          ),
                        ),
                      if (inst.fija)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                          child: const Text('🔒 Estándar Fijo', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // INSTRUCCIONES / DESCRIPCIÓN
                  if (inst.descripcion.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Instrucciones Operativas:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A))),
                          const SizedBox(height: 4),
                          Text(inst.descripcion, style: const TextStyle(fontSize: 13, color: Color(0xFF334155))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 1. COMENTARIO U OBSERVACIÓN PRE-CIERRE
                  const Text('1. Comentario u Observación Operativa:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _commentCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Escribe novedades, condiciones del puesto o hallazgos...',
                      hintStyle: const TextStyle(fontSize: 12),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. EVIDENCIA FOTOGRÁFICA
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text('2. Evidencia Fotográfica:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                          if (inst.reqFoto) ...[
                            const SizedBox(width: 6),
                            const Text('* Requerida', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 11)),
                          ],
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.camera_alt_rounded, color: Color(0xFF002F6C)),
                            tooltip: 'Tomar Foto',
                            onPressed: () => _pickPhoto(ImageSource.camera),
                          ),
                          IconButton(
                            icon: const Icon(Icons.photo_library_rounded, color: Color(0xFF0284C7)),
                            tooltip: 'Seleccionar de Galería',
                            onPressed: () => _pickPhoto(ImageSource.gallery),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (_photoPath == null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: inst.reqFoto ? const Color(0xFFFFFBEB) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: inst.reqFoto ? const Color(0xFFFDE68A) : Colors.grey.shade300, style: BorderStyle.solid),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.add_a_photo_outlined, size: 28, color: inst.reqFoto ? const Color(0xFFB45309) : Colors.grey.shade400),
                          const SizedBox(height: 6),
                          Text(
                            inst.reqFoto ? 'Fotografía requerida para poder completar' : 'Opcional: Adjunta evidencia de orden o calidad',
                            style: TextStyle(fontSize: 11, color: inst.reqFoto ? const Color(0xFFB45309) : Colors.grey.shade600, fontWeight: inst.reqFoto ? FontWeight.bold : FontWeight.normal),
                          ),
                        ],
                      ),
                    )
                  else
                    _buildPhotoThumbnail(),

                  const SizedBox(height: 16),

                  // 3. PLANES DE ACCIÓN ASOCIADOS
                  if (inst.requierePlanAccion || inst.planAccionObligatorio) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text('3. Plan de Acción:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                            if (inst.planAccionObligatorio) ...[
                              const SizedBox(width: 6),
                              const Text('* Obligatorio', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 11)),
                            ],
                          ],
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            final ok = await ActionPlanDialog.show(context: context, instance: inst);
                            if (ok == true) setState(() {});
                          },
                          icon: const Icon(Icons.flag_outlined, size: 16),
                          label: Text(relatedPlan == null ? 'Crear Plan' : 'Ver / Diligenciar', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isPlanFulfilled ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isPlanFulfilled ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA)),
                      ),
                      child: Row(
                        children: [
                          Icon(isPlanFulfilled ? Icons.check_circle_rounded : Icons.pending_actions_rounded, color: isPlanFulfilled ? const Color(0xFF16A34A) : const Color(0xFFDC2626)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  relatedPlan != null ? relatedPlan.plan : 'Ningún plan registrado aún',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isPlanFulfilled ? const Color(0xFF166534) : const Color(0xFF991B1B)),
                                ),
                                Text(
                                  relatedPlan != null ? 'Estado: ${relatedPlan.estado} · ${(relatedPlan.porcentajeAvance * 100).toInt()}%' : 'Toca el botón para registrar compromisos y avances',
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 4. CHECKLIST DE SUBTAREAS SI TIENE
                  if (inst.subtasksTotal > 0) ...[
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => ActivitySubtasksModal(
                            instance: inst,
                            onComplete: (data) async {
                              for (final entry in data.entries) {
                                await provider.reportSubtaskExecution(
                                  instanceId: inst.id!,
                                  subtaskId: entry.key,
                                  photoPath: entry.value['photo'] as String?,
                                  comment: entry.value['comment'] as String?,
                                  measuredValue: entry.value['measurement'] as double?,
                                );
                              }
                              setState(() {});
                            },
                          ),
                        );
                      },
                      icon: const Icon(Icons.checklist_rounded, size: 18),
                      label: Text('Ver Checklist de Subtareas (${inst.subtasksReported}/${inst.subtasksTotal} completadas)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ALERTA DE REQUISITOS PENDIENTES
                  if (!canComplete) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFFDE68A))),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: Color(0xFFB45309), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              !isPhotoFulfilled
                                  ? '⚠️ Debes adjuntar la fotografía obligatoria antes de finalizar.'
                                  : '⚠️ Debes registrar y cumplir el plan de acción obligatorio.',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ),

          // BARRA INFERIOR DE FINALIZACIÓN
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cerrar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canComplete ? const Color(0xFF16A34A) : Colors.grey.shade400,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: !canComplete || _isSubmitting
                        ? null
                        : () async {
                            setState(() => _isSubmitting = true);
                            final error = await provider.completeActivityInstance(
                              instanceId: inst.id!,
                              observaciones: _commentCtrl.text.trim(),
                              fotoPath: _photoPath,
                            );
                            setState(() => _isSubmitting = false);

                            if (context.mounted) {
                              if (error != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(backgroundColor: const Color(0xFFDC2626), content: Text(error)),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(backgroundColor: Color(0xFF16A34A), content: Text('¡Actividad finalizada y validada exitosamente!')),
                                );
                                Navigator.pop(context, true);
                              }
                            }
                          },
                    icon: _isSubmitting
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.check_circle_rounded, size: 20),
                    label: Text(
                      _isSubmitting ? 'Validando...' : 'Marcar como Completada',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

