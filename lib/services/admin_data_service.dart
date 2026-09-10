import 'package:tempsupabaseadmintool/core/supabase_client_service.dart';
import 'package:tempsupabaseadmintool/models/collected_task.dart';
import 'package:tempsupabaseadmintool/models/trf_upload.dart';

class AdminDataService {
  final _sb = SupabaseClientService().client;

  // NOTE: matches the bucket used by the rider app's TRF upload flow.
  static const _bucket = 'trf-photos';

  Future<List<CollectedTask>> fetchTasks({
    DateTime? from,
    DateTime? to,
    String? riderId,
  }) async {
    var query = _sb.from('collected_tasks').select();

    if (riderId != null && riderId.isNotEmpty) {
      query = query.eq('rider_id', riderId);
    }
    if (from != null) {
      query = query.gte('created_at', from.toIso8601String());
    }
    if (to != null) {
      query = query.lte('created_at', to.toIso8601String());
    }

    final taskRows = await query.order('created_at', ascending: false);

    // TRF counts are fetched separately and joined client-side, same
    // approach the rider app's TRF Pending screen already uses.
    final trfRows = await _sb.from('trf_uploads').select('task_id');
    final counts = <int, int>{};
    for (final r in (trfRows as List)) {
      final tid = r['task_id'] as int;
      counts[tid] = (counts[tid] ?? 0) + 1;
    }

    return (taskRows as List)
        .map((row) => CollectedTask.fromRow(
              row as Map<String, dynamic>,
              counts[row['id'] as int] ?? 0,
            ))
        .toList();
  }

  Future<List<TrfUpload>> fetchTrfsForTask(int taskId) async {
    final rows = await _sb
        .from('trf_uploads')
        .select()
        .eq('task_id', taskId)
        .order('uploaded_at', ascending: false);

    return (rows as List)
        .map((r) => TrfUpload.fromRow(r as Map<String, dynamic>))
        .toList();
  }

  /// Tries a signed URL first (works for a private bucket), falls back to
  /// a public URL if the bucket turns out to be public.
  Future<String> getImageUrl(String path) async {
    try {
      return await _sb.storage.from(_bucket).createSignedUrl(path, 3600);
    } catch (_) {
      return _sb.storage.from(_bucket).getPublicUrl(path);
    }
  }
}
