import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:journalyze/pages/bookmark.dart';
import 'package:journalyze/pages/dashboard_user.dart';
import 'package:journalyze/pages/journal_detail_user.dart';

class ListJournalPage extends StatefulWidget {
  final String category;

  ListJournalPage({required this.category});

  @override
  _ListJournalState createState() => _ListJournalState();
}

class _ListJournalState extends State<ListJournalPage> {
  String searchQuery = '';
  String sortBy = 'title_asc'; // Default sorting option

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFE8BF36), // Warna kuning
        elevation: 0,
        title: Center(
          child: Text(
            'Journal ${widget.category}',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search, color: Colors.black),
                      hintText: 'Search',
                      hintStyle: GoogleFonts.poppins(color: Colors.black),
                      filled: true,
                      fillColor: Colors.yellow[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: Icon(Icons.sort, color: Colors.black),
                  onSelected: (value) {
                    setState(() {
                      sortBy = value;
                    });
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'title_asc',
                      child: Text('Title (A-Z)'),
                    ),
                    PopupMenuItem(
                      value: 'title_desc',
                      child: Text('Title (Z-A)'),
                    ),
                    PopupMenuItem(
                      value: 'date_oldest',
                      child: Text('Publication Date (Oldest)'),
                    ),
                    PopupMenuItem(
                      value: 'date_newest',
                      child: Text('Publication Date (Newest)'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('journals')
                  .where('category', isEqualTo: widget.category)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No journals found.',
                      style: GoogleFonts.poppins(fontSize: 16),
                    ),
                  );
                }

                List<QueryDocumentSnapshot> filteredJournals =
                    snapshot.data!.docs.where((doc) {
                  final title = doc['title'].toString().toLowerCase();
                  final author = doc['author'].toString().toLowerCase();
                  return title.contains(searchQuery.toLowerCase()) ||
                      author.contains(searchQuery.toLowerCase());
                }).toList();

                // Sorting logic based on selected option
                filteredJournals.sort((a, b) {
                  String titleA = a['title'] ?? '';
                  String titleB = b['title'] ?? '';
                  int dateA = int.tryParse(a['journal_release'] ?? '0') ?? 0;
                  int dateB = int.tryParse(b['journal_release'] ?? '0') ?? 0;

                  switch (sortBy) {
                    case 'title_asc':
                      return titleA.compareTo(titleB);
                    case 'title_desc':
                      return titleB.compareTo(titleA);
                    case 'date_oldest':
                      return dateA.compareTo(dateB);
                    case 'date_newest':
                      return dateB.compareTo(dateA);
                    default:
                      return 0;
                  }
                });

                return ListView.builder(
                  itemCount: filteredJournals.length,
                  itemBuilder: (context, index) {
                    final journal = filteredJournals[index];

                    return StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('bookmarks')
                          .doc(journal.id)
                          .snapshots(),
                      builder: (context, bookmarkSnapshot) {
                        bool isBookmarked =
                            bookmarkSnapshot.data?.exists ?? false;

                        return Card(
                          margin:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          color: Colors.yellow[200],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            title: Text(
                              journal['title'] ?? 'No Title',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Author: ${journal['author'] ?? 'Unknown'}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  'Publication Date: ${journal['journal_release'] ?? 'Unknown'}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                isBookmarked
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                color:
                                    isBookmarked ? Colors.black : Colors.black,
                              ),
                              onPressed: () async {
                                final bookmarkRef = FirebaseFirestore.instance
                                    .collection('bookmarks')
                                    .doc(journal.id);

                                if (isBookmarked) {
                                  // Hapus dari bookmark jika sudah di-bookmark
                                  await bookmarkRef.delete();
                                } else {
                                  // Tambahkan ke bookmark jika belum di-bookmark
                                  await bookmarkRef.set({
                                    'title': journal['title'],
                                    'author': journal['author'],
                                    'journal_release':
                                        journal['journal_release'],
                                    'category': widget
                                        .category, // Tambahkan kategori jurnal
                                  });
                                }
                              },
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => JournalDetailUser(
                                      snapshot: filteredJournals[index]),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
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
}
