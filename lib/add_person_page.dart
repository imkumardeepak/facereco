import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddPersonPage extends StatefulWidget {
  final CameraDescription camera;

  const AddPersonPage({Key? key, required this.camera}) : super(key: key);

  @override
  _AddPersonPageState createState() => _AddPersonPageState();
}

class _AddPersonPageState extends State<AddPersonPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _takePictureAndAddPerson() async {
    if (_nameController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter a name",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();

      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/${DateTime.now()}.png';
      File(image.path).copySync(imagePath);

      await _sendImageToApi(File(imagePath), _nameController.text);
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendImageToApi(File image, String name) async {
    final request = http.MultipartRequest(
        'POST', Uri.parse('http://192.168.10.179:5000/add_person'));
    request.files.add(await http.MultipartFile.fromPath('image', image.path));
    request.fields['name'] = name;

    final response = await request.send();
    if (response.statusCode == 200) {
      Fluttertoast.showToast(
        msg: "Person added successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    } else {
      Fluttertoast.showToast(
        msg: "Error adding person",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Person')),
      body: _isLoading
          ? Center(
              child: SpinKitCircle(
                color: Colors.blue,
                size: 50.0,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: Color.fromARGB(211, 64, 17, 175),
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Expanded(
                    child: FutureBuilder<void>(
                      future: _initializeControllerFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return CameraPreview(_controller);
                        } else {
                          return Center(child: CircularProgressIndicator());
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 16.0),
                  SizedBox(
                    width: double.infinity, // Makes the button full-width
                    child: ElevatedButton.icon(
                      onPressed: _takePictureAndAddPerson,
                      icon: Icon(Icons.add), // Icon to be displayed
                      label: Text('Add Person'), // Text to be displayed
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            vertical:
                                16.0), // Optional: Makes the button taller
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
