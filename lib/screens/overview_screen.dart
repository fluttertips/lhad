import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:tempsupabaseadmintool/providers/dashboard_provider.dart';
import 'package:tempsupabaseadmintool/theme/admin_tokens.dart';
import 'package:tempsupabaseadmintool/widgets/stat_card.dart';
import 'package:tempsupabaseadmintool/widgets/rider_filter_bar.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        if (provider.state == DashboardLoadState.loading) {
          return const Center(child: CircularProgressIndicator(color: AdminTokens.brand));
        }
        if (provider.state == DashboardLoadState.error) {
          return _ErrorView(message: provider.error ?? 'Something went wrong', onRetry: provider.refresh);
        }

        return RefreshIndicator(
          color: AdminTokens.brand,
          onRefresh: provider.refresh,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cols = constraints.maxWidth >= 900 ? 4 : 2;
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const RiderFilterBar(),
                  const SizedBox(height: 20),
                  GridView.count(
                    crossAxisCount: cols,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.5,
                    children: [
                      StatCard(label: 'Total Visits', value: '${provider.totalVisits}', icon: Icons.route_rounded, color: AdminTokens.brand),
                      StatCard(label: 'Samples Collected', value: '${provider.totalSamples}', icon: Icons.science_rounded, color: AdminTokens.brandDark),
                      StatCard(
                        label: 'Cash Collected',
                        value: NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0).format(provider.totalCash),
                        icon: Icons.currency_rupee_rounded,
                        color: AdminTokens.success,
                      ),
                      StatCard(label: 'TRF Pending', value: '${provider.pendingTrfVisits}', icon: Icons.pending_actions_rounded, color: AdminTokens.warning),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Text('By Rider', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AdminTokens.ink)),
                  const SizedBox(height: 12),
                  if (provider.riderSummaries.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: Center(child: Text('No activity for the selected filters', style: TextStyle(color: AdminTokens.muted))),
                    )
                  else
                    _RiderSummaryTable(provider: provider),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _RiderSummaryTable extends StatelessWidget {
  final DashboardProvider provider;
  const _RiderSummaryTable({required this.provider});

  @override
  Widget build(BuildContext context) {
    final entries = provider.riderSummaries.entries.toList()
      ..sort((a, b) => b.value.visits.compareTo(a.value.visits));
    final money = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminTokens.border),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(AdminTokens.bg),
          columns: const [
            DataColumn(label: Text('Rider')),
            DataColumn(label: Text('Visits')),
            DataColumn(label: Text('Samples')),
            DataColumn(label: Text('Cash')),
            DataColumn(label: Text('TRF Pending')),
          ],
          rows: entries.map((e) {
            final s = e.value;
            return DataRow(cells: [
              DataCell(Text(e.key, style: const TextStyle(fontWeight: FontWeight.w700))),
              DataCell(Text('${s.visits}')),
              DataCell(Text('${s.samples}')),
              DataCell(Text(money.format(s.cash))),
              DataCell(Text(
                '${s.pendingTrf}',
                style: TextStyle(color: s.pendingTrf > 0 ? AdminTokens.warning : AdminTokens.success, fontWeight: FontWeight.w700),
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 40, color: AdminTokens.muted),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AdminTokens.subtle)),
            const SizedBox(height: 14),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
