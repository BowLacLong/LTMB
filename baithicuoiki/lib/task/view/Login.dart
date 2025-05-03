import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../db/databasehelper.dart';
import '../model/users.dart';
import '../view/Tasklistsrceen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  String _username = '';
  String _password = '';
  String _email = '';
  bool _isAdmin = false;

  final db = DatabaseHelper.instance;

  void _toggleForm() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    _formKey.currentState?.save();

    if (_isLogin) {
      final user = await db.getUserByUsername(_username);
      if (user != null && user.password == _password) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => TaskListScreen(user: user)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sai tên đăng nhập hoặc mật khẩu")),
        );
      }
    } else {
      final newUser = User(
        id: const Uuid().v4(),
        username: _username,
        password: _password,
        email: _email,
        avatar: null,
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
        isAdmin: _isAdmin,
      );
      await db.insertUser(newUser);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tạo tài khoản thành công. Hãy đăng nhập!")),
      );
      setState(() {
        _isLogin = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? "Đăng nhập" : "Đăng ký")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: "Tên đăng nhập"),
                validator: (val) => val == null || val.isEmpty ? "Bắt buộc" : null,
                onSaved: (val) => _username = val!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Mật khẩu"),
                obscureText: true,
                validator: (val) => val == null || val.length < 4 ? "Tối thiểu 4 ký tự" : null,
                onSaved: (val) => _password = val!,
              ),
              if (!_isLogin)
                TextFormField(
                  decoration: const InputDecoration(labelText: "Email"),
                  validator: (val) => val == null || !val.contains('@') ? "Email không hợp lệ" : null,
                  onSaved: (val) => _email = val!,
                ),
              if (!_isLogin)
                CheckboxListTile(
                  value: _isAdmin,
                  onChanged: (val) => setState(() => _isAdmin = val!),
                  title: const Text("Là Admin"),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text(_isLogin ? "Đăng nhập" : "Đăng ký"),
              ),
              TextButton(
                onPressed: _toggleForm,
                child: Text(_isLogin ? "Chưa có tài khoản? Đăng ký" : "Đã có tài khoản? Đăng nhập"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
