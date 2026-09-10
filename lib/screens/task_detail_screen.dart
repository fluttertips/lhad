import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tempsupabaseadmintool/models/collected_task.dart';
import 'package:tempsupabaseadmintool/models/trf_upload.dart';
import 'package:tempsupabaseadmintool/services/admin_data_service.dart';
import 'package:tempsupabaseadmintool/theme/admin_tokens.dart';

class TaskDetailScreen extends StatefulWidget {
  final CollectedTask task;
  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _service = AdminDataService();
  late Future<List<TrfUpload>> _trfsFuture;

  @override
  void initState() {
    super.initState();
    _trfsFuture = _service.fetchTrfsForTask(widget.task.id);
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    return Scaffold(
      backgroundColor: AdminTokens.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AdminTokens.ink),
        title: const Text('Visit Details', style: TextStyle(color: AdminTokens.ink, fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AdminTokens.border)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.clientName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AdminTokens.ink)),
                const SizedBox(height: 4),
                Text(task.clientCode, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AdminTokens.brand)),
                if (task.clientAddress != null && task.clientAddress!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.location_on_outlined, size: 15, color: AdminTokens.muted),
                    const SizedBox(width: 5),
                    Expanded(child: Text(task.clientAddress!, style: const TextStyle(fontSize: 13, color: AdminTokens.subtle))),
                  ]),
                ],
                const Divider(height: 28, color: AdminTokens.border),
                _detailRow('Rider', task.riderId),
                _detailRow('Visited', DateFormat('MMM d, yyyy \u00b7 h:mm a').format(task.createdAt)),
                _detailRow('Samples collected', '${task.samplesCollected}'),
                _detailRow('Contact person', task.contactPerson?.isNotEmpty == true ? task.contactPerson! : '\u2014'),
                _detailRow('Cash collected', NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 2).format(task.cashCollected)),
                if (task.latitude != null && task.longitude != null)
                  _detailRow('Location', '${task.latitude!.toStringAsFixed(5)}, ${task.longitude!.toStringAsFixed(5)}'),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text('TRF Uploads', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AdminTokens.ink)),
          const SizedBox(height: 12),
          FutureBuilder<List<TrfUpload>>(
            future: _trfsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: Center(child: CircularProgressIndicator(color: AdminTokens.brand)),
                );
              }
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Center(child: Text('Could not load TRFs: ${snapshot.error}', style: const TextStyle(color: AdminTokens.danger))),
                );
              }
              final trfs = snapshot.data ?? [];
              if (trfs.isEmpty) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AdminTokens.border)),
                  child: const Center(
                    child: Column(
                      children: [
                        Icon(Icons.pending_actions_rounded, color: AdminTokens.muted, size: 32),
                        SizedBox(height: 8),
                        Text('No TRF uploaded yet for this visit', style: TextStyle(color: AdminTokens.muted)),
                      ],
                    ),
                  ),
                );
              }
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: trfs.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, i) => _TrfThumb(trf: trfs[i], service: _service),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text(label, style: const TextStyle(fontSize: 13, color: AdminTokens.muted))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AdminTokens.ink))),
        ],
      ),
    );
  }
}

class _TrfThumb extends StatelessWidget {
  final TrfUpload trf;
  final AdminDataService service;
  const _TrfThumb({required this.trf, required this.service});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: service.getImageUrl(trf.imagePath),
      builder: (context, snapshot) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            color: AdminTokens.bg,
            child: snapshot.connectionState == ConnectionState.waiting
                ? const Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)))
                : snapshot.hasError || !snapshot.hasData
                    ? const Center(child: Icon(Icons.broken_image_outlined, color: AdminTokens.muted))
                    : InkWell(
                        onTap: () => _showFullImage(context, snapshot.data!),
                        child: Image.network(
                          snapshot.data!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image_outlined, color: AdminTokens.muted)),
                        ),
                      ),
          ),
        );
      },
    );
  }

  void _showFullImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: InteractiveViewer(child: Image.network(url)),
      ),
    );
  }
}
