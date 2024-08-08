import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LiveSnapshotPage extends StatefulWidget {
  final CameraDescription camera;

  const LiveSnapshotPage({Key? key, required this.camera}) : super(key: key);

  @override
  _LiveSnapshotPageState createState() => _LiveSnapshotPageState();
}

class _LiveSnapshotPageState extends State<LiveSnapshotPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  int? _circleCount;
  Uint8List? _outputImageBytes;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
    _startLiveSnapshot();
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startLiveSnapshot() {
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      _captureAndSendSnapshot();
    });
  }

  Future<void> _captureAndSendSnapshot() async {
    try {
      await _initializeControllerFuture;

      final XFile file = await _controller.takePicture();

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.100.50:5000/detect_circles'),
      );

      request.files.add(await http.MultipartFile.fromPath('image', file.path));
      request.fields['min_radius'] = '20';
      request.fields['max_radius'] = '40';

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final responseJson = json.decode(responseData);

        setState(() {
          _circleCount = responseJson['circle_count'];
          _outputImageBytes = base64Decode(responseJson['output_image']);
        });
      } else {
        throw Exception('Failed to send snapshot');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Live Snapshot')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: [
                Expanded(
                  child: CameraPreview(_controller),
                ),
                if (_circleCount != null)
                  Text('Circles detected: $_circleCount'),
                if (_outputImageBytes != null) Image.memory(_outputImageBytes!),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
