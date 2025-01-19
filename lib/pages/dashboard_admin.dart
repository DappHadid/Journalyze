import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:shimmer/shimmer.dart';
import 'upload.dart';
import 'journal_detail.dart';
import 'package:flutter/services.dart';

class DashboardAdmin extends StatefulWidget {
  @override
  _DashboardAdminState createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<DashboardAdmin> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = '';
  String sortOption = 'Title A-Z';
  bool isAscending = true;
  User? currentUser;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    currentUser = _auth.currentUser;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => UploadJournalPage(collection: 'journals')),
      );
    }
  }

  void _selectSortOption(String option) {
    setState(() {
      sortOption = option;
      isAscending = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Color.fromARGB(225, 232, 191, 54),
            title: Text(
              'Welcome, Admin!',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.logout, color: Colors.white),
                onPressed: () => _confirmLogout(context),
              ),
            ],
            centerTitle: true,
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
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey[200],
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.search,
                          color: Color.fromARGB(255, 230, 214, 124),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                PopupMenuButton<String>(
                  icon: Icon(Icons.sort,
                      color: Color.fromARGB(255, 230, 214, 124)),
                  onSelected: _selectSortOption,
                  itemBuilder: (BuildContext context) {
                    return <String>[
                      'Title A-Z',
                      'Title Z-A',
                      'Publication Date (Oldest)',
                      'Publication Date (Newest)',
                    ].map<PopupMenuItem<String>>((String value) {
                      return PopupMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList();
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
                      .contains(_searchQuery.toLowerCase());
                }).toList();

                _sortJournals(filteredJournals);

                if (filteredJournals.isEmpty) {
                  return Center(child: Text('Journal not found'));
                }

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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(225, 232, 191, 54),
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[600],
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add',
          ),
        ],
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
    if (sortOption == 'Title A-Z') {
      filteredJournals.sort((a, b) {
        final titleA = (a.data() as Map<String, dynamic>)['title'] ?? '';
        final titleB = (b.data() as Map<String, dynamic>)['title'] ?? '';
        return isAscending
            ? titleA.compareTo(titleB)
            : titleB.compareTo(titleA);
      });
    } else if (sortOption == 'Title Z-A') {
      filteredJournals.sort((a, b) {
        final titleA = (a.data() as Map<String, dynamic>)['title'] ?? '';
        final titleB = (b.data() as Map<String, dynamic>)['title'] ?? '';
        return isAscending
            ? titleB.compareTo(titleA)
            : titleA.compareTo(titleB);
      });
    } else if (sortOption == 'Release Oldest') {
      filteredJournals.sort((a, b) {
        final dateA = (a.data() as Map<String, dynamic>)['journal_release'];
        final dateB = (b.data() as Map<String, dynamic>)['journal_release'];
        return isAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
      });
    } else if (sortOption == 'Release Latest') {
      filteredJournals.sort((a, b) {
        final dateA = (a.data() as Map<String, dynamic>)['journal_release'];
        final dateB = (b.data() as Map<String, dynamic>)['journal_release'];
        return isAscending ? dateB.compareTo(dateA) : dateA.compareTo(dateB);
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
            Text('Category: ${journalData['category'] ?? 'Uncategorized'}',
                style: GoogleFonts.poppins()),
            Text('Release Year: ${journalData['journal_release'] ?? 'Unknown'}',
                style: GoogleFonts.poppins()),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () =>
                  _showEditJournalDialog(context, journalData, journalId),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(context, journalId),
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
    final abstractController =
        TextEditingController(text: journalData['abstract']);
    final urlController = TextEditingController(text: journalData['url']);
    final journalReleaseController =
        TextEditingController(text: journalData['journal_release']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Journal', style: GoogleFonts.poppins()),
          content: SingleChildScrollView(
            // Tambahkan scroll view
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                  maxLines: 2, // Memperbesar TextField untuk title
                ),
                TextField(
                  controller: authorController,
                  decoration: InputDecoration(labelText: 'Author'),
                ),
                TextField(
                  controller: categoryController,
                  decoration: InputDecoration(labelText: 'Category'),
                ),
                TextField(
                  controller: abstractController,
                  decoration: InputDecoration(labelText: 'Abstract'),
                  maxLines: 4, // Memperbesar TextField untuk abstract
                ),
                TextField(
                  controller: journalReleaseController,
                  decoration: InputDecoration(labelText: 'Journal Release'),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter
                        .digitsOnly, // Hanya izinkan angka
                  ],
                ),
                TextField(
                  controller: urlController,
                  decoration: InputDecoration(labelText: 'URL'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: GoogleFonts.poppins()),
            ),
            TextButton(
              onPressed: () => _confirmUpdate(
                titleController.text,
                authorController.text,
                categoryController.text,
                abstractController.text,
                journalReleaseController.text,
                urlController.text,
                journalId,
                context,
              ),
              child: Text('Update', style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }

  void _confirmUpdate(
    String title,
    String author,
    String category,
    String abstract,
    String journalRelease,
    String url,
    String journalId,
    BuildContext context,
  ) {
    if (title.isNotEmpty && author.isNotEmpty) {
      _firestore.collection('journals').doc(journalId).update({
        'title': title,
        'author': author,
        'category': category,
        'abstract': abstract,
        'journal_release': journalRelease,
        'url': url,
      }).then((_) {
        // Tutup dialog edit
        Navigator.of(context).pop(); // Tutup dialog edit

        // Tampilkan alert setelah dialog ditutup
        ArtSweetAlert.show(
          context: context,
          artDialogArgs: ArtDialogArgs(
            title: "Success",
            text: "Journal updated successfully!",
            type: ArtSweetAlertType.success,
          ),
        );

        // Kembali ke halaman DashboardAdmin setelah alert ditutup
        Future.delayed(Duration(seconds: 2), () {
          Navigator.of(context).pop(); // Kembali ke halaman sebelumnya
        });
      }).catchError((error) {
        // Tampilkan alert jika terjadi kesalahan
        ArtSweetAlert.show(
          context: context,
          artDialogArgs: ArtDialogArgs(
            title: "Error",
            text: "Failed to update journal: $error",
            type: ArtSweetAlertType.danger,
          ),
        );
      });
    }
  }

  void _confirmDelete(BuildContext context, String journalId) {
    ArtSweetAlert.show(
      context: context,
      artDialogArgs: ArtDialogArgs(
        title: "Delete Journal",
        text: "Are you sure you want to delete this journal?",
        type: ArtSweetAlertType.warning,
        confirmButtonText: "Yes",
        denyButtonText: "No",
      ),
    ).then((response) {
      if (response.isTapConfirmButton) {
        _deleteJournal(journalId);
      }
    });
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
      Navigator.of(context).pushReplacementNamed('welcome_screen');
    }
  }
}
