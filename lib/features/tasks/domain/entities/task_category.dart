class TaskCategory {
  const TaskCategory({
    required this.id,
    required this.name,
    required this.colorValue,
  });

  final String id;
  final String name;
  final int colorValue;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'colorValue': colorValue,
  };

  factory TaskCategory.fromJson(Map<String, dynamic> json) {
    return TaskCategory(
      id: json['id'] as String? ?? 'personal',
      name: json['name'] as String? ?? 'Личное',
      colorValue: json['colorValue'] as int? ?? 0xFF8B5CF6,
    );
  }
}
