import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart'; // Import the audioplayers package
import 'dart:typed_data';

class FaceRecognitionPage extends StatefulWidget {
  final CameraDescription camera;

  const FaceRecognitionPage({Key? key, required this.camera}) : super(key: key);

  @override
  _FaceRecognitionPageState createState() => _FaceRecognitionPageState();
}

class _FaceRecognitionPageState extends State<FaceRecognitionPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late AudioPlayer _audioPlayer; // Declare AudioPlayer
  String _result = "No Match";
  Color _resultColor = Colors.red;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
    _audioPlayer = AudioPlayer(); // Initialize AudioPlayer
    _startPictureTaking();
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose(); // Dispose AudioPlayer
    _timer?.cancel();
    super.dispose();
  }

  void _startPictureTaking() {
    _timer = Timer.periodic(Duration(milliseconds: 300), (timer) {
      _takePicture();
    });
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();

      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/${DateTime.now()}.png';
      File(image.path).copySync(imagePath);

      await _sendImageToApi(File(imagePath));
    } catch (e) {
      print(e);
    }
  }

  Future<void> _sendImageToApi(File image) async {
    final request = http.MultipartRequest(
        'POST', Uri.parse('http://192.168.10.179:5000/match_face'));
    request.files.add(await http.MultipartFile.fromPath('image', image.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final result = json.decode(responseData);
      setState(() {
        if (result['match']) {
          _result = 'Match Found: ${result['name']}';
          _resultColor = Colors.green;
          _playMatchSound(); // Play sound when match is found
        } else {
          _result = 'No Match';
          _resultColor = Colors.red;
        }
      });
    } else {
      setState(() {
        _result = 'Error: Unable to connect to server';
        _resultColor = Colors.red;
      });
    }
  }

  Future<void> _playMatchSound() async {
    await _audioPlayer
        .play(AssetSource('beep.mp3')); // Play beep.mp3 from assets

    // Stop the sound after a short duration
    Future.delayed(Duration(milliseconds: 100), () {
      _audioPlayer.stop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Face Recognition')),
      body: Column(
        children: [
          Expanded(
            flex: 4,
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
          Expanded(
            flex: 1,
            child: Center(
                child: Text(_result,
                    style: TextStyle(fontSize: 24, color: _resultColor))),
          ),
        ],
      ),
    );
  }
}
