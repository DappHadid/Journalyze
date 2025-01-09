import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class UploadJournalPage extends StatefulWidget {
  @override
  _UploadJournalPageState createState() => _UploadJournalPageState();
}

class _UploadJournalPageState extends State<UploadJournalPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _abstractController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  Future<void> _uploadCSV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['csv']);

    if (result != null) {
      File file = File(result.files.single.path!);
      String content = await file.readAsString();

      List<List<dynamic>> rowsAsListOfValues =
          content.split('\n').map((e) => e.split(',')).toList();

      for (var row in rowsAsListOfValues.skip(1)) {
        if (row.length >= 6) {
          try {
            await _firestore.collection('journals').add({
              'title': row[0],
              'author': row[1],
              'category': row[2],
              'publication_date': row[3],
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
  }

  Future<void> _uploadManual() async {
    final title = _titleController.text;
    final author = _authorController.text;
    final category = _categoryController.text;
    final abstract = _abstractController.text;
    final url = _urlController.text;
    final year = _yearController.text;

    if (title.isNotEmpty && author.isNotEmpty && category.isNotEmpty && year.isNotEmpty) {
      try {
        await _firestore.collection('journals').add({
          'title': title,
          'author': author,
          'category': category,
          'publication_date': year,
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

  void _clearFields() {
    _titleController.clear();
    _authorController.clear();
    _categoryController.clear();
    _abstractController.clear();
    _urlController.clear();
    _yearController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Journal Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _authorController,
              decoration: InputDecoration(labelText: 'Author'),
            ),
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(labelText: 'Category'),
            ),
            TextField(
              controller: _yearController,
              decoration: InputDecoration(labelText: 'Publication Year'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _abstractController,
              decoration: InputDecoration(labelText: 'Abstract'),
            ),
            TextField(
              controller: _urlController,
              decoration: InputDecoration(labelText: 'Link URL'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadManual,
              child: Text('Upload'),
            ),
            ElevatedButton.icon(
              onPressed: _uploadCSV,
              icon: Icon(Icons.upload_file),
              label: Text('Import CSV'),
            ),
          ],
        ),
      ),
    );
  }
}
