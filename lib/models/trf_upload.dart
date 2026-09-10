class TrfUpload {
  final int id;
  final int taskId;
  final String riderId;
  final String imagePath;
  final DateTime uploadedAt;

  TrfUpload({
    required this.id,
    required this.taskId,
    required this.riderId,
    required this.imagePath,
    required this.uploadedAt,
  });

  factory TrfUpload.fromRow(Map<String, dynamic> row) {
    return TrfUpload(
      id: row['id'] as int,
      taskId: row['task_id'] as int,
      riderId: row['rider_id'] as String,
      imagePath: row['image_path'] as String,
      uploadedAt: DateTime.parse(row['uploaded_at'] as String),
    );
  }
}
