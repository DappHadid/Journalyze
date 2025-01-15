import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:excel/excel.dart'; // Import the excel package
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dashboard_admin.dart';

class UploadJournalPage extends StatefulWidget {
  @override
  _UploadJournalPageState createState() => _UploadJournalPageState();
}

class _UploadJournalPageState extends State<UploadJournalPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _abstractController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  int _selectedIndex = 1; // Set to 1 for the "Add" page
  String? _selectedCategory;
  List<String> categories = [
    'Science',
    'Technology',
    'Arts',
    'Business',
    'Health'
  ];

  // Method to upload files (CSV, PDF, Excel)
  Future<void> _uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'pdf', 'xls', 'xlsx']);

    if (result != null) {
      // Check if the app is running on the web
      if (kIsWeb) {
        // Handle web file upload
        final bytes = result.files.single.bytes;
        final fileExtension = result.files.single.extension;

        if (fileExtension == 'csv') {
          await _processCSVFromBytes(bytes!);
        } else if (fileExtension == 'xls' || fileExtension == 'xlsx') {
          await _processExcelFromBytes(bytes!);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Unsupported file format!')),
          );
        }
      } else {
        // Handle mobile file upload
        File file = File(result.files.single.path!);
        String fileExtension = file.path.split('.').last.toLowerCase();

        if (fileExtension == 'csv') {
          await _processCSV(file);
        } else if (fileExtension == 'pdf') {
          // Handle PDF upload if needed
        } else if (fileExtension == 'xls' || fileExtension == 'xlsx') {
          await _processExcel(file);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Unsupported file format!')),
          );
        }
      }
    }
  }

  // Mengimpor data dari file CSV
  Future<void> _processCSV(File file) async {
    try {
      String content = await file.readAsString();
      List<List<dynamic>> rowsAsListOfValues =
          const CsvToListConverter().convert(content);

      // Simpan data ke Firestore
      for (var row in rowsAsListOfValues.skip(1)) {
        if (row.length >= 6) {
          await _firestore.collection('journals').add({
            'title': row[0].toString(),
            'author': row[1].toString(),
            'category': row[2].toString(),
            'journal_release': row[3].toString(), // Simpan sebagai string
            'abstract': row[4].toString(),
            'url': row[5].toString(),
          });
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CSV uploaded successfully!')),
      );
      // Navigasi kembali ke DashboardAdmin
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardAdmin()),
      );
    } catch (e) {
      print("Error importing data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to import CSV file.')),
      );
    }
  }

  // Process CSV file from bytes and upload data to Firestore
  Future<void> _processCSVFromBytes(List<int> bytes) async {
    try {
      String content = String.fromCharCodes(bytes);
      List<List<dynamic>> rowsAsListOfValues =
          const CsvToListConverter().convert(content);

      // Simpan data ke Firestore
      for (var row in rowsAsListOfValues.skip(1)) {
        if (row.length >= 6) {
          await _firestore.collection('journals').add({
            'title': row[0].toString(),
            'author': row[1].toString(),
            'category': row[2].toString(),
            'journal_release': row[3].toString(), // Simpan sebagai string
            'abstract': row[4].toString(),
            'url': row[5].toString(),
          });
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CSV uploaded successfully!')),
      );
      // Navigasi kembali ke DashboardAdmin
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardAdmin()),
      );
    } catch (e) {
      print("Error importing data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to import CSV file.')),
      );
    }
  }

  // Process Excel file from bytes and upload data to Firestore
  Future<void> _processExcelFromBytes(List<int> bytes) async {
    try {
      var excel =
          Excel.decodeBytes(bytes); // Decode the bytes to an Excel object

      for (var table in excel.tables.keys) {
        for (var row in excel.tables[table]!.rows) {
          if (row.length >= 6) {
            await _firestore.collection('journals').add({
              'title': row[0]?.value.toString() ?? '',
              'author': row[1]?.value.toString() ?? '',
              'category': row[2]?.value.toString() ?? '',
              'journal_release':
                  row[3]?.value.toString() ?? '', // Simpan sebagai string
              'abstract': row[4]?.value.toString() ?? '',
              'url': row[5]?.value.toString() ?? '',
            });
          }
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Excel uploaded successfully!')),
      );
    } catch (e) {
      print('Error processing Excel file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload Excel file.')),
      );
    }
  }

  // Process Excel file and upload data to Firestore
  Future<void> _processExcel(File file) async {
    try {
      var bytes = await file.readAsBytes();
      var excel =
          Excel.decodeBytes(bytes); // Decode the bytes to an Excel object

      for (var table in excel.tables.keys) {
        for (var row in excel.tables[table]!.rows) {
          if (row.length >= 6) {
            await _firestore.collection('journals').add({
              'title': row[0]?.value.toString() ?? '',
              'author': row[1]?.value.toString() ?? '',
              'category': row[2]?.value.toString() ?? '',
              'journal_release': row[3]?.value.toString() ?? '',
              'abstract': row[4]?.value.toString() ?? '',
              'url': row[5]?.value.toString() ?? '',
            });
          }
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Excel uploaded successfully!')),
      );
      // Navigasi kembali ke DashboardAdmin
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardAdmin()),
      );
    } catch (e) {
      print('Error processing Excel file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload Excel file.')),
      );
    }
  }

  // Method to upload data manually
  Future<void> _uploadManual() async {
    final title = _titleController.text;
    final author = _authorController.text;
    final category = _selectedCategory;
    final abstract = _abstractController.text;
    final url = _urlController.text;
    final year = _yearController.text;

    if (title.isNotEmpty &&
        author.isNotEmpty &&
        category != null &&
        year.isNotEmpty) {
      try {
        await _firestore.collection('journals').add({
          'title': title,
          'author': author,
          'category': category,
          'journal_release': year,
          'abstract': abstract,
          'url': url,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Journal uploaded successfully!')),
        );

        _clearFields();
        // Navigasi kembali ke DashboardAdmin
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardAdmin()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading journal: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all required fields.')),
      );
    }
  }

  // Method to clear input fields
  void _clearFields() {
    _titleController.clear();
    _authorController.clear();
    _abstractController.clear();
    _urlController.clear();
    _yearController.clear();
    setState(() {
      _selectedCategory = null;
    });
  }

  // Method to select year using date picker
  Future<void> _selectYear() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _yearController.text = pickedDate.year.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          child: AppBar(
            backgroundColor: Color.fromARGB(255, 230, 214, 124),
            title: Text(
              'Upload New Journal!',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.upload_file, color: Colors.white),
                onPressed: _uploadFile,
                tooltip: 'Import Excel',
              ),
            ],
            centerTitle: true,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0)),
                filled: true,
                fillColor: const Color.fromARGB(225, 232, 191, 54),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _authorController,
              decoration: InputDecoration(
                labelText: 'Author',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0)),
                filled: true,
                fillColor: const Color.fromARGB(225, 232, 191, 54),
              ),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0)),
                filled: true,
                fillColor: const Color.fromARGB(225, 232, 191, 54),
              ),
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
            SizedBox(height: 10),
            TextField(
              controller: _yearController,
              decoration: InputDecoration(
                labelText: 'Journal Release Year',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0)),
                filled: true,
                fillColor: const Color.fromARGB(225, 232, 191, 54),
              ),
              readOnly: true,
              onTap: _selectYear,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _abstractController,
              decoration: InputDecoration(
                labelText: 'Abstract',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0)),
                filled: true,
                fillColor: const Color.fromARGB(225, 232, 191, 54),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'Link URL',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0)),
                filled: true,
                fillColor: const Color.fromARGB(225, 232, 191, 54),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadManual,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(
                    255, 232, 191, 54), // Warna latar belakang kuning
              ),
              child: Text(
                'Upload Manually',
                style: TextStyle(
                  color: Colors.white, // Warna teks putih
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 230, 214, 124),
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => DashboardAdmin()),
            );
          }
        },
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
}
