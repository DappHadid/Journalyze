import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:journalyze/pages/upload.dart';
import 'package:shimmer/shimmer.dart';
import 'journal_detail.dart';


class DashboardAdmin extends StatefulWidget {
  @override
  _DashboardAdminState createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<DashboardAdmin> {
  static bool isLoggedIn = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String searchQuery = '';
  String sortOption = 'Title A-Z';
  bool isAscending = true;

  @override
  void initState() {
    super.initState();
    if (!isLoggedIn) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('welcome_screen');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Admin Dashboard',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _confirmLogout(context),
          ),
        ],
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
                      labelText: 'Search by Title',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                // Sorting Icons
                IconButton(
                  icon: Icon(
                    isAscending
                        ? FontAwesomeIcons.sortAlphaDown
                        : FontAwesomeIcons.sortAlphaUp,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      isAscending = !isAscending;
                      sortOption = 'Title';
                    });
                  },
                ),
                IconButton(
                  icon: Icon(
                    isAscending
                        ? FontAwesomeIcons.sortNumericDown
                        : FontAwesomeIcons.sortNumericUp,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      isAscending = !isAscending;
                      sortOption = 'Publication Date';
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('journals').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildShimmerLoading();
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading journals'));
                }
                final journals = snapshot.data?.docs ?? [];
                if (journals.isEmpty) {
                  return Center(child: Text('No journals available'));
                }

                final filteredJournals = journals.where((journal) {
                  final title =
                      (journal.data() as Map<String, dynamic>)['title'] ?? '';
                  return title
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase());
                }).toList();

                _sortJournals(filteredJournals);

                return ListView.builder(
                  itemCount: filteredJournals.length,
                  itemBuilder: (context, index) {
                    final journalData =
                        filteredJournals[index].data() as Map<String, dynamic>;
                    return _buildJournalItem(journalData,
                        filteredJournals[index].id, filteredJournals, index);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UploadJournalPage()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Container(
                height: 20,
                color: Colors.white,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 15,
                    color: Colors.white,
                  ),
                  SizedBox(height: 5),
                  Container(
                    height: 15,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _sortJournals(List<QueryDocumentSnapshot> filteredJournals) {
    if (sortOption == 'Title') {
      filteredJournals.sort((a, b) {
        final titleA = (a.data() as Map<String, dynamic>)['title'] ?? '';
        final titleB = (b.data() as Map<String, dynamic>)['title'] ?? '';
        return isAscending
            ? titleA.compareTo(titleB)
            : titleB.compareTo(titleA);
      });
    } else if (sortOption == 'Publication Date') {
      filteredJournals.sort((a, b) {
        final dateA = (a.data() as Map<String, dynamic>)['publication_date'];
        final dateB = (b.data() as Map<String, dynamic>)['publication_date'];
        return isAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
      });
    }
  }

  Widget _buildJournalItem(Map<String, dynamic> journalData, String journalId,
      List<QueryDocumentSnapshot> filteredJournals, int index) {
    return Card(
      margin: EdgeInsets.all(8.0),
      elevation: 4,
      child: ListTile(
        title: Text(
          journalData['title'] ?? 'No Title',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Author: ${journalData['author'] ?? 'Unknown'}',
                style: GoogleFonts.poppins()),
            Text('Category: ${journalData['category'] ?? 'Uncategorized'}',
                style: GoogleFonts.poppins()),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(FontAwesomeIcons.edit, color: Colors.blue),
              onPressed: () =>
                  _showEditJournalDialog(context, journalData, journalId),
            ),
            IconButton(
              icon: Icon(FontAwesomeIcons.trash, color: Colors.red),
              onPressed: () => _deleteJournal(journalId),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  JournalDetail(snapshot: filteredJournals[index]),
            ),
          );
        },
      ),
    );
  }

  void _showEditJournalDialog(BuildContext context,
      Map<String, dynamic> journalData, String journalId) {
    final titleController = TextEditingController(text: journalData['title']);
    final authorController = TextEditingController(text: journalData['author']);
    final categoryController =
        TextEditingController(text: journalData['category']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Journal', style: GoogleFonts.poppins()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: authorController,
                decoration: InputDecoration(labelText: 'Author'),
              ),
              TextField(
                controller: categoryController,
                decoration: InputDecoration(labelText: 'Category'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: GoogleFonts.poppins()),
            ),
            TextButton(
              onPressed: () {
                final title = titleController.text;
                final author = authorController.text;
                final category = categoryController.text;

                if (title.isNotEmpty && author.isNotEmpty) {
                  _firestore.collection('journals').doc(journalId).update({
                    'title': title,
                    'author': author,
                    'category': category,
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Update', style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }

  void _deleteJournal(String journalId) {
    _firestore.collection('journals').doc(journalId).delete().then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Journal deleted successfully!')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete journal: $error')),
      );
    });
  }

  void _confirmLogout(BuildContext context) async {
    ArtDialogResponse response = await ArtSweetAlert.show(
      context: context,
      artDialogArgs: ArtDialogArgs(
        title: "Logout",
        text: "Are you sure you want to logout?",
        confirmButtonText: "Yes",
        denyButtonText: "No",
        type: ArtSweetAlertType.warning,
      ),
    );

    if (response.isTapConfirmButton) {
      await _auth.signOut();
      setState(() {
        isLoggedIn = false;
      });
      Navigator.of(context).pushReplacementNamed('login_page');
    }
  }
}
