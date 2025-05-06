import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../db/Database_Helper.dart';
import '../models/User.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final DatabaseHelper dbHelper = DatabaseHelper();

  String _role = 'user'; // Mặc định user thường

  void _register() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text;
    String email = _emailController.text.trim();

    if (username.isEmpty || password.isEmpty || email.isEmpty) {
      _showMsg('Vui lòng nhập đầy đủ thông tin');
      return;
    }

    User? existed = await dbHelper.getUserByUsername(username);
    if (existed != null) {
      _showMsg('Tên đăng nhập đã tồn tại');
      return;
    }

    final user = User(
      id: const Uuid().v4(),
      username: username,
      password: password,
      email: email,
      createdAt: DateTime.now(),
      lastActive: DateTime.now(),
      role: _role,
    );

    await dbHelper.insertUser(user);
    _showMsg('Đăng ký thành công, quay lại đăng nhập');
    Navigator.pop(context);
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            Text(
              "Đăng ký",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Tên đăng nhập',
                prefixIcon: Icon(Icons.account_circle),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Mật khẩu',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              obscureText: true,
            ),

            SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            DropdownButton<String>(
              value: _role,
              onChanged: (value) {
                setState(() {
                  _role = value!;
                });
              },
              items: const [
                DropdownMenuItem(value: 'user', child: Text('User')),
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
              ],
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: const Text('Đăng ký'),
            ),
          ],
        ),
      ),
    );
  }
}
