import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils_helper.dart';
import '../../data/models/app_models.dart';
import '../../data/services/standard_work_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _filterState = 'ALL'; // 'ALL', 'DONE', 'PENDING'
  String _search = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showDetailModal(BuildContext context, ActivityInstance item, UserProfile? user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final diaNombre = DateUtilsHelper.diasCompletos[item.day - 1];
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            top: 16,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).padding.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: item.done
                          ? AppColors.verde.withValues(alpha: 0.12)
                          : AppColors.rojo.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      item.done ? Icons.check_circle_outline : Icons.pending_actions,
                      color: item.done ? AppColors.verde : AppColors.rojo,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: item.done ? AppColors.verdeBg : AppColors.rojoBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            item.done ? 'ESTADO: REALIZADA' : 'ESTADO: PENDIENTE',
                            style: TextStyle(
                              color: item.done ? AppColors.verde : AppColors.rojo,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.nombre,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.txt,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 14),

              // Campos detallados de auditoría
              _buildDetailRow(Icons.calendar_today_outlined, 'Día y Semana', '$diaNombre (Semana ${item.weekKey})'),
              _buildDetailRow(Icons.access_time_outlined, 'Horario programado', '${item.timeStart} - ${item.timeEnd}'),
              _buildDetailRow(Icons.business_outlined, 'Área responsable', item.area.isNotEmpty ? item.area : (user?.area ?? 'No asignada')),
              _buildDetailRow(Icons.category_outlined, 'Categoría', item.category),
              _buildDetailRow(Icons.person_outline, 'Responsable registrado', user?.nombre ?? item.userId),
              _buildDetailRow(Icons.push_pin_outlined, 'Tipo de actividad', item.fija ? 'Actividad Fija / Obligatoria diaria' : 'Actividad Flexible / Ordinaria'),
              
              if (item.descripcion.isNotEmpty)
                _buildDetailRow(Icons.description_outlined, 'Descripción', item.descripcion),

              if (item.completedAt != null)
                _buildDetailRow(Icons.done_all, 'Fecha/Hora Ejecución', item.completedAt.toString().substring(0, 16)),

              if (item.observaciones != null && item.observaciones!.isNotEmpty)
                _buildAlertBox('Observaciones registradas', item.observaciones!, Colors.blue),

              if (item.motivoNoRealizada != null && item.motivoNoRealizada!.isNotEmpty)
                _buildAlertBox('Motivo de Incumplimiento', item.motivoNoRealizada!, Colors.red),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.azul,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Cerrar Detalle', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.azul),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 11, color: AppColors.gris, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 13, color: AppColors.txt, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertBox(String title, String message, MaterialColor color) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: color.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color.shade800)),
                const SizedBox(height: 3),
                Text(message, style: TextStyle(fontSize: 12, color: color.shade900)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.azul,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        title: const Text('Historial de Ejecuciones'),
      ),
      body: Consumer<StandardWorkProvider>(
        builder: (context, provider, child) {
          final user = provider.currentProfile;
          final all = provider.instances;

          final filtered = all.where((item) {
            if (_filterState == 'DONE' && !item.done) return false;
            if (_filterState == 'PENDING' && item.done) return false;

            if (_search.isNotEmpty) {
              final q = _search.toLowerCase();
              final matchesName = item.nombre.toLowerCase().contains(q);
              final matchesDesc = item.descripcion.toLowerCase().contains(q);
              final matchesObs = item.observaciones?.toLowerCase().contains(q) ?? false;
              final matchesMot = item.motivoNoRealizada?.toLowerCase().contains(q) ?? false;
              if (!matchesName && !matchesDesc && !matchesObs && !matchesMot) return false;
            }
            return true;
          }).toList();

          return Column(
            children: [
              // Barra de filtros superiores
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Buscar por nombre, observación o motivo...',
                        prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.gris),
                        suffixIcon: _search.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _search = '');
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onChanged: (val) => setState(() => _search = val.trim()),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _FilterChip(
                          label: 'Todas (${all.length})',
                          isSelected: _filterState == 'ALL',
                          onTap: () => setState(() => _filterState = 'ALL'),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Realizadas (${all.where((x) => x.done).length})',
                          isSelected: _filterState == 'DONE',
                          onTap: () => setState(() => _filterState = 'DONE'),
                          activeColor: AppColors.verde,
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Pendientes (${all.where((x) => !x.done).length})',
                          isSelected: _filterState == 'PENDING',
                          onTap: () => setState(() => _filterState = 'PENDING'),
                          activeColor: AppColors.rojo,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Banner con indicación UX
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: const Color(0xFFEFF6FF),
                child: const Row(
                  children: [
                    Icon(Icons.touch_app_outlined, size: 16, color: AppColors.azul),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Mantén presionada una actividad para ver su trazabilidad y ficha completa.',
                        style: TextStyle(fontSize: 12, color: AppColors.azul, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),

              // Lista de Registros
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history_toggle_off, size: 48, color: AppColors.gris.withValues(alpha: 0.5)),
                            const SizedBox(height: 12),
                            const Text('No se encontraron registros en el historial', style: TextStyle(color: AppColors.gris)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(14),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          final diaNombre = DateUtilsHelper.diasCompletos[item.day - 1];

                          return Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () => _showDetailModal(context, item, user),
                              onLongPress: () => _showDetailModal(context, item, user),
                              child: Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: item.done ? AppColors.verdeBg : AppColors.rojoBg,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            item.done ? '✔ Realizada' : '✖ Pendiente',
                                            style: TextStyle(
                                              color: item.done ? AppColors.verde : AppColors.rojo,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          'Semana: ${item.weekKey} · $diaNombre',
                                          style: const TextStyle(fontSize: 11, color: AppColors.gris),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item.nombre,
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.txt),
                                    ),
                                    Text(
                                      item.descripcion,
                                      style: const TextStyle(fontSize: 12, color: AppColors.gris),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(Icons.business, size: 13, color: Colors.grey.shade600),
                                        const SizedBox(width: 4),
                                        Text(
                                          item.area.isNotEmpty ? item.area : (user?.area ?? 'Área General'),
                                          style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(width: 12),
                                        Icon(Icons.access_time, size: 13, color: Colors.grey.shade600),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${item.timeStart} - ${item.timeEnd}',
                                          style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                                        ),
                                      ],
                                    ),
                                    if (item.observaciones != null && item.observaciones!.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEFF6FF),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.note_alt_outlined, size: 16, color: AppColors.azul),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                'Obs: ${item.observaciones}',
                                                style: const TextStyle(fontSize: 11, color: AppColors.azul),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                    if (item.motivoNoRealizada != null && item.motivoNoRealizada!.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFEF2F2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.rojo),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                'Motivo: ${item.motivoNoRealizada}',
                                                style: const TextStyle(fontSize: 11, color: AppColors.rojo),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                    if (item.completedAt != null) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        'Completada: ${item.completedAt.toString().substring(0, 16)} por ${user?.nombre}',
                                        style: const TextStyle(fontSize: 10, color: AppColors.gris),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color activeColor;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.activeColor = AppColors.azul,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppColors.gris,
          ),
        ),
      ),
    );
  }
}
