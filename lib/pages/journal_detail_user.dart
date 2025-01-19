import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:journalyze/pages/bookmark.dart';

class JournalDetailUser extends StatelessWidget {
  final DocumentSnapshot snapshot;

  JournalDetailUser({required this.snapshot, required journalId});

  @override
  Widget build(BuildContext context) {
    final data = snapshot.data() as Map<String, dynamic>;
    final bookmarkRef =
        FirebaseFirestore.instance.collection('bookmarks').doc(snapshot.id);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Journal Detail',
              style: GoogleFonts.poppins(color: Colors.black),
            ),
            StreamBuilder<DocumentSnapshot>(
              stream: bookmarkRef.snapshots(),
              builder: (context, bookmarkSnapshot) {
                bool isBookmarked = bookmarkSnapshot.data?.exists ?? false;

                return IconButton(
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: Colors.black,
                  ),
                  onPressed: () async {
                    if (isBookmarked) {
                      await bookmarkRef.delete();
                    } else {
                      await bookmarkRef.set({
                        'title': data['title'],
                        'author': data['author'],
                        'journal_release': data['journal_release'],
                        'category': data['category'],
                        'abstract': data['abstract'],
                        'url': data['url'],
                      });
                    }
                  },
                );
              },
            ),
          ],
        ),
        backgroundColor: const Color(0xFFE8BF36),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                data['title'] ?? 'No Title',
                style: GoogleFonts.poppins(
                    fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Author: ${data['author'] ?? 'Unknown'}',
              style: GoogleFonts.poppins(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Category: ${data['category'] ?? 'Uncategorized'}',
              style: GoogleFonts.poppins(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Journal Release: ${data['journal_release'] ?? 'Unknown'}',
              style: GoogleFonts.poppins(fontSize: 18),
            ),
            SizedBox(height: 20),
            Divider(color: Colors.grey),
            SizedBox(height: 20),
            Text(
              'Abstract:',
              style: GoogleFonts.poppins(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              data['abstract'] ?? 'No Abstract Provided',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            SizedBox(height: 20),
            Divider(color: Colors.grey),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final url = data['url'];
                  if (url != null && await canLaunch(url)) {
                    await launch(url);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Could not launch $url')),
                    );
                  }
                },
                child: Text(
                  'Open URL',
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFE8BF36),
                  padding:
                      EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
