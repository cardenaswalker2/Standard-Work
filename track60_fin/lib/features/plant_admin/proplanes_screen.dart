import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/app_models.dart';
import '../../data/services/standard_work_provider.dart';
import '../../data/services/proplanes_excel_service.dart';
import '../../core/theme/app_theme.dart';

class ProPlanesScreen extends StatefulWidget {
  final bool embedded;

  const ProPlanesScreen({super.key, this.embedded = false});

  @override
  State<ProPlanesScreen> createState() => _ProPlanesScreenState();
}

class _ProPlanesScreenState extends State<ProPlanesScreen> {
  String _selectedStatus = 'Todos';
  String _selectedArea = 'Todas';
  String _searchQuery = '';

  void _showAddPlanDialog(BuildContext context, StandardWorkProvider provider) {
    final planCtrl = TextEditingController();
    final respCtrl = TextEditingController();
    final areaCtrl = TextEditingController(text: 'Operaciones');
    final fechaCtrl = TextEditingController(
      text: DateTime.now().add(const Duration(days: 2)).toIso8601String().substring(0, 10),
    );
    final comCtrl = TextEditingController();

    // Lista de colaboradores para selector rápido
    final users = provider.usersForCurrentPlant;
    String? selectedUser = users.isNotEmpty ? users.first.nombre : null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.add_task_rounded, color: Color(0xFF002F6C)),
              SizedBox(width: 8),
              Text('Nuevo Plan / Compromiso', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: planCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Compromiso / Acción *',
                    hintText: 'Ej. Ajuste de cuchilla de troquelado',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: selectedUser,
                  decoration: const InputDecoration(labelText: 'Responsable Asignado *'),
                  items: users.map((u) => DropdownMenuItem(
                    value: u.nombre,
                    child: Text(
                      '${u.nombre} (${u.cargo})',
                      overflow: TextOverflow.ellipsis,
                    ),
                  )).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDlgState(() {
                        selectedUser = val;
                        respCtrl.text = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: 'Operaciones',
                  decoration: const InputDecoration(labelText: 'Área Operativa'),
                  items: const [
                    DropdownMenuItem(value: 'Operaciones', child: Text('Operaciones')),
                    DropdownMenuItem(value: 'Extrusión', child: Text('Extrusión')),
                    DropdownMenuItem(value: 'Termoformado', child: Text('Termoformado')),
                    DropdownMenuItem(value: 'Inyección', child: Text('Inyección')),
                    DropdownMenuItem(value: 'Calidad', child: Text('Calidad')),
                    DropdownMenuItem(value: 'Mantenimiento', child: Text('Mantenimiento')),
                    DropdownMenuItem(value: 'Logística', child: Text('Logística')),
                    DropdownMenuItem(value: 'SST / EHS', child: Text('SST / EHS')),
                  ],
                  onChanged: (val) {
                    if (val != null) areaCtrl.text = val;
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: fechaCtrl,
                  readOnly: true,
                  onTap: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: now.add(const Duration(days: 2)),
                      firstDate: now,
                      lastDate: now.add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setDlgState(() {
                        fechaCtrl.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                      });
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Fecha Compromiso (Tocar para elegir)',
                    prefixIcon: Icon(Icons.calendar_today_rounded, size: 18),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: comCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Comentarios / Instrucción Técnica',
                    hintText: 'Detalles adicionales o repuestos requeridos',
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar', style: TextStyle(color: Color(0xFF64748B))),
            ),
            ElevatedButton(
              onPressed: () async {
                if (planCtrl.text.isNotEmpty) {
                  final respFinal = selectedUser ?? respCtrl.text.trim();
                  await provider.addProPlan(
                    plan: planCtrl.text.trim(),
                    responsable: respFinal.isNotEmpty ? respFinal : 'Responsable Turno',
                    area: areaCtrl.text.trim(),
                    fechaCompromiso: fechaCtrl.text.trim(),
                    comentarios: comCtrl.text.trim(),
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Color(0xFF16A34A),
                        content: Text('¡Compromiso PROPLAN registrado con éxito!'),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF002F6C)),
              child: const Text('Guardar Plan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusUpdateDialog(BuildContext context, ProPlanModel plan, StandardWorkProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Actualizar Estado del Plan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusOption(ctx, plan, 'Pendiente', const Color(0xFFD97706), provider),
            _buildStatusOption(ctx, plan, 'En Proceso', const Color(0xFF0284C7), provider),
            _buildStatusOption(ctx, plan, 'Cumplido', const Color(0xFF16A34A), provider),
            _buildStatusOption(ctx, plan, 'Vencido', const Color(0xFFDC2626), provider),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.deleteProPlan(plan.id!);
            },
            child: const Text('Eliminar Plan', style: TextStyle(color: Color(0xFFDC2626))),
          ),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar')),
        ],
      ),
    );
  }

