import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:tempsupabaseadmintool/providers/dashboard_provider.dart';
import 'package:tempsupabaseadmintool/models/collected_task.dart';
import 'package:tempsupabaseadmintool/theme/admin_tokens.dart';
import 'package:tempsupabaseadmintool/widgets/rider_filter_bar.dart';
import 'package:tempsupabaseadmintool/screens/task_detail_screen.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        if (provider.state == DashboardLoadState.loading) {
          return const Center(child: CircularProgressIndicator(color: AdminTokens.brand));
        }
        if (provider.state == DashboardLoadState.error) {
          return Center(child: Text(provider.error ?? 'Failed to load', style: const TextStyle(color: AdminTokens.subtle)));
        }

        final tasks = provider.tasks;

        return RefreshIndicator(
          color: AdminTokens.brand,
          onRefresh: provider.refresh,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const RiderFilterBar(),
              const SizedBox(height: 16),
              if (tasks.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(child: Text('No visits for the selected filters', style: TextStyle(color: AdminTokens.muted))),
                )
              else
                ...tasks.map((t) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _TaskTile(task: t),
                    )),
            ],
          ),
        );
      },
    );
  }
}

class _TaskTile extends StatelessWidget {
  final CollectedTask task;
  const _TaskTile({required this.task});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AdminTokens.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: AdminTokens.brand.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              alignment: Alignment.center,
              child: Text(
                task.riderId.isNotEmpty ? task.riderId[0].toUpperCase() : '?',
                style: const TextStyle(fontWeight: FontWeight.w800, color: AdminTokens.brand),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.clientName, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: AdminTokens.ink)),
                  const SizedBox(height: 3),
                  Text(
                    'Rider ${task.riderId} \u00b7 ${task.clientCode} \u00b7 ${DateFormat('MMM d, h:mm a').format(task.createdAt)}',
                    style: const TextStyle(fontSize: 12, color: AdminTokens.muted),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${task.samplesCollected} samples', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AdminTokens.ink)),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: task.trfCount > 0 ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    task.trfCount > 0 ? '${task.trfCount} TRF' : 'TRF pending',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: task.trfCount > 0 ? const Color(0xFF16A34A) : const Color(0xFF92400E),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
