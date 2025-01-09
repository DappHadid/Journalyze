import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardUser extends StatefulWidget {
  @override
  _DashboardUserState createState() => _DashboardUserState();
}

class _DashboardUserState extends State<DashboardUser> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'User  Dashboard',
          style: GoogleFonts.openSans(
              fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Colors.grey[800]!],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('songs').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(color: Colors.green),
              );
            }

            final songs = snapshot.data!.docs;

            if (songs.isEmpty) {
              return Center(
                child: Text(
                  'No songs available.',
                  style: GoogleFonts.openSans(
                    fontSize: 18.0,
                    color: Colors.white,
                  ),
                ),
              );
            }

            return ListView.builder(
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final songData = songs[index].data() as Map<String, dynamic>;
                final title = songData['title'] ?? 'Unknown Title';
                final artist = songData['artist'] ?? 'Unknown Artist';
                final url = songData['url'] ?? '';

                return Card(
                  margin:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                  color: Colors.grey[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListTile(
                    leading: Icon(
                      FontAwesomeIcons.music,
                      color: Colors.green,
                    ),
                    title: Text(
                      title,
                      style: GoogleFonts.openSans(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      artist,
                      style: GoogleFonts.openSans(
                        fontSize: 14.0,
                        color: Colors.grey[400],
                      ),
                    ),
                    onTap: () async {
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Could not play the song'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
