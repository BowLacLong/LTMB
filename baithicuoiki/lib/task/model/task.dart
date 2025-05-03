class Task {
  final String id;
  final String title;
  final String description;
  final String status; // To do, In progress, Done, Cancelled
  final int priority; // 1: Low, 2: Medium, 3: High
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String? assignedTo;
  final String? category;
  final List<String>? attachments;
  final bool completed;
  final int userId;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.assignedTo,
    this.category,
    this.attachments,
    required this.completed,
    required this.userId,
  });

  factory Task.fromMap(Map<String, dynamic> map) => Task(
    id: map['id'],
    title: map['title'],
    description: map['description'],
    status: map['status'],
    priority: map['priority'],
    dueDate:
    map['dueDate'] != null ? DateTime.tryParse(map['dueDate']) : null,
    createdAt: DateTime.parse(map['createdAt']),
    updatedAt: DateTime.parse(map['updatedAt']),
    createdBy: map['createdBy'],
    assignedTo: map['assignedTo'],
    category: map['category'],
    attachments: map['attachments'] != null
        ? map['attachments'].split(',')
        : null,
    completed: map['completed'] == 1,
    userId: map['userId'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'status': status,
    'priority': priority,
    'dueDate': dueDate?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'createdBy': createdBy,
    'assignedTo': assignedTo,
    'category': category,
    'attachments': attachments?.join(','),
    'completed': completed ? 1 : 0,
    'userId': userId,
  };
}