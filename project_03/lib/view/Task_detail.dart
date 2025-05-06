import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/Task.dart';

class TaskDetail extends StatelessWidget {
  final Task task;
  const TaskDetail({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết công việc')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('Tiêu đề:', style: labelStyle),
            Text(task.title, style: valueStyle),
            const SizedBox(height: 20),
            Text('Mô tả:', style: labelStyle),
            Text(task.description, style: valueStyle),
            const SizedBox(height: 10),
            Text('Hạn hoàn thành:', style: labelStyle),
            Text(DateFormat('dd/MM/yyyy').format(task.dueDate!), style: valueStyle),
            const SizedBox(height: 10),
            Text('Trạng thái:', style: labelStyle),
            Text(task.status, style: valueStyle),
            const SizedBox(height: 10),
            Text('Ưu tiên:', style: labelStyle),
            Text(task.priority, style: valueStyle),
          ],
        ),
      ),
    );
  }

  TextStyle get labelStyle => const TextStyle(fontWeight: FontWeight.bold);
  TextStyle get valueStyle => const TextStyle(fontSize: 16);
}
