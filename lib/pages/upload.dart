import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:journalyze/pages/dashboard_admin.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
// import 'package:xlsx/xlsx.dart' as xlsx; // Add a dependency for handling Excel files

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

  int _selectedIndex = 0;
  String? _selectedCategory;
  List<String> categories = ['Science', 'Technology', 'Arts', 'Business', 'Health'];

  // Method to upload files (CSV, PDF, Excel)
  Future<void> _uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['csv', 'pdf', 'xls', 'xlsx']);

    if (result != null) {
      File file = File(result.files.single.path!);
      String fileExtension = file.path.split('.').last.toLowerCase();

      if (fileExtension == 'csv') {
        await _processCSV(file);
      } else if (fileExtension == 'pdf') {
        await _processPDF(file);
      } else if (fileExtension == 'xls' || fileExtension == 'xlsx') {
        await _processExcel(file);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unsupported file format!')),
        );
      }
    }
  }

  // Process CSV file and upload data to Firestore
  Future<void> _processCSV(File file) async {
    String content = await file.readAsString();
    List<List<dynamic>> rowsAsListOfValues = content.split('\n').map((e) => e.split(',')).toList();

    for (var row in rowsAsListOfValues.skip(1)) {
      if (row.length >= 6) {
        try {
          await _firestore.collection('journals').add({
            'title': row[0],
            'author': row[1],
            'category': row[2],
            'journal_release': row[3],
            'abstract': row[4],
            'url': row[5],
          });
        } catch (e) {
          print('Error uploading journal: $e');
        }
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('CSV uploaded successfully!')),
    );
  }

  // Process PDF file (content extraction can be implemented if needed)
  Future<void> _processPDF(File file) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF file uploaded! (Content extraction not implemented)')),
    );
  }

  // Process Excel file (content extraction can be implemented if needed)
  Future<void> _processExcel(File file) async {
    var bytes = await file.readAsBytes();
    // var excel = xlsx.Excel.decodeBytes(bytes);  // Using a library to handle Excel data

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Excel file uploaded! (Content extraction not implemented)')),
    );
  }

  // Method to upload data manually
  Future<void> _uploadManual() async {
    final title = _titleController.text;
    final author = _authorController.text;
    final category = _selectedCategory;
    final abstract = _abstractController.text;
    final url = _urlController.text;
    final year = _yearController.text;

    if (title.isNotEmpty && author.isNotEmpty && category != null && year.isNotEmpty) {
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DashboardAdmin()),
    );
  } else if (index == 1) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => UploadJournalPage()),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Journal Detail'),
        actions: [
          IconButton(
            icon: Icon(Icons.upload_file),
            onPressed: _uploadFile,
            tooltip: 'Import CSV, PDF, or Excel',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                filled: true,
                fillColor: const Color.fromARGB(225, 232, 191, 54),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _authorController,
              decoration: InputDecoration(
                labelText: 'Author',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                filled: true,
                fillColor: const Color.fromARGB(225, 232, 191, 54),
              ),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                filled: true,
                fillColor: const Color.fromARGB(225, 232, 191, 54),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'Link URL',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                filled: true,
                fillColor: const Color.fromARGB(225, 232, 191, 54),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadManual,
              child: Text('Upload Manually'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 230, 214, 124),
        currentIndex: _selectedIndex,
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
}
