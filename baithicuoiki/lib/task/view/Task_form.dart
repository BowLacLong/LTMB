import 'package:flutter/material.dart';
import '../model/users.dart';
import '../model/task.dart';
import '../db/databasehelper.dart';

class TaskFormScreen extends StatefulWidget {
  final User user;
  final Task? task;
  const TaskFormScreen({super.key, required this.user, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _status = 'Cần làm';
  User? _assignedUser;
  List<User> _userList = [];

  final db = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _initForm();
  }

  Future<void> _initForm() async {
    if (widget.user.isAdmin) {
      final allUsers = await db.getAllUsers();
      setState(() {
        _userList = allUsers.where((u) => !u.isAdmin).toList();
      });
    }

    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descController.text = widget.task!.description ?? '';
      _status = widget.task!.status;
      if (widget.user.isAdmin) {
        _assignedUser = _userList.firstWhere(
              (u) => u.id == widget.task!.userId,
          orElse: () => null,
        );
      }
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    final task = Task(
      id: widget.task?.id,
      title: _titleController.text,
      description: _descController.text,
      status: _status,
      userId: widget.user.isAdmin
          ? (_assignedUser?.id ?? widget.user.id)
          : widget.user.id,
    );

    if (widget.task == null) {
      await db.insertTask(task);
    } else {
      await db.updateTask(task);
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Thêm công việc' : 'Sửa công việc'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Tiêu đề'),
                validator: (value) =>
                value!.isEmpty ? 'Vui lòng nhập tiêu đề' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Mô tả'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _status,
                items: ['Cần làm', 'Đang làm', 'Đã hoàn thành', 'Đã hủy']
                    .map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(status),
                ))
                    .toList(),
                onChanged: (val) => setState(() => _status = val!),
                decoration: const InputDecoration(labelText: 'Trạng thái'),
              ),
              const SizedBox(height: 12),
              if (widget.user.isAdmin)
                DropdownButtonFormField<User>(
                  value: _assignedUser,
                  items: _userList
                      .map((u) => DropdownMenuItem(
                    value: u,
                    child: Text(u.username),
                  ))
                      .toList(),
                  onChanged: (val) => setState(() => _assignedUser = val),
                  decoration: const InputDecoration(
                      labelText: 'Giao cho người dùng'),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveTask,
                child: Text(widget.task == null ? 'Thêm' : 'Cập nhật'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
