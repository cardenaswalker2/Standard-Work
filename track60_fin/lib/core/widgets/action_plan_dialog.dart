import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/app_models.dart';
import '../../data/services/standard_work_provider.dart';

class ActionPlanDialog extends StatefulWidget {
  final ActivityInstance? instance;
  final ProPlanModel? existingPlan;
  final bool isMandatoryForActivity;

  const ActionPlanDialog({
    super.key,
    this.instance,
    this.existingPlan,
    this.isMandatoryForActivity = false,
  });

  static Future<bool?> show({
    required BuildContext context,
    ActivityInstance? instance,
    ProPlanModel? existingPlan,
    bool isMandatoryForActivity = false,
  }) async {
    return await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ActionPlanDialog(
        instance: instance,
        existingPlan: existingPlan,
        isMandatoryForActivity: isMandatoryForActivity,
      ),
    );
  }

  @override
  State<ActionPlanDialog> createState() => _ActionPlanDialogState();
}

class _ActionPlanDialogState extends State<ActionPlanDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tituloCtrl;
  late final TextEditingController _situacionCtrl;
  late final TextEditingController _accionesCtrl;
  late final TextEditingController _fechaCtrl;
  late final TextEditingController _evidenciaCtrl;
  late double _avance;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.existingPlan;
    _tituloCtrl = TextEditingController(
      text: p?.plan ?? (widget.instance != null ? 'Plan de Acción: ${widget.instance!.nombre}' : ''),
    );
    _situacionCtrl = TextEditingController(
      text: p?.descripcionSituacion ?? (widget.instance != null ? widget.instance!.descripcion : ''),
    );
    _accionesCtrl = TextEditingController(text: p?.comentarios ?? '');
    _fechaCtrl = TextEditingController(
      text: p?.fechaCompromiso ?? DateTime.now().add(const Duration(days: 3)).toIso8601String().substring(0, 10),
    );
    _evidenciaCtrl = TextEditingController(text: p?.evidencia ?? '');
    _avance = p?.porcentajeAvance ?? (widget.isMandatoryForActivity ? 1.0 : 0.5);
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _situacionCtrl.dispose();
    _accionesCtrl.dispose();
    _fechaCtrl.dispose();
    _evidenciaCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final provider = Provider.of<StandardWorkProvider>(context, listen: false);
    final user = provider.currentUser;

    try {
      if (widget.existingPlan != null) {
        await provider.updateProPlanStatus(
          planId: widget.existingPlan!.id!,
          nuevoEstado: _avance >= 1.0 ? 'Cumplido' : 'En Proceso',
          porcentajeAvance: _avance,
          evidencia: _evidenciaCtrl.text.trim(),
          comentarios: _accionesCtrl.text.trim(),
        );
      } else {
        await provider.createProPlan(
          plantId: widget.instance?.plantId ?? user?.plantId ?? 'PL-EXTRUSA',
          plan: _tituloCtrl.text.trim(),
          responsable: user?.nombre ?? 'Colaborador',
          area: widget.instance?.area ?? user?.area ?? 'Operaciones',
          fechaCompromiso: _fechaCtrl.text.trim(),
          activityInstanceId: widget.instance?.id,
          activityId: widget.instance?.activityId,
          activityNombre: widget.instance?.nombre,
          descripcionSituacion: _situacionCtrl.text.trim(),
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF16A34A),
            content: Text('¡Plan de acción registrado y actualizado con éxito!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFDC2626),
            content: Text('Error: $e'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.flag_rounded, color: Color(0xFFD97706), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isMandatoryForActivity
                            ? 'Plan de Acción Requerido Obligatorio'
                            : 'Gestión de Plan de Acción',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF002F6C)),
                      ),
                      if (widget.instance != null)
                        Text(
                          'Vinculado a: ${widget.instance!.nombre}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600, overflow: TextOverflow.ellipsis),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context, false),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            if (widget.isMandatoryForActivity)
              Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFCD34D)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFFB45309), size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Esta actividad exige completar el plan de acción para poder ser finalizada y enviada a revisión.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF92400E), fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            const Divider(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Título del Plan o Acción Correctiva *'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _tituloCtrl,
                      decoration: _inputDecoration('Nombre descriptivo del plan', Icons.assignment_outlined),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 14),
                    _buildLabel('Descripción del Problema o Situación Operativa *'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _situacionCtrl,
                      maxLines: 2,
                      decoration: _inputDecoration('Detalla la desviación, falla o causa raíz...', Icons.report_problem_outlined),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 14),
                    _buildLabel('Acciones, Tareas y Compromisos Acordados'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _accionesCtrl,
                      maxLines: 3,
                      decoration: _inputDecoration('Qué se va a hacer, pasos de corrección...', Icons.task_alt_rounded),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Fecha Compromiso'),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _fechaCtrl,
                                decoration: _inputDecoration('YYYY-MM-DD', Icons.calendar_today_rounded),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Evidencia Documentada'),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _evidenciaCtrl,
                                decoration: _inputDecoration('Comprobante / OT', Icons.attachment_rounded),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _buildLabel('Porcentaje de Avance del Plan: ${(_avance * 100).toInt()}%'),
                    Slider(
                      value: _avance,
                      min: 0.0,
                      max: 1.0,
                      divisions: 4,
                      activeColor: _avance >= 1.0 ? const Color(0xFF16A34A) : const Color(0xFF0284C7),
                      label: '${(_avance * 100).toInt()}%',
                      onChanged: (val) => setState(() => _avance = val),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('0% (Iniciado)', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                        Text('50% (En Proceso)', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                        const Text('100% (Completado)', style: TextStyle(fontSize: 11, color: Color(0xFF16A34A), fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _handleSave,
                icon: _isSaving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.check_circle_rounded, color: Colors.white),
                label: Text(
                  _isSaving
                      ? 'Guardando...'
                      : (_avance >= 1.0 ? 'Completar y Guardar Plan de Acción' : 'Guardar Avance del Plan'),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _avance >= 1.0 ? const Color(0xFF16A34A) : const Color(0xFF002F6C),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12),
      prefixIcon: Icon(icon, size: 20, color: const Color(0xFF002F6C)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF002F6C), width: 1.5)),
    );
  }
}

