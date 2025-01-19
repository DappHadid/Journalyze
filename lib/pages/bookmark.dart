import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:journalyze/pages/journal_detail_user.dart';
import 'package:journalyze/pages/dashboard_user.dart';

class BookmarkPage extends StatefulWidget {
  @override
  _BookmarkPageState createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  String searchQuery = '';
  String sortOption = 'title_asc'; // Default sort by title (A-Z)

  List<QueryDocumentSnapshot> _bookmarkedJournals = [];

  // Fetch bookmarked journals from Firestore
  void fetchBookmarkedJournals() async {
    FirebaseFirestore.instance
        .collection('bookmarks')
        .get()
        .then((querySnapshot) {
      setState(() {
        _bookmarkedJournals = querySnapshot.docs;
      });
    });
  }

  // Remove bookmark from Firestore
  void removeBookmark(String journalId) async {
    await FirebaseFirestore.instance
        .collection('bookmarks')
        .doc(journalId)
        .delete();
    fetchBookmarkedJournals(); // Refresh the list after removing the bookmark
  }

  @override
  void initState() {
    super.initState();
    fetchBookmarkedJournals();
  }

  // Filter and sort journals based on search query and selected sort option
  List<QueryDocumentSnapshot> get filteredJournals {
    List<QueryDocumentSnapshot> filtered = _bookmarkedJournals.where((journal) {
      final title = journal['title'].toString().toLowerCase();
      final author = journal['author'].toString().toLowerCase();
      final query = searchQuery.toLowerCase();

      return (title.contains(query) || author.contains(query));
    }).toList();

    // Sorting logic
    filtered.sort((a, b) {
      final titleA = a['title']?.toLowerCase() ?? '';
      final titleB = b['title']?.toLowerCase() ?? '';
      final yearA = int.tryParse(a['journal_release'] ?? '0') ?? 0;
      final yearB = int.tryParse(b['journal_release'] ?? '0') ?? 0;

      switch (sortOption) {
        case 'title_asc':
          return titleA.compareTo(titleB);
        case 'title_desc':
          return titleB.compareTo(titleA);
        case 'date_oldest':
          return yearA.compareTo(yearB);
        case 'date_newest':
          return yearB.compareTo(yearA);
        default:
          return 0;
      }
    });

    return filtered;
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
                  onSelected: (value) {
                    setState(() {
                      sortOption = value;
                    });
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'title_asc',
                      child: Text('Sort by Title (A-Z)'),
                    ),
                    PopupMenuItem(
                      value: 'title_desc',
                      child: Text('Sort by Title (Z-A)'),
                    ),
                    PopupMenuItem(
                      value: 'date_oldest',
                      child: Text('Sort by Publication Date (Oldest)'),
                    ),
                    PopupMenuItem(
                      value: 'date_newest',
                      child: Text('Sort by Publication Date (Newest)'),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            // List of bookmarked journals
            Expanded(
              child: _bookmarkedJournals.isEmpty
                  ? Center(child: Text('No bookmarks found.'))
                  : ListView.builder(
                      itemCount: filteredJournals.length,
                      itemBuilder: (context, index) {
                        final journal = filteredJournals[index];
                        return Card(
                          color: Colors.yellow[200],
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text(
                              journal['title'] ?? 'No Title',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            subtitle: Text(
                              'Author: ${journal['author']}\nPublication Date: ${journal['journal_release']}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.bookmark,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                // Remove bookmark from Firestore
                                removeBookmark(journal.id);
                              },
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      JournalDetailUser(snapshot: journal, journalId: null,),
                                ),
                              );
                            },
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
                icon: Icon(Icons.home_outlined),
                iconSize: 30,
                color: Colors.black,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DashboardUser(),
                    ),
                  );
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
