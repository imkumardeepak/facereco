import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DisplayAddedPersonsPage extends StatefulWidget {
  @override
  _DisplayAddedPersonsPageState createState() =>
      _DisplayAddedPersonsPageState();
}

class _DisplayAddedPersonsPageState extends State<DisplayAddedPersonsPage> {
  List<Map<String, String>> _imageData = [];

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    final response =
        await http.get(Uri.parse('http://192.168.10.179:5000/images'));

    if (response.statusCode == 200) {
      // Parse the JSON response as a list of maps
      final List<dynamic> jsonResponse = json.decode(response.body);

      setState(() {
        _imageData = jsonResponse
            .map((item) {
              final filename = item['filename'] as String;
              // Remove the file extension from the filename
              final nameWithoutExtension = filename.split('.').first;
              return {
                'filename': filename,
                'url': 'http://192.168.10.179:5000/images/$filename',
                'name': nameWithoutExtension,
              };
            })
            .toList()
            .cast<Map<String, String>>(); // Ensure type compatibility
      });
    } else {
      // Handle errors
      print('Error loading images: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Added Persons')),
      body: _imageData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              padding: EdgeInsets.all(8.0),
              itemCount: _imageData.length,
              itemBuilder: (context, index) {
                final image = _imageData[index];
                return GridTile(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Image.network(
                          image['url']!,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        image['name']!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
