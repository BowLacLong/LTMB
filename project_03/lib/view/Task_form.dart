import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../db/Database_Helper.dart';
import '../models/Task.dart';
import '../models/User.dart';

class TaskForm extends StatefulWidget {
  final User currentUser;
  final Task? taskToEdit;

  const TaskForm({
    super.key,
    required this.currentUser,
    this.taskToEdit,
  });

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime _dueDate = DateTime.now();
  String _status = 'Chưa bắt đầu';
  String _priority = 'Thấp';
  String? _selectedUserId;

  final DatabaseHelper dbHelper = DatabaseHelper();
  List<User> _users = [];

  bool get isEdit => widget.taskToEdit != null;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    if (isEdit) {
      final task = widget.taskToEdit!;
      _titleController.text = task.title;
      _descController.text = task.description;
      _dueDate = task.dueDate!;
      _status = task.status;
      _priority = task.priority;
      _selectedUserId = task.assignedTo;
    }
  }

  Future<void> _loadUsers() async {
    final users = await dbHelper.getAllUsers();
    setState(() {
      _users = users.where((u) => u.role == 'user').toList();
    });
  }

  void _submit() async {
    if (_titleController.text.isEmpty ||
        _descController.text.isEmpty ||
        _selectedUserId == null) {
      _showMsg('Vui lòng nhập đầy đủ thông tin');
      return;
    }

    final task = Task(
      id: isEdit ? widget.taskToEdit!.id : const Uuid().v4(),
      title: _titleController.text,
      description: _descController.text,
      dueDate: _dueDate,
      status: _status,
      priority: _priority,
      assignedTo: _selectedUserId,
      createdAt: isEdit ? widget.taskToEdit!.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
      createdBy: widget.currentUser.id,
      category: null, // hoặc gán nếu có chọn loại
      attachments: [], // hoặc truyền danh sách file nếu có
      completed: _status == 'Hoàn thành',
    );


    if (isEdit) {
      await dbHelper.updateTask(task);
    } else {
      await dbHelper.insertTask(task);
    }

    Navigator.pop(context, true);
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = isEdit ? 'Sửa công việc' : 'Thêm công việc';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [

            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Tiêu đề',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            SizedBox(height: 20),
            TextField(
              controller: _descController,
              decoration: InputDecoration(
                labelText: 'Mô tả',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 5,
            ),

            SizedBox(height: 20),
            ListTile(
              title: const Text('Hạn hoàn thành'),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(_dueDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDueDate,
            ),

            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: InputDecoration(
                labelText: 'Trạng thái',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (val) => setState(() => _status = val!),
              items: const [
                DropdownMenuItem(value: 'Chưa bắt đầu', child: Text('Chưa bắt đầu')),
                DropdownMenuItem(value: 'Đang làm', child: Text('Đang làm')),
                DropdownMenuItem(value: 'Đã hoàn thành', child: Text('Đã hoàn thành')),
              ],
            ),

            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _priority,
              decoration: InputDecoration(
                labelText: 'Mức độ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (val) => setState(() => _priority = val!),
              items: const [
                DropdownMenuItem(value: 'Thấp', child: Text('Thấp')),
                DropdownMenuItem(value: 'Trung bình', child: Text('Trung bình')),
                DropdownMenuItem(value: 'Cao', child: Text('Cao')),
              ],
            ),

            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedUserId,
              decoration: InputDecoration(
                labelText: 'Giao cho người dùng',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (val) => setState(() => _selectedUserId = val!),
              items: _users
                  .map((user) => DropdownMenuItem(
                  value: user.id, child: Text(user.username)))
                  .toList(),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Lưu'),
            )
          ],
        ),
      ),
    );
  }
}
