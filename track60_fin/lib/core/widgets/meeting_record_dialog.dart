import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/app_models.dart';
import '../../data/services/standard_work_provider.dart';

class MeetingRecordDialog extends StatefulWidget {
  final ActivityInstance instance;
  final MeetingRecordModel? existingRecord;
  final bool isReadOnly;

  const MeetingRecordDialog({
    super.key,
    required this.instance,
    this.existingRecord,
    this.isReadOnly = false,
  });

  static Future<void> show({
    required BuildContext context,
    required ActivityInstance instance,
    MeetingRecordModel? existingRecord,
    bool isReadOnly = false,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MeetingRecordDialog(
        instance: instance,
        existingRecord: existingRecord,
        isReadOnly: isReadOnly,
      ),
    );
  }

  @override
  State<MeetingRecordDialog> createState() => _MeetingRecordDialogState();
}

class _MeetingRecordDialogState extends State<MeetingRecordDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tituloCtrl;
  late final TextEditingController _fechaCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _participantesCtrl;
  late final TextEditingController _observacionesCtrl;
  late final TextEditingController _compromisosCtrl;
  late final TextEditingController _responsablesCtrl;
  late final TextEditingController _fechaCumplimientoCtrl;
  String? _fotoAdjunto;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final rec = widget.existingRecord;
    _tituloCtrl = TextEditingController(text: rec?.titulo ?? widget.instance.nombre);
    _fechaCtrl = TextEditingController(text: rec?.fecha ?? DateTime.now().toIso8601String().substring(0, 10));
    _descCtrl = TextEditingController(text: rec?.descripcion ?? widget.instance.descripcion);
    _participantesCtrl = TextEditingController(text: rec?.participantes ?? '');
    _observacionesCtrl = TextEditingController(text: rec?.observaciones ?? '');
    _compromisosCtrl = TextEditingController(text: rec?.compromisos ?? '');
    _responsablesCtrl = TextEditingController(text: rec?.responsablesCompromisos ?? '');
    _fechaCumplimientoCtrl = TextEditingController(text: rec?.fechaCumplimientoCompromisos ?? '');
    _fotoAdjunto = rec?.fotoOAdjuntoPath;
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _fechaCtrl.dispose();
    _descCtrl.dispose();
    _participantesCtrl.dispose();
    _observacionesCtrl.dispose();
    _compromisosCtrl.dispose();
    _responsablesCtrl.dispose();
    _fechaCumplimientoCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSave(StandardWorkProvider provider) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      await provider.submitMeetingRecord(
        instanceId: widget.instance.id!,
        titulo: _tituloCtrl.text.trim(),
        fecha: _fechaCtrl.text.trim(),
        descripcion: _descCtrl.text.trim(),
        participantes: _participantesCtrl.text.trim(),
        observaciones: _observacionesCtrl.text.trim(),
        compromisos: _compromisosCtrl.text.trim(),
        responsablesCompromisos: _responsablesCtrl.text.trim(),
        fechaCumplimientoCompromisos: _fechaCumplimientoCtrl.text.trim(),
        fotoOAdjuntoPath: _fotoAdjunto,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF16A34A),
            content: Text('¡Registro de información guardado y enviado exitosamente!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFDC2626),
            content: Text('Error al guardar el registro: $e'),
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
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BARRA SUPERIOR
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
                    color: const Color(0xFF002F6C).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.assignment_rounded, color: Color(0xFF002F6C), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isReadOnly ? 'Consulta de Registro Operativo' : 'Actividad de Registro de Información',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF002F6C)),
                      ),
                      Text(
                        'Modalidad: Reuniones, Acuerdos, Compromisos e Inspecciones',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const Divider(height: 24),

            // FORMULARIO CON SCROLL
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('1. Datos Generales de la Actividad'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _tituloCtrl,
                      readOnly: widget.isReadOnly,
                      decoration: _inputDecoration('Título del registro o reunión *', Icons.title_rounded),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _fechaCtrl,
                            readOnly: widget.isReadOnly,
                            decoration: _inputDecoration('Fecha (YYYY-MM-DD)', Icons.calendar_today_rounded),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _participantesCtrl,
                            readOnly: widget.isReadOnly,
                            decoration: _inputDecoration('Participantes / Asistentes', Icons.group_rounded),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descCtrl,
                      readOnly: widget.isReadOnly,
                      maxLines: 2,
                      decoration: _inputDecoration('Objetivo o descripción de la sesión', Icons.description_rounded),
                    ),

                    const SizedBox(height: 20),
                    _buildSectionTitle('2. Observaciones y Novedades del Proceso'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _observacionesCtrl,
                      readOnly: widget.isReadOnly,
                      maxLines: 3,
                      decoration: _inputDecoration('Escribe las notas, acuerdos y puntos clave tratados...', Icons.edit_note_rounded),
                    ),

                    const SizedBox(height: 20),
                    _buildSectionTitle('3. Compromisos y Plan de Seguimiento'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _compromisosCtrl,
                      readOnly: widget.isReadOnly,
                      maxLines: 2,
                      decoration: _inputDecoration('Compromisos pactados...', Icons.check_circle_outline_rounded),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _responsablesCtrl,
                            readOnly: widget.isReadOnly,
                            decoration: _inputDecoration('Responsables de cumplimiento', Icons.person_outline_rounded),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _fechaCumplimientoCtrl,
                            readOnly: widget.isReadOnly,
                            decoration: _inputDecoration('Fecha límite compromiso', Icons.event_available_rounded),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    _buildSectionTitle('4. Soporte y Evidencias Adjuntas'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.attachment_rounded, color: Colors.blue.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _fotoAdjunto ?? 'Sin archivo adjunto',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                                const Text('Fotografía del acta, minuta o estándar firmado', style: TextStyle(fontSize: 11, color: Colors.grey)),
                              ],
                            ),
                          ),
                          if (!widget.isReadOnly)
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _fotoAdjunto = 'acta_${DateTime.now().millisecondsSinceEpoch}.jpg';
                                });
                              },
                              icon: const Icon(Icons.camera_alt_rounded, size: 16),
                              label: const Text('Adjuntar'),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // BOTÓN DE ACCIÓN
            if (!widget.isReadOnly)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving
                      ? null
                      : () => _handleSave(
                            Provider.of<StandardWorkProvider>(context, listen: false),
                          ),
                  icon: _isSaving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.send_rounded, color: Colors.white),
                  label: Text(_isSaving ? 'Guardando Registro...' : 'Guardar y Finalizar Actividad', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF002F6C),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569), letterSpacing: 0.5),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 12),
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
