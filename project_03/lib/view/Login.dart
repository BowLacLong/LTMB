import 'package:flutter/material.dart';
import '../db/Database_Helper.dart';
import '../models/User.dart';
import '../view/Task_list.dart';
import '../view/Register.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final DatabaseHelper dbHelper = DatabaseHelper();

  void _login() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      _showMsg('Vui lòng nhập đầy đủ thông tin');
      return;
    }

    User? user = await dbHelper.getUserByUsername(username);
    if (user == null || user.password != password) {
      _showMsg('Sai tên đăng nhập hoặc mật khẩu');
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => TaskList(currentUser: user),
      ),
    );
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            SizedBox(height: 25),
            Text(
              "Đăng nhập",
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
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Mật khẩu',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Đăng nhập'),
            ),

            TextButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const Register()));
              },
              child: const Text('Chưa có tài khoản? Đăng ký'),

            )
          ],
        ),
      ),
    );
  }
}
