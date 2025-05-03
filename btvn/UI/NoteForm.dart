import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../Model/Note.dart';
import '../Database Helper/NoteDatabaseHelper.dart';

class NoteForm extends StatefulWidget {
  final Note? note;

  NoteForm({this.note});

  @override
  _NoteFormState createState() => _NoteFormState();
}

class _NoteFormState extends State<NoteForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  int _priority = 1;
  List<String> _tags = [];
  String? _color;
  Color _currentColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _priority = widget.note?.priority ?? 1;
    _tags = widget.note?.tags ?? [];
    _color = widget.note?.color;
    if (_color != null) {
      _currentColor = Color(int.parse(_color!.substring(2), radix: 16));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _changeColor(Color color) {
    setState(() => _currentColor = color);
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Chọn màu'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _currentColor,
              onColorChanged: _changeColor,
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Chọn'),
              onPressed: () {
                setState(() => _color = '#${_currentColor.value.toRadixString(16).substring(2)}');
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _saveNote() async {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text;
      final content = _contentController.text;
      final now = DateTime.now();

      final note = Note(
        id: widget.note?.id,
        title: title,
        content: content,
        priority: _priority,
        createdAt: widget.note?.createdAt ?? now,
        modifiedAt: now,
        tags: _tags.isNotEmpty ? _tags : null,
        color: _color,
      );

      if (widget.note == null) {
        await NoteDatabaseHelper.instance.insertNote(note);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã thêm ghi chú')),
        );
      } else {
        await NoteDatabaseHelper.instance.updateNote(note);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã cập nhật ghi chú')),
        );
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Thêm ghi chú' : 'Sửa ghi chú'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Tiêu đề (bắt buộc)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tiêu đề';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                maxLines: 5,
                decoration: InputDecoration(labelText: 'Nội dung (bắt buộc)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập nội dung';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Text('Mức độ ưu tiên:', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Radio<int>(
                    value: 1,
                    groupValue: _priority,
                    onChanged: (value) {
                      setState(() {
                        _priority = value!;
                      });
                    },
                  ),
                  Text('Thấp'),
                  SizedBox(width: 16),
                  Radio<int>(
                    value: 2,
                    groupValue: _priority,
                    onChanged: (value) {
                      setState(() {
                        _priority = value!;
                      });
                    },
                  ),
                  Text('Trung bình'),
                  SizedBox(width: 16),
                  Radio<int>(
                    value: 3,
                    groupValue: _priority,
                    onChanged: (value) {
                      setState(() {
                        _priority = value!;
                      });
                    },
                  ),
                  Text('Cao'),
                ],
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _showColorPicker,
                child: Text('Chọn màu'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _currentColor,
                ),
              ),
              if (_color != null) Text('Màu đã chọn: $_color'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveNote,
                child: Text('Lưu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}