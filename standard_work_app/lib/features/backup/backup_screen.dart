import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../data/services/standard_work_provider.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _isProcessing = false;

  Future<void> _exportBackup() async {
    setState(() => _isProcessing = true);
    final provider = context.read<StandardWorkProvider>();
    final user = provider.currentProfile;

    try {
      final data = await provider.exportBackupJson();
      if (data == null) throw Exception('No hay datos disponibles para exportar');

      final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
      final dir = await getTemporaryDirectory();
      final now = DateTime.now();
      final timestamp = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour}${now.minute}';
      final file = File('${dir.path}/Backup_StandardWork_${user?.id ?? "U"}_$timestamp.json');
      await file.writeAsString(jsonStr);

      if (mounted) {
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Respaldo Local Standard Work · Darnel Group (${user?.nombre})',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al exportar: $e')));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _importBackup() async {
    final provider = context.read<StandardWorkProvider>();

    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (files.isEmpty || files.first.path == null) return;

      final file = File(files.first.path!);
      final content = await file.readAsString();
      final Map<String, dynamic> data = jsonDecode(content);

      if (!mounted) return;

      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('¿Restaurar Copia de Seguridad?'),
          content: Text(
            'Se restaurarán las actividades e historial del perfil correspondiente.\n\nFecha de exportación: ${data["exportedAt"] ?? "N/A"}\n\nLos registros actuales se reemplazarán de forma segura.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.azul),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Restaurar'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      setState(() => _isProcessing = true);
      final msg = await provider.restoreBackupJson(data);

      if (mounted && msg != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Archivo no válido o error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StandardWorkProvider>();
    final user = provider.currentProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Copia de Seguridad Local'),
        backgroundColor: AppColors.azul,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.backup_outlined, color: AppColors.azul, size: 28),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Exportar Respaldo Local (JSON)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              Text('Perfil: ${user?.nombre}', style: const TextStyle(fontSize: 12, color: AppColors.gris)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Crea un archivo JSON seguro con tus actividades, ejecuciones, historial y registros de auditoría. Permite transferir tus datos a otro teléfono sin necesidad de conexión a internet ni servidores.',
                      style: TextStyle(fontSize: 13, color: AppColors.txt),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Crear y Compartir Respaldo'),
                        onPressed: _isProcessing ? null : _exportBackup,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.restore_page_outlined, color: AppColors.azul2, size: 28),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text('Restaurar Copia de Seguridad', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Restaura tus actividades e historial a partir de un archivo JSON generado previamente. La base de datos realiza la operación mediante transacciones atómicas seguras.',
                      style: TextStyle(fontSize: 13, color: AppColors.txt),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.download),
                        label: const Text('Seleccionar Archivo JSON y Restaurar'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.azul, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: _isProcessing ? null : _importBackup,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
