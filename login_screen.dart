import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../helpers/aes_helper.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _register() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Username and Password cannot be empty!')),
      );
      return;
    }
    final db = await DBHelper().database;

    
    final encryptionKey = _usernameController.text; 
    final encryptedPassword =
        EncryptionHelper.encryptText(_passwordController.text, encryptionKey);

    try {
      await db.insert('users', {
        'username': _usernameController.text,
        'password': encryptedPassword,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User registered successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: Username might already exist!')),
      );
    }
  }

  Future<void> _login() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }
    final db = await DBHelper().database;

   
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [_usernameController.text],
    );

    if (result.isNotEmpty) {
      final storedEncryptedPassword = result.first['password'] as String;

      try {
       
        final encryptionKey = _usernameController.text;
        final decryptedPassword = EncryptionHelper.decryptText(
          storedEncryptedPassword,
          encryptionKey,
        );

        if (decryptedPassword == _passwordController.text) {
          final userId = result.first['id'] as int;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(userId: userId),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid username or password')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error decrypting password')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid username or password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login/Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: Text('Login')),
            TextButton(
              onPressed: _register,
              child: Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}
