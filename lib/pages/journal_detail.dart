import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JournalDetail extends StatelessWidget {
  final DocumentSnapshot snapshot;

  JournalDetail({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final data = snapshot.data() as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          data['title'] ?? 'Journal Detail',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.black,
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
              'Publication Date: ${data['publication_date']?.toDate() ?? 'Unknown'}',
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
            Text(
              'Content:',
              style: GoogleFonts.poppins(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              data['content'] ?? 'No Content Available',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Back to Dashboard'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding:
                      EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
                  textStyle: GoogleFonts.poppins(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
