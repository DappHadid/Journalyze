import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


//ini dihapus aja gpp, diganti kodingan kamu, yg penting nama classnya tetep BookmarkPage
class BookmarkPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFE8BF36),
        title: Text(
          'Bookmarks',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: Text(
          'Your bookmarked journals',
          style: GoogleFonts.poppins(fontSize: 18),
        ),
      ),
    );
  }
}
