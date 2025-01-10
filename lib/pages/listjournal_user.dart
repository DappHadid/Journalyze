import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:journalyze/pages/bookmark.dart';
import 'package:journalyze/pages/dashboard_user.dart';
import 'package:journalyze/pages/journal_detail.dart';

class ListJournalPage extends StatefulWidget {
  final String category;

  ListJournalPage({required this.category});

  @override
  _ListJournalState createState() => _ListJournalState();
}

class _ListJournalState extends State<ListJournalPage> {
  String searchQuery = '';
  bool ascending = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Center(
          child: Text(
            'JURNAL ${widget.category}',
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
                      hintStyle: GoogleFonts.poppins(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.yellow[600],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    ascending ? Icons.arrow_upward : Icons.arrow_downward,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      ascending = !ascending;
                    });
                  },
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

                List<QueryDocumentSnapshot> filteredJournals = snapshot.data!.docs.where((doc) {
                  final title = doc['title'].toString().toLowerCase();
                  final author = doc['author'].toString().toLowerCase();
                  return title.contains(searchQuery.toLowerCase()) ||
                      author.contains(searchQuery.toLowerCase());
                }).toList();

                filteredJournals.sort((a, b) {
                  int yearA = int.tryParse(a['journal_release'] ?? '0') ?? 0;
                  int yearB = int.tryParse(b['journal_release'] ?? '0') ?? 0;
                  return ascending ? yearA.compareTo(yearB) : yearB.compareTo(yearA);
                });

                return ListView.builder(
                  itemCount: filteredJournals.length,
                  itemBuilder: (context, index) {
                    final journal = filteredJournals[index];

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: Colors.yellow[600],
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
                              'Tahun Terbit: ${journal['journal_release'] ?? 'Unknown'}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.bookmark_border, color: Colors.black),
                          onPressed: () {
                          },
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => JournalDetail(snapshot: filteredJournals[index]),
                            ),
                          );
                        },
                      ),
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
