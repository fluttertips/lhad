import 'package:flutter/material.dart';
import 'package:tempsupabaseadmintool/models/collected_task.dart';
import 'package:tempsupabaseadmintool/services/admin_data_service.dart';

enum DashboardLoadState { loading, loaded, error }

class RiderSummary {
  int visits = 0;
  int samples = 0;
  double cash = 0;
  int pendingTrf = 0;
}

class DashboardProvider extends ChangeNotifier {
  final AdminDataService _service;
  DashboardProvider({AdminDataService? service}) : _service = service ?? AdminDataService();

  DashboardLoadState _state = DashboardLoadState.loading;
  DashboardLoadState get state => _state;

  String? _error;
  String? get error => _error;

  List<CollectedTask> _tasks = [];

  DateTimeRange? _dateRange;
  DateTimeRange? get dateRange => _dateRange;

  String? _selectedRiderId;
  String? get selectedRiderId => _selectedRiderId;

  /// Tasks after the in-memory rider filter is applied. Date filtering is
  /// applied server-side in [load] since it changes what gets fetched.
  List<CollectedTask> get tasks {
    if (_selectedRiderId == null || _selectedRiderId!.isEmpty) return _tasks;
    return _tasks.where((t) => t.riderId == _selectedRiderId).toList();
  }

  List<String> get riderIds {
    final ids = _tasks.map((t) => t.riderId).toSet().toList();
    ids.sort();
    return ids;
  }

  int get totalVisits => tasks.length;
  int get totalSamples => tasks.fold(0, (sum, t) => sum + t.samplesCollected);
  double get totalCash => tasks.fold(0.0, (sum, t) => sum + t.cashCollected);
  int get pendingTrfVisits => tasks.where((t) => t.trfCount == 0).length;
  int get uploadedTrfVisits => tasks.where((t) => t.trfCount > 0).length;

  Map<String, RiderSummary> get riderSummaries {
    final map = <String, RiderSummary>{};
    for (final t in tasks) {
      final s = map.putIfAbsent(t.riderId, () => RiderSummary());
      s.visits += 1;
      s.samples += t.samplesCollected;
      s.cash += t.cashCollected;
      if (t.trfCount == 0) s.pendingTrf += 1;
    }
    return map;
  }

  Future<void> load() async {
    _state = DashboardLoadState.loading;
    notifyListeners();
    try {
      _tasks = await _service.fetchTasks(from: _dateRange?.start, to: _dateRange?.end);
      _state = DashboardLoadState.loaded;
    } catch (e) {
      _error = e.toString();
      _state = DashboardLoadState.error;
    }
    notifyListeners();
  }

  void setDateRange(DateTimeRange? range) {
    _dateRange = range;
    load();
  }

  void setRiderFilter(String? riderId) {
    _selectedRiderId = riderId;
    notifyListeners();
  }

  Future<void> refresh() => load();
}
