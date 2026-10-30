import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils_helper.dart';

class AddActivitySheet extends StatefulWidget {
  final int initialDay;
  final String? initialArea;
  final Function({
    required String nombre,
    required String descripcion,
    required List<int> days,
    required String area,
    required String category,
    required String timeStart,
    required String timeEnd,
    required bool isFixed,
  }) onSave;

  const AddActivitySheet({
    super.key,
    required this.initialDay,
    this.initialArea,
    required this.onSave,
  });

  @override
  State<AddActivitySheet> createState() => _AddActivitySheetState();
}

class _AddActivitySheetState extends State<AddActivitySheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  late Set<int> _selectedDays;
  late String _selectedArea;
  late String _selectedCategory;
  late TimeOfDay _timeStart;
  late TimeOfDay _timeEnd;
  bool _isFixed = false;

  // Catálogos reales oficiales
  static const List<String> availableAreas = [
    'Planta Extrusa',
    'Producción',
    'Calidad',
    'Logística',
    'Mantenimiento',
    'Administración',
  ];

  static const List<String> availableCategories = [
    'Operación y Ejecución',
    'Resultados y Productividad',
    'Liderazgo y Desarrollo de Personas',
    'Proyectos y Mejora Continua',
    'Calidad e Inocuidad',
    'Seguridad',
    'Administración',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDays = {widget.initialDay.clamp(1, 5)};
    _selectedArea = (widget.initialArea != null && availableAreas.contains(widget.initialArea))
        ? widget.initialArea!
        : availableAreas.first;
    _selectedCategory = availableCategories.first;
    _timeStart = const TimeOfDay(hour: 8, minute: 0);
    _timeEnd = const TimeOfDay(hour: 8, minute: 30);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _timeStart,
      helpText: 'HORA DE INICIO',
      cancelText: 'CANCELAR',
      confirmText: 'SELECCIONAR',
    );
    if (picked != null) {
      setState(() {
        _timeStart = picked;
        // Ajustar fin si es anterior
        final startMinutes = _timeStart.hour * 60 + _timeStart.minute;
        final endMinutes = _timeEnd.hour * 60 + _timeEnd.minute;
        if (endMinutes <= startMinutes) {
          _timeEnd = TimeOfDay(
            hour: (_timeStart.hour + (_timeStart.minute + 30 >= 60 ? 1 : 0)) % 24,
            minute: (_timeStart.minute + 30) % 60,
          );
        }
      });
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _timeEnd,
      helpText: 'HORA DE FINALIZACIÓN',
      cancelText: 'CANCELAR',
      confirmText: 'SELECCIONAR',
    );
    if (picked != null) {
      final startMinutes = _timeStart.hour * 60 + _timeStart.minute;
      final endMinutes = picked.hour * 60 + picked.minute;
      if (endMinutes <= startMinutes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('La hora final debe ser posterior a la hora inicial'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        return;
      }
      setState(() {
        _timeEnd = picked;
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona al menos un día laboral'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final startMinutes = _timeStart.hour * 60 + _timeStart.minute;
    final endMinutes = _timeEnd.hour * 60 + _timeEnd.minute;
    if (endMinutes <= startMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El horario es inválido: fin debe ser mayor a inicio'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final sortedDays = _selectedDays.toList()..sort();
    Navigator.pop(context);

    widget.onSave(
      nombre: _nameController.text.trim(),
      descripcion: _descController.text.trim(),
      days: sortedDays,
      area: _selectedArea,
      category: _selectedCategory,
      timeStart: _formatTime(_timeStart),
      timeEnd: _formatTime(_timeEnd),
      isFixed: _isFixed || (sortedDays.length == 5 && _isFixed),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.azul.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.add_task, color: AppColors.azul, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nueva Actividad Estándar',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.txt,
                            ),
                          ),
                          Text(
                            'Programación operativa en SQLite',
                            style: TextStyle(fontSize: 12, color: AppColors.gris),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Campo Nombre
                const Text(
                  'Nombre de la actividad *',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.txt),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa el nombre de la actividad' : null,
                  decoration: InputDecoration(
                    hintText: 'Ej: Control de variables en proceso extrusión',
                    prefixIcon: const Icon(Icons.assignment_outlined, size: 20, color: AppColors.azul),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 14),

                // Selector de Área Real
                const Text(
                  'Área responsable *',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.txt),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedArea,
                  isExpanded: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.business_outlined, size: 20, color: AppColors.azul),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  items: availableAreas.map((area) {
                    return DropdownMenuItem(
                      value: area,
                      child: Text(area, style: const TextStyle(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedArea = val);
                  },
                ),
                const SizedBox(height: 14),

                // Selector de Categoría
                const Text(
                  'Categoría de Trabajo Estándar *',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.txt),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.category_outlined, size: 20, color: AppColors.azul),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  items: availableCategories.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(cat, style: const TextStyle(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategory = val);
                  },
                ),
                const SizedBox(height: 14),

                // Horario Inicio y Fin
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Hora Inicio',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.txt),
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: _pickStartTime,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.borde),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time, size: 18, color: AppColors.azul),
                                  const SizedBox(width: 8),
                                  Text(
                                    _formatTime(_timeStart),
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Hora Fin',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.txt),
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: _pickEndTime,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.borde),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.alarm_off, size: 18, color: AppColors.azul),
                                  const SizedBox(width: 8),
                                  Text(
                                    _formatTime(_timeEnd),
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Selector de Días Laborales
                const Text(
                  'Días de ejecución (Semana laboral) *',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.txt),
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(5, (index) {
                    final dayNum = index + 1;
                    final isChecked = _selectedDays.contains(dayNum);

                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: index == 0 ? 0 : 3,
                          right: index == 4 ? 0 : 3,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isChecked) {
                                _selectedDays.remove(dayNum);
                              } else {
                                _selectedDays.add(dayNum);
                              }
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isChecked ? AppColors.azul : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isChecked ? AppColors.azul : AppColors.borde,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              DateUtilsHelper.diasCortos[index],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isChecked ? Colors.white : AppColors.txt,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 14),

                // Switch de Actividad Fija
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Actividad fija / obligatoria diaria',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.txt),
                  ),
                  subtitle: const Text(
                    'Las actividades fijas no pueden ser postergadas ni movidas de día',
                    style: TextStyle(fontSize: 12, color: AppColors.gris),
                  ),
                  value: _isFixed,
                  activeColor: AppColors.azul,
                  onChanged: (val) {
                    setState(() {
                      _isFixed = val;
                      if (val) {
                        // Si se marca fija, típicamente aplica a toda la semana
                        _selectedDays = {1, 2, 3, 4, 5};
                      }
                    });
                  },
                ),
                const SizedBox(height: 10),

                // Descripción
                const Text(
                  'Descripción detallada (opcional)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.txt),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Detalles, objetivos o instrucciones de la actividad',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 20),

                // Botones Guardar y Cancelar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                    label: const Text(
                      'Guardar Actividad',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.azul,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFF1F5F9),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: AppColors.gris, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
