import 'package:flutter/material.dart';
import '../Model/Note.dart';
import 'NoteForm.dart';
import 'package:intl/intl.dart';

class NoteDetailScreen extends StatelessWidget {
  final Note note;

  NoteDetailScreen({required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết ghi chú'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NoteForm(note: note)),
              ).then((_) => Navigator.pop(context)); // Reload list after edit
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              note.content,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text('Ưu tiên: '),
                Text(
                  _getPriorityText(note.priority),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text('Ngày tạo: ${DateFormat('dd/MM/yyyy HH:mm').format(note.createdAt)}'),
            Text('Ngày sửa: ${DateFormat('dd/MM/yyyy HH:mm').format(note.modifiedAt)}'),
            SizedBox(height: 8),
            if (note.tags != null && note.tags!.isNotEmpty)
              Text('Nhãn: ${note.tags!.join(', ')}'),
            if (note.color != null) ...[
              SizedBox(height: 8),
              Text('Màu: ${note.color}'),
              Container(
                width: 30,
                height: 30,
                color: Color(int.parse(note.color!.substring(2), radix: 16)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getPriorityText(int priority) {
    switch (priority) {
      case 1:
        return 'Thấp';
      case 2:
        return 'Trung bình';
      case 3:
        return 'Cao';
      default:
        return '';
    }
  }
}