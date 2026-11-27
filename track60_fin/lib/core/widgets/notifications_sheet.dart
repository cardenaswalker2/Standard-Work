import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/app_models.dart';
import 'notification_detail_dialog.dart';

class NotificationsSheet extends StatefulWidget {
  final List<NotificationModel> notifications;
  final Function(int id) onMarkAsRead;
  final VoidCallback onMarkAllAsRead;

  const NotificationsSheet({
    super.key,
    required this.notifications,
    required this.onMarkAsRead,
    required this.onMarkAllAsRead,
  });

  @override
  State<NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends State<NotificationsSheet> {
  String _filter = 'Todas'; // Todas, Sin leer, Alertas, Asignaciones

  @override
  Widget build(BuildContext context) {
    final unreadCount = widget.notifications.where((n) => !n.isRead).length;
    final filtered = widget.notifications.where((n) {
      if (_filter == 'Sin leer') return !n.isRead;
      if (_filter == 'Alertas') return n.type == 'alert';
      if (_filter == 'Asignaciones') return n.type == 'corporate_assignment' || n.type == 'assignment';
      return true;
    }).toList();

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F7FB),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: const Color(0xFF002F6C).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.notifications_active_rounded, color: Color(0xFF002F6C), size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Centro de Notificaciones',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                          ),
                          Text(
                            unreadCount > 0 ? '$unreadCount pendiente(s) por leer' : 'Todo al día',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: unreadCount > 0 ? const Color(0xFF007AFF) : const Color(0xFF16A34A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (unreadCount > 0)
                      TextButton.icon(
                        onPressed: widget.onMarkAllAsRead,
                        icon: const Icon(Icons.done_all_rounded, size: 16, color: Color(0xFF007AFF)),
                        label: const Text(
                          'Marcar leídas',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF007AFF)),
                        ),
                      ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['Todas', 'Sin leer', 'Alertas', 'Asignaciones'].map((lbl) {
                      final selected = _filter == lbl;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(
                            lbl,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: selected ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          selected: selected,
                          selectedColor: const Color(0xFF002F6C),
                          backgroundColor: const Color(0xFFF8FAFC),
                          side: BorderSide(color: selected ? const Color(0xFF002F6C) : const Color(0xFFE2E8F0)),
                          onSelected: (_) => setState(() => _filter = lbl),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 42, horizontal: 20),
              child: Column(
                children: [
                  Icon(Icons.mark_email_read_outlined, size: 46, color: Colors.grey.shade400),
                  const SizedBox(height: 10),
                  Text(
                    'No hay notificaciones en esta vista',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(14),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final notif = filtered[index];
                  final isAlert = notif.type == 'alert';
                  final isCorporate = notif.type == 'corporate_assignment';
                  final accent = isAlert
                      ? const Color(0xFFDC2626)
                      : (isCorporate ? const Color(0xFF7C3AED) : const Color(0xFF0284C7));
                  final tag = isAlert ? 'Alerta' : (isCorporate ? 'Comunicado' : 'Asignación');
                  final icon = isAlert
                      ? Icons.warning_amber_rounded
                      : (isCorporate ? Icons.campaign_rounded : Icons.task_alt_rounded);

                  return InkWell(
                    onTap: () {
                      if (notif.id != null && !notif.isRead) {
                        widget.onMarkAsRead(notif.id!);
                      }
                      NotificationDetailDialog.show(context, notif);
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: notif.isRead ? Colors.white : const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: notif.isRead ? const Color(0xFFE2E8F0) : const Color(0xFF93C5FD),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(icon, color: accent, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: accent.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(tag, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: accent)),
                                    ),
                                    const Spacer(),
                                    Text(
                                      DateFormat('dd/MM · HH:mm').format(notif.timestamp),
                                      style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  notif.title,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.w800,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                if (notif.body.isNotEmpty) ...[
                                  const SizedBox(height: 3),
                                  Text(
                                    notif.body,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (!notif.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(left: 8, top: 4),
                              decoration: const BoxDecoration(color: Color(0xFF007AFF), shape: BoxShape.circle),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
