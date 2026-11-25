import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/app_models.dart';
import '../../data/services/standard_work_provider.dart';

class TemplatesModal extends StatefulWidget {
  final Function(ActivityTemplateModel template)? onSelectTemplate;

  const TemplatesModal({super.key, this.onSelectTemplate});

  static Future<ActivityTemplateModel?> show({
    required BuildContext context,
    Function(ActivityTemplateModel template)? onSelectTemplate,
  }) {
    return showDialog<ActivityTemplateModel>(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: TemplatesModal(onSelectTemplate: onSelectTemplate),
      ),
    );
  }

  @override
  State<TemplatesModal> createState() => _TemplatesModalState();
}

class _TemplatesModalState extends State<TemplatesModal> {
  int _activeView = 0; // 0: Lista de Plantillas, 1: Formulario Crear/Editar, 2: Previsualización Detallada
  ActivityTemplateModel? _selectedTemplate;
  ActivityTemplateModel? _editingTemplate;

  // Controladores de formulario
  final _nombreCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _areaCtrl = TextEditingController(text: 'Producción');
  final _instruccionesCtrl = TextEditingController();
  final _criteriosCtrl = TextEditingController();

  String _prioridad = 'Alta';
  String _tipoActividad = 'ejecucion';
  bool _fija = false;
  bool _reqFoto = false;
  bool _reqMedicion = false;
  bool _reqComentario = true;
  bool _requierePlanAccion = false;
  bool _planAccionObligatorio = false;

  final List<Map<String, dynamic>> _subtareasForm = [];

  void _initFormWithTemplate([ActivityTemplateModel? t]) {
    _editingTemplate = t;
    if (t != null) {
      _nombreCtrl.text = t.nombre;
      _descCtrl.text = t.descripcion;
      _areaCtrl.text = t.area;
      _instruccionesCtrl.text = t.instrucciones;
      _criteriosCtrl.text = t.criteriosCumplimiento;
      _prioridad = t.prioridad;
      _tipoActividad = t.tipoActividad;
      _fija = t.fija;
      _reqFoto = t.reqFoto;
      _reqMedicion = t.reqMedicion;
      _reqComentario = t.reqComentario;
      _requierePlanAccion = t.requierePlanAccion;
      _planAccionObligatorio = t.planAccionObligatorio;

      _subtareasForm.clear();
      try {
        final List list = jsonDecode(t.subtareasJson);
        for (final item in list) {
          _subtareasForm.add(Map<String, dynamic>.from(item));
        }
      } catch (_) {}
    } else {
      _nombreCtrl.clear();
      _descCtrl.clear();
      _areaCtrl.text = 'Producción';
      _instruccionesCtrl.clear();
      _criteriosCtrl.clear();
      _prioridad = 'Alta';
      _tipoActividad = 'ejecucion';
      _fija = false;
      _reqFoto = false;
      _reqMedicion = false;
      _reqComentario = true;
      _requierePlanAccion = false;
      _planAccionObligatorio = false;
      _subtareasForm.clear();
    }
  }

