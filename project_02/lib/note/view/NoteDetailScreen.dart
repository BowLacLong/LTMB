import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../db/DatabaseHelper.dart';
import '../Model/Note.dart';
import 'NoteForm.dart';
import 'dart:io';

class NoteDetailScreen extends StatelessWidget {
  final Note note;

  const NoteDetailScreen({Key? key, required this.note}) : super(key: key);

  Color _getColorFromHex(String? hex) {
    if (hex == null) return Colors.white;
    hex = hex.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  String _priorityText(int p) {
    switch (p) {
      case 1:
        return 'Thấp';
      case 2:
        return 'Trung bình';
      case 3:
        return 'Cao';
      default:
        return 'Không xác định';
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(
        2, '0')}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(
        2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết ghi chú'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Chia sẻ ghi chú',
            onPressed: () {
              final shareText = '''
📌 ${note.title}
${note.content}

📅 Tạo lúc: ${_formatDate(note.createdAt)}
🕒 Cập nhật: ${_formatDate(note.modifiedAt)}
        ''';
              Share.share(shareText);
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => NoteForm(note: note)),
              );
              if (updated == true) {
                Navigator.pop(context, true);
              }
            },
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.flag, size: 18, color: Colors.grey),
                  const SizedBox(width: 5),
                  Text('Mức ưu tiên: ${_priorityText(note.priority)}',
                      style: const TextStyle(color: Colors.black)),
                ],
              ),

              const SizedBox(height: 8),
              Row(
                children: [
                  const SizedBox(width: 5),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () async {
                      Navigator.pop(context, true); // Trả về để cập nhật lại NoteList
                    },
                    icon: const Icon(Icons.sync),
                    label: const Text('Đổi trạng thái'),
                  )
                ],
              ),

              if (note.tags != null && note.tags!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: note.tags!
                      .map((tag) => Chip(label: Text(tag)))
                      .toList(),
                ),
              ],

              const SizedBox(height: 16),
              if (note.imagePath != null && note.imagePath!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(note.imagePath!),
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),

              const Divider(),
              Text(
                'Tạo lúc: ${_formatDate(note.createdAt)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                'Cập nhật: ${_formatDate(note.modifiedAt)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}