import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget
{
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black12,
        leading: Icon(Icons.person),
        title: Text('Profile',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20
          )
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // Gambar Profil dari URL
          CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/img/profile_img.jpeg'),
          ),
          const SizedBox(height: 10),
          // Nama Profil
          Text(
            'Profile Name',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          // Nomor Telepon
          Text(
            '+62 895-4223-3667',
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
          const SizedBox(height: 20),
          // List Menu
          Expanded(
            child: ListView(
              children: const [
                ListTile(
                  leading: Icon(Icons.security),
                  title: Text('Account and Security'),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
                ListTile(
                  leading: Icon(Icons.history),
                  title: Text('History'),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
                ListTile(
                  leading: Icon(Icons.favorite),
                  title: Text('Favorite'),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
                ListTile(
                  leading: Icon(Icons.language),
                  title: Text('Language'),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
                ListTile(
                  leading: Icon(Icons.privacy_tip),
                  title: Text('Privacy'),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
                ListTile(
                  leading: Icon(Icons.info),
                  title: Text('About'),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
                ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}