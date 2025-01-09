import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BookmarkPage extends StatefulWidget {
  @override
  _BookmarkPageState createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  // Dummy list of bookmarked journals
  List<Map<String, dynamic>> journals = [
    {
      'title': 'Judul Jurnal 1',
      'author': 'Nama Author 1',
      'year': '2021',
      'isBookmarked': true
    },
    {
      'title': 'Judul Jurnal 2',
      'author': 'Nama Author 2',
      'year': '2022',
      'isBookmarked': true
    },
    {
      'title': 'Judul Jurnal 3',
      'author': 'Nama Author 3',
      'year': '2020',
      'isBookmarked': true
    },
  ];

  String searchQuery = '';
  String sortOption = 'title'; // Default sort by title

  // Toggle bookmark state
  void toggleBookmark(int index) {
    setState(() {
      journals[index]['isBookmarked'] = !journals[index]['isBookmarked'];
    });
  }

  // Sort journals
  void sortJournals(String option) {
    setState(() {
      sortOption = option;
      if (option == 'title') {
        journals.sort((a, b) => a['title'].compareTo(b['title']));
      } else if (option == 'year') {
        journals.sort((a, b) => a['year'].compareTo(b['year']));
      }
    });
  }

  // Filter journals based on search query
  List<Map<String, dynamic>> get filteredJournals {
    return journals.where((journal) {
      final title = journal['title'].toLowerCase();
      final author = journal['author'].toLowerCase();
      final query = searchQuery.toLowerCase();

      return (title.contains(query) || author.contains(query)) &&
          journal['isBookmarked'];
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFFE8BF36),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Bookmarks',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search bar and sort button
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: Icon(Icons.search, color: Colors.black),
                      filled: true,
                      fillColor: Colors.yellow[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                PopupMenuButton<String>(
                  icon: Icon(Icons.filter_list, color: Colors.black),
                  onSelected: sortJournals,
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'title',
                      child: Text('Sort by Title'),
                    ),
                    PopupMenuItem(
                      value: 'year',
                      child: Text('Sort by Year'),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            // List of bookmarked journals
            Expanded(
              child: ListView.builder(
                itemCount: filteredJournals.length,
                itemBuilder: (context, index) {
                  final journal = filteredJournals[index];
                  return Card(
                    color: Colors.yellow[200],
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(
                        journal['title'],
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      subtitle: Text(
                        'Author: ${journal['author']}\nTahun Terbit: ${journal['year']}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          journal['isBookmarked']
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          color: journal['isBookmarked']
                              ? Colors.black
                              : Colors.grey,
                        ),
                        onPressed: () => toggleBookmark(index),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.yellow[700],
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
                  // Navigate to home
                  Navigator.pop(context);
                },
              ),
              IconButton(
                icon: Icon(Icons.bookmark),
                iconSize: 30,
                color: Colors.black,
                onPressed: () {
                  // Already on bookmark page
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
