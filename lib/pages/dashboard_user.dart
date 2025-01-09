import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:journalyze/pages/listjournal_user.dart';
import 'package:journalyze/pages/bookmark.dart';

import 'package:journalyze/pages/welcome_page.dart';
import 'package:art_sweetalert/art_sweetalert.dart';

class DashboardUser extends StatelessWidget {
  final List<Map<String, dynamic>> categories = [
    {'title': 'Education', 'icon': Icons.school},
    {'title': 'Engineering', 'icon': Icons.engineering},
    {'title': 'Social', 'icon': Icons.group},
    {'title': 'Health', 'icon': Icons.health_and_safety},
    {'title': 'Technology', 'icon': Icons.computer},
    {'title': 'Science', 'icon': Icons.science},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE8BF36),
      body: SafeArea(
        child: Column(
          children: [
            // Header dengan sapaan dan gambar profil
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage('assets/img/profile.jpg'),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Hi, Jeykeyy',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.all(16.0),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return _buildCategoryCard(context, category);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color(0xFFE8BF36),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.home),
                iconSize: 30,
                color: Colors.black,
                onPressed: () {
                  // Aksi tombol Home
                },
              ),
              IconButton(
                icon: Icon(Icons.bookmark),
                iconSize: 30,
                color: Colors.black,
                onPressed: () {
                  // Navigasi ke halaman bookmark
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookmarkPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
      BuildContext context, Map<String, dynamic> category) {
    return GestureDetector(
      onTap: () {
        print('Selected: ${category['title']}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              category['icon'],
              size: 40,
              color: Colors.black87,
            ),
            SizedBox(height: 10),
            Text(
              category['title']!,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header dengan ikon kembali dan nama profil di tengah
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context); // Kembali ke halaman sebelumnya
                    },
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Profile',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE8BF36),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                      width: 48), // Placeholder untuk menggantikan tombol back
                ],
              ),
            ),
            SizedBox(height: 10),
            // Foto Profil
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage('assets/img/profile.jpg'),
              ),
            ),
            SizedBox(height: 20),
            // List Informasi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  _buildProfileItem(Icons.person, 'Name', 'Jeykeyy'),
                  _buildProfileItem(Icons.email, 'Email', 'jeykey@gmail.com'),
                  _buildProfileItem(Icons.phone, 'Contact', '+62 123 4567 890'),
                ],
              ),
            ),
            Spacer(),
            // Tombol Logout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ElevatedButton(
                onPressed: () {
                  // Menutup semua halaman dan kembali ke login
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => WelcomeScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFE8BF36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child: Center(
                  child: Text(
                    'Logout',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, size: 30, color: Color(0xFFE8BF36)),
          SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          'Login Page',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LoginPage(), // Awali dengan halaman login
  ));
}
