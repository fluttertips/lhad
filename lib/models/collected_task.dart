class CollectedTask {
  final int id;
  final String riderId;
  final String clientCode;
  final String clientName;
  final String? clientAddress;
  final int samplesCollected;
  final String? contactPerson;
  final double cashCollected;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final int trfCount;

  CollectedTask({
    required this.id,
    required this.riderId,
    required this.clientCode,
    required this.clientName,
    this.clientAddress,
    required this.samplesCollected,
    this.contactPerson,
    required this.cashCollected,
    this.latitude,
    this.longitude,
    required this.createdAt,
    required this.trfCount,
  });

  factory CollectedTask.fromRow(Map<String, dynamic> row, int trfCount) {
    return CollectedTask(
      id: row['id'] as int,
      riderId: row['rider_id'] as String,
      clientCode: row['client_code'] as String,
      clientName: row['client_name'] as String,
      clientAddress: row['client_address'] as String?,
      samplesCollected: row['samples_collected'] as int? ?? 0,
      contactPerson: row['contact_person'] as String?,
      cashCollected: (row['cash_collected'] as num?)?.toDouble() ?? 0.0,
      latitude: (row['latitude'] as num?)?.toDouble(),
      longitude: (row['longitude'] as num?)?.toDouble(),
      createdAt: DateTime.parse(row['created_at'] as String),
      trfCount: trfCount,
    );
  }
}
