import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../data/models/app_models.dart';
import '../../data/database/database_helper.dart';
import '../../data/services/standard_work_provider.dart';

class ActivitySubtasksModal extends StatefulWidget {
  final ActivityInstance instance;
  final Function(Map<int, Map<String, dynamic>> subtaskData) onComplete;

  const ActivitySubtasksModal({
    super.key,
    required this.instance,
    required this.onComplete,
  });

  @override
  State<ActivitySubtasksModal> createState() => _ActivitySubtasksModalState();
}

class _ActivitySubtasksModalState extends State<ActivitySubtasksModal> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final ImagePicker _picker = ImagePicker();
  List<ActivitySubtaskModel> _subtasks = [];
  bool _loading = true;

  // Mapa de estado por subtaskId:
  // { subtaskId: { 'done': bool, 'photo': String?, 'comment': String, 'measurement': double? } }
  final Map<int, Map<String, dynamic>> _data = {};

  final List<String> _catalogPhotos = [
    'assets/images/fotos_track60/1F.jpg',
    'assets/images/fotos_track60/2F.jpg',
    'assets/images/fotos_track60/3F.jpg',
    'assets/images/fotos_track60/4F.jpg',
    'assets/images/fotos_track60/5F.jpg',
    'assets/images/fotos_track60/6F.jpg',
    'assets/images/fotos_track60/7F.jpg',
    'assets/images/fotos_track60/8F.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _loadSubtasks();
  }

  Future<void> _loadSubtasks() async {
    final provider = Provider.of<StandardWorkProvider>(context, listen: false);
    final list = await provider.getSubtasksForActivity(widget.instance.activityId);
    final previousExecs = await _db.getSubtaskExecutionsForInstance(widget.instance.id ?? 0);

    for (final s in list) {
      if (s.id != null) {
        final existing = previousExecs.where((e) => e.subtaskId == s.id).toList();
        if (existing.isNotEmpty) {
          final e = existing.first;
          _data[s.id!] = {
            'done': e.reportada,
            'photo': e.fotoPath,
            'comment': e.comentario ?? '',
            'measurement': e.valorMedido,
          };
        } else {
          _data[s.id!] = {
            'done': false,
            'photo': null,
            'comment': '',
            'measurement': null,
          };
        }
      }
    }

    if (mounted) {
      setState(() {
        _subtasks = list;
        _loading = false;
      });
    }
  }

  void _showPhotoOptionsDialog(int subtaskId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Capturar Evidencia Fotográfica',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Elige cómo deseas adjuntar la fotografía requerida:',
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFF002F6C).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF002F6C)),
              ),
              title: const Text('Tomar Foto con Cámara', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: const Text('Abre la cámara del dispositivo en tiempo real', style: TextStyle(fontSize: 12)),
              onTap: () async {
                Navigator.pop(ctx);
                final xfile = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
                if (xfile != null) {
                  setState(() {
                    _data[subtaskId]!['photo'] = xfile.path;
                  });
                }
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFF0284C7).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.photo_library_rounded, color: Color(0xFF0284C7)),
              ),
              title: const Text('Seleccionar de Galería', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: const Text('Adjunta una imagen guardada en tu teléfono', style: TextStyle(fontSize: 12)),
              onTap: () async {
                Navigator.pop(ctx);
                final xfile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
                if (xfile != null) {
                  setState(() {
                    _data[subtaskId]!['photo'] = xfile.path;
                  });
                }
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFF16A34A).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.factory_rounded, color: Color(0xFF16A34A)),
              ),
              title: const Text('Fotos Estándar de Planta (Catálogo)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: const Text('Selecciona una toma de inspección de la línea de producción', style: TextStyle(fontSize: 12)),
              onTap: () {
                Navigator.pop(ctx);
                _showCatalogSelector(subtaskId);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCatalogSelector(int subtaskId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Catálogo de Fotos de Planta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            itemCount: _catalogPhotos.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, idx) {
              final photo = _catalogPhotos[idx];
              return InkWell(
                onTap: () {
                  setState(() {
                    _data[subtaskId]!['photo'] = photo;
                  });
                  Navigator.pop(ctx);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(photo, fit: BoxFit.cover),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  bool get _canSubmit {
    if (_subtasks.isEmpty) return true;
    for (final s in _subtasks) {
      if (s.id == null) continue;
      final d = _data[s.id!];
      if (d == null || d['done'] != true) return false;
      if (s.requiereFoto && (d['photo'] == null || (d['photo'] as String).isEmpty)) {
        return false;
      }
      if (s.requiereComentario && ((d['comment'] as String?)?.trim().isEmpty ?? true)) {
        return false;
      }
      if (s.requiereMedicion && d['measurement'] == null) {
        return false;
      }
    }
    return true;
  }

  Widget _buildPhotoThumbnail(String path) {
    if (path.startsWith('assets/')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(path, width: 60, height: 60, fit: BoxFit.cover),
      );
    } else {
      final file = File(path);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(file, width: 60, height: 60, fit: BoxFit.cover),
        );
      }
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
        child: const Icon(Icons.broken_image, size: 24, color: Colors.grey),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Header de la Actividad
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: widget.instance.fija
                                ? const Color(0xFFDC2626).withValues(alpha: 0.12)
                                : const Color(0xFF0284C7).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.instance.fija ? 'ACTIVIDAD FIJA' : 'FLEXIBLE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: widget.instance.fija ? const Color(0xFFDC2626) : const Color(0xFF0284C7),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.instance.timeStart} - ${widget.instance.timeEnd}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.instance.nombre,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    if (widget.instance.descripcion.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.instance.descripcion,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(height: 20),

          // Contenido de Subtareas
          if (_loading)
            const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
          else if (_subtasks.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'Esta actividad no requiere desglose de subtareas paso a paso. Puedes marcarla directamente.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _subtasks.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final s = _subtasks[index];
                  final sid = s.id!;
                  final d = _data[sid]!;
                  final isDone = d['done'] as bool;
                  final photo = d['photo'] as String?;

                  return Container(
                    decoration: BoxDecoration(
                      color: isDone ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDone ? const Color(0xFF86EFAC) : Colors.grey.shade300,
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Checkbox y Título del Paso
                        Row(
                          children: [
                            Checkbox(
                              value: isDone,
                              activeColor: const Color(0xFF16A34A),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              onChanged: (val) {
                                setState(() {
                                  d['done'] = val ?? false;
                                });
                              },
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Paso ${s.orden}: ${s.nombre}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isDone ? const Color(0xFF166534) : const Color(0xFF0F172A),
                                      decoration: isDone ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                  if (s.descripcion.isNotEmpty)
                                    Text(
                                      s.descripcion,
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Requisitos de Evidencia
                        if (isDone) ...[
                          const SizedBox(height: 8),
                          const Divider(height: 1),
                          const SizedBox(height: 8),

                          // Foto requerida
                          if (s.requiereFoto) ...[
                            Row(
                              children: [
                                if (photo != null && photo.isNotEmpty) ...[
                                  _buildPhotoThumbnail(photo),
                                  const SizedBox(width: 10),
                                ],
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        photo != null ? 'Foto cargada correctamente' : 'Foto de evidencia obligatoria *',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: photo != null ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      OutlinedButton.icon(
                                        onPressed: () => _showPhotoOptionsDialog(sid),
                                        icon: const Icon(Icons.add_a_photo_rounded, size: 14),
                                        label: Text(photo != null ? 'Cambiar Foto' : 'Adjuntar Foto'),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          textStyle: const TextStyle(fontSize: 11),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],

                          // Medición Numérica requerida
                          if (s.requiereMedicion) ...[
                            Row(
                              children: [
                                Icon(Icons.speed_rounded, size: 16, color: d['measurement'] != null ? const Color(0xFF16A34A) : Colors.grey.shade600),
                                const SizedBox(width: 6),
                                Text(
                                  'Medición (${s.unidadMedida}) *',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: d['measurement'] != null ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                SizedBox(
                                  width: 100,
                                  height: 36,
                                  child: TextFormField(
                                    initialValue: d['measurement']?.toString() ?? '',
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: '0.00',
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                                    ),
                                    onChanged: (val) {
                                      final numVal = double.tryParse(val);
                                      setState(() {
                                        d['measurement'] = numVal;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],

                          // Comentario / Novedad requerida
                          if (s.requiereComentario) ...[
                            TextFormField(
                              initialValue: d['comment'] as String? ?? '',
                              decoration: InputDecoration(
                                hintText: 'Observación o novedad del paso *',
                                hintStyle: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              onChanged: (val) {
                                setState(() {
                                  d['comment'] = val;
                                });
                              },
                            ),
                          ],
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),

          // Botón de Enviar Reporte
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _canSubmit
                  ? () {
                      widget.onComplete(_data);
                      Navigator.pop(context);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF002F6C),
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                _canSubmit
                    ? 'Reportar Ejecución con Evidencias'
                    : 'Completa todos los pasos y evidencias',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
