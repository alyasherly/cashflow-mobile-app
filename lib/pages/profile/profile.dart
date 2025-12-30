import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            CircleAvatar(radius: 40),
            SizedBox(height: 16),
            Text('Username'),
            Text('Nama Lengkap'),
            Text('email@example.com'),
          ],
        ),
      ),
    );
  }
}