  void _addSubtaskDialog() {
    final nameCtrl = TextEditingController();
    bool photo = false;
    bool med = false;
    final unitCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Agregar Subtarea a Plantilla', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre del Paso / Subtarea')),
              const SizedBox(height: 8),
              CheckboxListTile(
                value: photo,
                dense: true,
                title: const Text('Requiere Evidencia Fotográfica', style: TextStyle(fontSize: 12)),
                onChanged: (v) => setDState(() => photo = v ?? false),
              ),
              CheckboxListTile(
                value: med,
                dense: true,
                title: const Text('Requiere Medición Numérica', style: TextStyle(fontSize: 12)),
                onChanged: (v) => setDState(() => med = v ?? false),
              ),
              if (med)
                TextField(controller: unitCtrl, decoration: const InputDecoration(labelText: 'Unidad de Medida (ej. bar, °C, mm)')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF002F6C)),
              onPressed: () {
                if (nameCtrl.text.trim().isNotEmpty) {
                  setState(() {
                    _subtareasForm.add({
                      'orden': _subtareasForm.length + 1,
                      'nombre': nameCtrl.text.trim(),
                      'reqFoto': photo ? 1 : 0,
                      'reqMed': med ? 1 : 0,
                      'unidad': unitCtrl.text.trim(),
                    });
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Agregar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveTemplate(StandardWorkProvider provider) async {
    if (_nombreCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Color(0xFFDC2626), content: Text('El nombre de la plantilla es obligatorio.')),
      );
      return;
    }

    final template = ActivityTemplateModel(
      id: _editingTemplate?.id,
      nombre: _nombreCtrl.text.trim(),
      descripcion: _descCtrl.text.trim(),
      area: _areaCtrl.text.trim(),
      prioridad: _prioridad,
      tipoActividad: _tipoActividad,
      fija: _fija,
      reqFoto: _reqFoto,
      reqMedicion: _reqMedicion,
      reqComentario: _reqComentario,
      requierePlanAccion: _requierePlanAccion,
      planAccionObligatorio: _planAccionObligatorio,
      instrucciones: _instruccionesCtrl.text.trim(),
      criteriosCumplimiento: _criteriosCtrl.text.trim(),
      subtareasJson: jsonEncode(_subtareasForm),
      fechaCreacion: _editingTemplate?.fechaCreacion ?? DateTime.now().toIso8601String(),
    );

    if (_editingTemplate == null) {
      await provider.createTemplate(template);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: Color(0xFF16A34A), content: Text('¡Plantilla creada exitosamente!')),
        );
      }
    } else {
      await provider.updateTemplate(template);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: Color(0xFF0284C7), content: Text('¡Plantilla actualizada sin afectar historial existente!')),
        );
      }
    }

    setState(() => _activeView = 0);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StandardWorkProvider>(context);
    final templates = provider.templates;

    return Container(
      width: 680,
      constraints: const BoxConstraints(maxHeight: 740),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 30, offset: Offset(0, 10))],
      ),
      child: Column(
        children: [
          // HEADER APPLE-STYLE
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF002F6C),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.copy_all_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Gestión de Plantillas de Actividad', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('Estandarización corporativa multi-proceso Darnel', style: TextStyle(color: Colors.blue.shade100, fontSize: 11)),
                    ],
                  ),
                ),
                if (_activeView != 0)
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                    onPressed: () => setState(() => _activeView = 0),
                    icon: const Icon(Icons.arrow_back_rounded, size: 16),
                    label: const Text('Volver al Listado', style: TextStyle(fontSize: 12)),
                  ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                ),
              ],
            ),
          ),

          // CONTENIDO DINÁMICO POR VISTAS
          Expanded(
            child: _activeView == 0
                ? _buildTemplatesListView(templates)
                : _activeView == 1
                    ? _buildCreateOrEditForm(provider)
                    : _buildDetailPreviewView(),
          ),
        ],
      ),
    );
  }

  // --- VISTA 0: LISTADO DE PLANTILLAS ---
  Widget _buildTemplatesListView(List<ActivityTemplateModel> templates) {
    return Column(
      children: [
        // BARRA DE ACCIÓN SUPERIOR
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Catálogo de Plantillas (${templates.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF002F6C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                onPressed: () {
                  _initFormWithTemplate(null);
                  setState(() => _activeView = 1);
                },
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Nueva Plantilla', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // LISTA SCROLLABLE
        Expanded(
          child: templates.isEmpty
              ? const Center(child: Text('No hay plantillas registradas aún.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: templates.length,
                  itemBuilder: (ctx, i) {
                    final t = templates[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: t.esRegistro ? const Color(0xFFEFF6FF) : const Color(0xFFF0FDF4),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    t.esRegistro ? 'REGISTRO / REUNIÓN' : 'EJECUCIÓN',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: t.esRegistro ? const Color(0xFF1D4ED8) : const Color(0xFF15803D),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(t.area, style: TextStyle(fontSize: 10, color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF0284C7)),
                                  tooltip: 'Editar plantilla',
                                  onPressed: () {
                                    _initFormWithTemplate(t);
                                    setState(() => _activeView = 1);
                                  },
                                ),
                                if (t.id != null)
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFFF3B30)),
                                    tooltip: 'Eliminar plantilla',
                                    onPressed: () async {
                                      final ok = await showDialog<bool>(
                                        context: context,
                                        builder: (dCtx) => AlertDialog(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                          title: const Text('Eliminar Plantilla', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                          content: Text('¿Deseas eliminar la plantilla "${t.nombre}"?'),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(dCtx, false), child: const Text('Cancelar')),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF3B30)),
                                              onPressed: () => Navigator.pop(dCtx, true),
                                              child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (ok == true && context.mounted) {
                                        await context.read<StandardWorkProvider>().deleteTemplate(t.id!);
                                      }
                                    },
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(t.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF002F6C))),
                            if (t.descripcion.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(t.descripcion, style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
                            ],
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                if (t.reqFoto)
                                  const Padding(
                                    padding: EdgeInsets.only(right: 12),
                                    child: Row(
                                      children: [
                                        Icon(Icons.camera_alt_outlined, size: 14, color: Color(0xFFD97706)),
                                        SizedBox(width: 4),
                                        Text('Requiere Foto', style: TextStyle(fontSize: 11, color: Color(0xFFD97706))),
                                      ],
                                    ),
                                  ),
                                if (t.planAccionObligatorio)
                                  const Padding(
                                    padding: EdgeInsets.only(right: 12),
                                    child: Row(
                                      children: [
                                        Icon(Icons.warning_amber_rounded, size: 14, color: Color(0xFFDC2626)),
                                        SizedBox(width: 4),
                                        Text('Plan Obligatorio', style: TextStyle(fontSize: 11, color: Color(0xFFDC2626))),
                                      ],
                                    ),
                                  ),
                                const Spacer(),
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _selectedTemplate = t;
                                      _activeView = 2;
                                    });
                                  },
                                  child: const Text('Ver Detalle', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF16A34A),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  ),
                                  onPressed: () {
                                    if (widget.onSelectTemplate != null) {
                                      widget.onSelectTemplate!(t);
                                    }
                                    Navigator.pop(context, t);
                                  },
                                  child: const Text('Seleccionar', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // --- VISTA 1: CREAR O EDITAR PLANTILLA ---
  Widget _buildCreateOrEditForm(StandardWorkProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_editingTemplate == null ? Icons.add_box_rounded : Icons.edit_note_rounded, color: const Color(0xFF002F6C)),
              const SizedBox(width: 8),
              Text(
                _editingTemplate == null ? 'Nueva Plantilla Estándar' : 'Editar Plantilla: ${_editingTemplate!.nombre}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF002F6C)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(controller: _nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre de la Plantilla *', hintText: 'Ej. Auditoría 5S de Estación')),
          const SizedBox(height: 12),
          TextField(controller: _descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Descripción Operativa', hintText: 'Explica el objetivo de esta rutina')),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: TextField(controller: _areaCtrl, decoration: const InputDecoration(labelText: 'Área Responsable'))),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _prioridad,
                  decoration: const InputDecoration(labelText: 'Prioridad'),
                  items: const [
                    DropdownMenuItem(value: 'Baja', child: Text('Baja')),
                    DropdownMenuItem(value: 'Media', child: Text('Media')),
                    DropdownMenuItem(value: 'Alta', child: Text('Alta')),
                    DropdownMenuItem(value: 'Crítica', child: Text('Crítica')),
                  ],
                  onChanged: (v) => setState(() => _prioridad = v ?? 'Alta'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // MODALIDAD
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
            child: Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Actividad de Ejecución', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Tareas, checklist y evidencias', style: TextStyle(fontSize: 10)),
                    value: 'ejecucion',
                    groupValue: _tipoActividad,
                    onChanged: (v) => setState(() => _tipoActividad = v ?? 'ejecucion'),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Registro de Información', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Reuniones, compromisos, novedades', style: TextStyle(fontSize: 10)),
                    value: 'registro',
                    groupValue: _tipoActividad,
                    onChanged: (v) => setState(() => _tipoActividad = v ?? 'registro'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // CONFIGURACIÓN DE REQUISITOS
          const Text('Requisitos de Cumplimiento:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
          const SizedBox(height: 8),
          SwitchListTile(
            dense: true,
            title: const Text('Requiere Evidencia Fotográfica Obligatoria', style: TextStyle(fontSize: 12)),
            value: _reqFoto,
            onChanged: (v) => setState(() => _reqFoto = v),
          ),
          SwitchListTile(
            dense: true,
            title: const Text('Requiere Plan de Acción Obligatorio para Finalizar', style: TextStyle(fontSize: 12)),
            value: _planAccionObligatorio,
            onChanged: (v) => setState(() {
              _planAccionObligatorio = v;
              if (v) _requierePlanAccion = true;
            }),
          ),
          const SizedBox(height: 16),
          // SUBTAREAS DE LA PLANTILLA
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtareas Estándar (${_subtareasForm.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              TextButton.icon(
                onPressed: _addSubtaskDialog,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Agregar Subtarea', style: TextStyle(fontSize: 11)),
              ),
            ],
          ),
          if (_subtareasForm.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              alignment: Alignment.center,
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
              child: const Text('Sin subtareas definidas. La actividad se completará de forma global.', style: TextStyle(fontSize: 11, color: Colors.grey)),
            )
          else
            ..._subtareasForm.map((s) => Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                  child: Row(
                    children: [
                      Text('${s['orden']}.', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(s['nombre']?.toString() ?? '', style: const TextStyle(fontSize: 12))),
                      if ((s['reqFoto'] ?? 0) == 1) const Icon(Icons.camera_alt_outlined, size: 14, color: Colors.amber),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                        onPressed: () => setState(() => _subtareasForm.remove(s)),
                      ),
                    ],
                  ),
                )),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(onPressed: () => setState(() => _activeView = 0), child: const Text('Cancelar')),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF002F6C), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                onPressed: () => _saveTemplate(provider),
                icon: const Icon(Icons.save_rounded, size: 16, color: Colors.white),
                label: Text(_editingTemplate == null ? 'Guardar Plantilla' : 'Actualizar Plantilla', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- VISTA 2: PREVISUALIZACIÓN DETALLADA ---
  Widget _buildDetailPreviewView() {
    final t = _selectedTemplate!;
    List subtareas = [];
    try {
      subtareas = jsonDecode(t.subtareasJson);
    } catch (_) {}

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFF002F6C).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(t.esRegistro ? Icons.edit_note_rounded : Icons.assignment_outlined, color: const Color(0xFF002F6C), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF002F6C))),
                    Text('Área: ${t.area} · Modalidad: ${t.esRegistro ? "Registro" : "Ejecución"}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (t.descripcion.isNotEmpty) ...[
            const Text('Descripción:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A))),
            const SizedBox(height: 4),
            Text(t.descripcion, style: const TextStyle(fontSize: 13, color: Color(0xFF334155))),
            const SizedBox(height: 16),
          ],
          const Text('Subtareas / Checklist de la Plantilla:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A))),
          const SizedBox(height: 8),
          Expanded(
            child: subtareas.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
                    child: const Text('Esta plantilla no tiene subtareas. Aplica como actividad única.', style: TextStyle(color: Colors.grey)),
                  )
                : ListView.builder(
                    itemCount: subtareas.length,
                    itemBuilder: (ctx, i) {
                      final s = subtareas[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
                        child: Row(
                          children: [
                            CircleAvatar(radius: 10, backgroundColor: const Color(0xFF002F6C), child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontSize: 10))),
                            const SizedBox(width: 10),
                            Expanded(child: Text(s['nombre']?.toString() ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                            if ((s['reqFoto'] ?? 0) == 1)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(4)),
                                child: const Text('📷 Foto', style: TextStyle(fontSize: 10, color: Colors.amber)),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(onPressed: () => setState(() => _activeView = 0), child: const Text('Cerrar Previsualización')),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12)),
                onPressed: () {
                  if (widget.onSelectTemplate != null) {
                    widget.onSelectTemplate!(t);
                  }
                  Navigator.pop(context, t);
                },
                icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                label: const Text('Aplicar a Nueva Actividad', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

