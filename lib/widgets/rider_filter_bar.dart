import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:tempsupabaseadmintool/providers/dashboard_provider.dart';
import 'package:tempsupabaseadmintool/theme/admin_tokens.dart';

class RiderFilterBar extends StatelessWidget {
  const RiderFilterBar({super.key});

  Future<void> _pickRange(BuildContext context, DashboardProvider provider) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      initialDateRange: provider.dateRange,
    );
    if (picked != null) {
      provider.setDateRange(DateTimeRange(
        start: DateTime(picked.start.year, picked.start.month, picked.start.day),
        end: DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        final range = provider.dateRange;
        final rangeLabel = range == null
            ? 'All dates'
            : '${DateFormat('MMM d').format(range.start)} - ${DateFormat('MMM d').format(range.end)}';

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _FilterChipButton(
              icon: Icons.calendar_today_rounded,
              label: rangeLabel,
              onTap: () => _pickRange(context, provider),
              trailing: range != null
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, size: 16),
                      onPressed: () => provider.setDateRange(null),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    )
                  : null,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AdminTokens.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  value: provider.selectedRiderId,
                  hint: const Text('All riders', style: TextStyle(fontSize: 13.5, color: AdminTokens.subtle)),
                  icon: const Icon(Icons.expand_more_rounded, size: 18),
                  items: [
                    const DropdownMenuItem<String?>(value: null, child: Text('All riders')),
                    ...provider.riderIds.map(
                      (id) => DropdownMenuItem<String?>(value: id, child: Text(id)),
                    ),
                  ],
                  onChanged: provider.setRiderFilter,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Refresh',
              onPressed: provider.refresh,
              icon: const Icon(Icons.refresh_rounded, color: AdminTokens.brand),
            ),
          ],
        );
      },
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;
  const _FilterChipButton({required this.icon, required this.label, required this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AdminTokens.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: AdminTokens.brand),
            const SizedBox(width: 7),
            Text(label, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AdminTokens.ink)),
            if (trailing != null) ...[const SizedBox(width: 6), trailing!],
          ],
        ),
      ),
    );
  }
}
