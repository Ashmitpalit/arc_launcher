class WidgetInfo {
  final String id;
  final String type;
  final Map<String, dynamic>? config;
  final DateTime addedDate;
  final bool isEnabled;

  WidgetInfo({
    required this.id,
    required this.type,
    this.config,
    required this.addedDate,
    this.isEnabled = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'config': config,
      'addedDate': addedDate.millisecondsSinceEpoch,
      'isEnabled': isEnabled ? 1 : 0,
    };
  }

  factory WidgetInfo.fromMap(Map<String, dynamic> map) {
    return WidgetInfo(
      id: map['id'] as String,
      type: map['type'] as String,
      config: map['config'] as Map<String, dynamic>?,
      addedDate: DateTime.fromMillisecondsSinceEpoch(map['addedDate'] as int),
      isEnabled: map['isEnabled'] == 1,
    );
  }

  WidgetInfo copyWith({
    String? id,
    String? type,
    Map<String, dynamic>? config,
    DateTime? addedDate,
    bool? isEnabled,
  }) {
    return WidgetInfo(
      id: id ?? this.id,
      type: type ?? this.type,
      config: config ?? this.config,
      addedDate: addedDate ?? this.addedDate,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WidgetInfo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'WidgetInfo(id: $id, type: $type, isEnabled: $isEnabled)';
  }
}
