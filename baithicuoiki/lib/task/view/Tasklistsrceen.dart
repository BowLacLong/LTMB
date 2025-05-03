import 'package:flutter/material.dart';
import '../model/users.dart';
import '../model/task.dart';
import '../db/databasehelper.dart';
import '../view/Task_item.dart';
import 'Login.dart';
import 'Task_form.dart';

class TaskListScreen extends StatefulWidget {
  final User user;
  const TaskListScreen({super.key, required this.user});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final db = DatabaseHelper.instance;
  List<Task> _tasks = [];

  String _searchText = '';
  String _filterStatus = 'Tất cả';

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await db.getTasks(
      userId: widget.user.id,
      isAdmin: widget.user.isAdmin,
    );

    setState(() {
      _tasks = tasks.where((task) {
        final matchesSearch = task.title.toLowerCase().contains(_searchText.toLowerCase());
        final matchesStatus = _filterStatus == 'Tất cả' || task.status == _filterStatus;
        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  void _goToForm({Task? task}) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaskFormScreen(user: widget.user, task: task),
      ),
    );
    if (updated == true) _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chào ${widget.user.username}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTasks,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Đăng xuất",
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: "Tìm kiếm công việc",
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (val) {
                  _searchText = val;
                  _loadTasks();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: DropdownButtonFormField(
                value: _filterStatus,
                items: ['Tất cả', 'Cần làm', 'Đang làm', 'Đã hoàn thành', 'Đã hủy']
                    .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                    .toList(),
                onChanged: (val) {
                  _filterStatus = val!;
                  _loadTasks();
                },
                decoration: const InputDecoration(labelText: "Lọc theo trạng thái"),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _tasks.isEmpty
                  ? const Center(child: Text("Không có công việc nào"))
                  : ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, i) => TaskItem(
                  task: _tasks[i],
                  onTap: () => _goToForm(task: _tasks[i]),
                  onDelete: () async {
                    await db.deleteTask(_tasks[i].id);
                    _loadTasks();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Đã xoá công việc")),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _goToForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
