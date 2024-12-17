import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;
  const ProfileScreen({required this.userId, Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;

  
  Future<void> _fetchUserData() async {
    final db = await DBHelper().database;
    final results = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [widget.userId],
    );
    if (results.isNotEmpty) {
      setState(() {
        userData = results.first;
      });
    }
  }


  Future<void> _updateFullName(String fullName) async {
    final db = await DBHelper().database;
    await db.update(
      'users',
      {'full_name': fullName},
      where: 'id = ?',
      whereArgs: [widget.userId],
    );
    setState(() {
      userData?['full_name'] = fullName; 
    });
  }

  
  Future<void> _showEditFullNameDialog(BuildContext context) async {
    TextEditingController fullNameController = TextEditingController(
      text: userData?['full_name'] ?? '',
    );
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Full Name'),
          content: TextField(
            controller: fullNameController,
            decoration: InputDecoration(
              hintText: 'Enter your full name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final fullName = fullNameController.text.trim();
                if (fullName.isNotEmpty) {
                  await _updateFullName(fullName);
                  Navigator.pop(context);
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    if (userData == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text('User ID: ${userData!['id']}'),
            SizedBox(height: 10),
            Text('Username: ${userData!['username']}'),
            SizedBox(height: 10),
            Text('Full Name: ${userData!['full_name'] ?? 'Not Set'}'),
            SizedBox(height: 10),
            Text('Password: ${userData!['password']}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
               
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (route) => false,
                );
              },
              child: Text('Logout'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _showEditFullNameDialog(context),
              child: Text('Edit Full Name'),
            ),
          ],
        ),
      ),
    );
  }
}
