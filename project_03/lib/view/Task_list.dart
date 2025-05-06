import 'package:flutter/material.dart';
import '../db/Database_Helper.dart';
import '../models/Task.dart';
import '../models/User.dart';
import '../view/login.dart';
import '../view/Task_detail.dart';
import '../View/Task_form.dart';

class TaskList extends StatefulWidget {
  final User currentUser;
  const TaskList({super.key, required this.currentUser});

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<Task> _tasks = [];
  String _searchQuery = '';
  String _selectedStatus = 'Tất cả';
  String _selectedPriority = 'Tất cả';

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    List<Task> tasks;
    if (widget.currentUser.role == 'admin') {
      tasks = await dbHelper.getAllTasks();
    } else {
      tasks = await dbHelper.getTasksByUser(widget.currentUser.id);
    }

    // Lọc theo trạng thái
    if (_selectedStatus != 'Tất cả') {
      tasks = tasks.where((t) => t.status == _selectedStatus).toList();
    }

    // Lọc theo mức độ ưu tiên
    if (_selectedPriority != 'Tất cả') {
      tasks = tasks.where((t) => t.priority == _selectedPriority).toList();
    }

    // Lọc theo từ khóa tìm kiếm
    if (_searchQuery.isNotEmpty) {
      tasks = tasks
          .where((t) => t.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    setState(() {
      _tasks = tasks;
    });
  }

  void _deleteTask(String id) async {
    await dbHelper.deleteTask(id);
    _loadTasks();
  }

  void _searchTasks(String query) {
    setState(() {
      _searchQuery = query;
    });
    _loadTasks();
  }

  void _goToAddTask() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaskForm(currentUser: widget.currentUser),
      ),
    );
    if (result == true) _loadTasks();
  }

  void _goToEditTask(Task task) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaskForm(
          currentUser: widget.currentUser,
          taskToEdit: task,
        ),
      ),
    );
    if (result == true) _loadTasks();
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const Login()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.currentUser.role == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: Text(' ${widget.currentUser.username}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: _logout,
          )
        ],
      ),
      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Tìm kiếm theo tiêu đề...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _searchTasks,
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [

                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedStatus,
                    isExpanded: true,
                    items: ['Tất cả', 'Chưa bắt đầu', 'Đang tiến hành', 'Hoàn thành']
                        .map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value!;
                      });
                      _loadTasks();
                    },
                  ),
                ),

                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedPriority,
                    isExpanded: true,
                    items: ['Tất cả', 'Thấp', 'Trung bình', 'Cao']
                        .map((priority) => DropdownMenuItem(
                      value: priority,
                      child: Text(priority),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPriority = value!;
                      });
                      _loadTasks();
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          Expanded(
            child: _tasks.isEmpty
                ? const Center(child: Text('Không có công việc nào'))
                : ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (_, index) {
                final task = _tasks[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(task.title),
                    subtitle: Text('Trạng thái: ${task.status}'),
                      trailing: isAdmin
                          ? PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _goToEditTask(task);
                          } else if (value == 'delete') {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Xác nhận xoá'),
                                content: const Text('Bạn có chắc chắn muốn xoá công việc này không?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Hủy'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _deleteTask(task.id);
                                    },
                                    child: const Text('Xoá', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                          }
                        },

                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: ListTile(
                              title: Text('Sửa'),
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: ListTile(
                              title: Text('Xoá'),
                            ),
                          ),
                        ],
                      )
                          : null,

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TaskDetail(task: task),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          )
        ],
      ),

      floatingActionButton: isAdmin
          ? FloatingActionButton(
        onPressed: _goToAddTask,
        child: const Icon(Icons.add),
      )
          : null,
    );
  }
}