  Widget _buildStatusOption(BuildContext ctx, ProPlanModel plan, String status, Color color, StandardWorkProvider provider) {
    final isCurrent = plan.estado == status;
    return ListTile(
      dense: true,
      leading: Icon(
        isCurrent ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
        color: color,
      ),
      title: Text(status, style: TextStyle(fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal, color: color)),
      onTap: () async {
        Navigator.pop(ctx);
        await provider.updateProPlanStatus(planId: plan.id!, nuevoEstado: status);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StandardWorkProvider>(context);
    final allPlans = provider.proPlans;

    // Filtros
    final filtered = allPlans.where((p) {
      if (_selectedStatus != 'Todos' && p.estado != _selectedStatus) return false;
      if (_selectedArea != 'Todas' && p.area != _selectedArea) return false;
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchPlan = p.plan.toLowerCase().contains(query);
        final matchResp = p.responsable.toLowerCase().contains(query);
        if (!matchPlan && !matchResp) return false;
      }
      return true;
    }).toList();

    final areas = ['Todas', 'Extrusión', 'Termoformado', 'Inyección', 'Calidad', 'Mantenimiento', 'Logística', 'SST / EHS'];

    Widget bodyContent = Column(
      children: [
        // CABECERA / BARRA DE BÚSQUEDA Y EXPORTACIÓN EXCEL
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 38,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Buscar plan o responsable...',
                          hintStyle: const TextStyle(fontSize: 12),
                          prefixIcon: const Icon(Icons.search, size: 18),
                          contentPadding: const EdgeInsets.symmetric(vertical: 4),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                          ),
                        ),
                        onChanged: (val) => setState(() => _searchQuery = val),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await ProPlanesExcelService.instance.exportAndShareProPlanes(
                          plantId: provider.currentUser?.plantId,
                        );
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al exportar: $e')));
                        }
                      }
                    },
                    icon: const Icon(Icons.file_download_rounded, size: 16, color: Colors.white),
                    label: const Text('Excel', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  ElevatedButton.icon(
                    onPressed: () => _showAddPlanDialog(context, provider),
                    icon: const Icon(Icons.add, size: 16, color: Colors.white),
                    label: const Text('Plan', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF002F6C),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Chips de Estado
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['Todos', 'Pendiente', 'En Proceso', 'Cumplido', 'Vencido'].map((st) {
                    final isSel = _selectedStatus == st;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(st, style: TextStyle(fontSize: 10, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                        selected: isSel,
                        selectedColor: const Color(0xFF002F6C),
                        labelStyle: TextStyle(color: isSel ? Colors.white : Colors.black87),
                        onSelected: (val) {
                          if (val) setState(() => _selectedStatus = st);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 6),

              // Chips de Área
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: areas.map((ar) {
                    final isSel = _selectedArea == ar;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: FilterChip(
                        label: Text(ar, style: TextStyle(fontSize: 10, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                        selected: isSel,
                        onSelected: (val) {
                          setState(() => _selectedArea = val ? ar : 'Todas');
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        // LISTA DE PLANES
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 52, color: Colors.grey.shade400),
                      const SizedBox(height: 10),
                      Text(
                        'No hay compromisos con los filtros seleccionados',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final plan = filtered[index];
                    Color statusColor;
                    switch (plan.estado) {
                      case 'Cumplido':
                        statusColor = const Color(0xFF16A34A);
                        break;
                      case 'En Proceso':
                        statusColor = const Color(0xFF0284C7);
                        break;
                      case 'Vencido':
                        statusColor = const Color(0xFFDC2626);
                        break;
                      default:
                        statusColor = const Color(0xFFD97706);
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: App3D.cardShadow(baseColor: statusColor),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => _showStatusUpdateDialog(context, plan, provider),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF002F6C).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '#${plan.id ?? (index + 1)} · ${plan.area}',
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF002F6C)),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: statusColor.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        plan.estado.toUpperCase(),
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  plan.plan,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                ),
                                if (plan.comentarios != null && plan.comentarios!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    plan.comentarios!,
                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                                const SizedBox(height: 10),
                                const Divider(height: 1),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.person_outline_rounded, size: 14, color: Color(0xFF64748B)),
                                        const SizedBox(width: 4),
                                        Text(plan.responsable, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.event_rounded, size: 14, color: Color(0xFF64748B)),
                                        const SizedBox(width: 4),
                                        Text('Límite: ${plan.fechaCompromiso}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );

    if (widget.embedded) {
      return bodyContent;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF002F6C),
        elevation: 0,
        title: const Text('PROPLANES · Compromisos de Planta', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: bodyContent,
    );
  }
}

