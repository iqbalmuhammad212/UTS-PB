import 'package:flutter/material.dart';
import '../models/password.dart';
import '../database/db_helper.dart';
import '../helpers/aes_helper.dart'; 

class PasswordScreen extends StatefulWidget {
  final int userId;

  PasswordScreen({required this.userId});

  @override
  _PasswordScreenState createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  static const String _encryptionKey = "my_secret_key"; 
  List<Password> _passwords = [];

  @override
  void initState() {
    super.initState();
    _loadPasswords();
  }

  Future<void> _loadPasswords() async {
    final db = await DBHelper().database;
    final List<Map<String, dynamic>> results = await db.query(
      'passwords',
      where: 'userId = ?',
      whereArgs: [widget.userId],
    );

    setState(() {
      _passwords = results.map((map) {
        
        return Password(
          id: map['id'],
          userId: map['userId'],
          title: map['title'],
          username: map['username'],
          password: map['password'],
        );
      }).toList();
    });
  }

  Future<void> _addOrEditPassword({Password? password}) async {
    final titleController = TextEditingController(text: password?.title ?? '');
    final usernameController =
        TextEditingController(text: password?.username ?? '');
    final passwordController =
        TextEditingController(text: password?.password ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(password == null ? 'Add New Password' : 'Edit Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: false,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final db = await DBHelper().database;
              
              final encryptedPassword = EncryptionHelper.encryptText(
                passwordController.text,
                _encryptionKey,
              );

              if (password == null) {
                await db.insert('passwords', {
                  'userId': widget.userId,
                  'title': titleController.text,
                  'username': usernameController.text,
                  'password': encryptedPassword,
                });
              } else {
                await db.update(
                  'passwords',
                  {
                    'title': titleController.text,
                    'username': usernameController.text,
                    'password': encryptedPassword,
                  },
                  where: 'id = ? AND userId = ?',
                  whereArgs: [password.id, widget.userId],
                );
              }
              Navigator.pop(context);
              _loadPasswords();
            },
            child: Text(password == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePassword(Password password) async {
    final db = await DBHelper().database;
    await db.delete(
      'passwords',
      where: 'id = ? AND userId = ?',
      whereArgs: [password.id, widget.userId],
    );
    _loadPasswords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Passwords')),
      body: ListView.builder(
        itemCount: _passwords.length,
        itemBuilder: (context, index) {
          final password = _passwords[index];
          return ListTile(
            title: Text(password.title),
            subtitle: Text(
                'Username: ${password.username}\nPassword: ${password.password}'), 
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _addOrEditPassword(password: password),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deletePassword(password),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditPassword(),
        child: Icon(Icons.add),
      ),
    );
  }
}
