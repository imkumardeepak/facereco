import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'add_person_page.dart';
import 'face_recognition_page.dart';
import 'display_added_persons_page.dart';
import 'package:intl/intl.dart'; // Add this import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(MyApp(camera: firstCamera));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  const MyApp({Key? key, required this.camera}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Face Recognition App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainPage(camera: camera),
    );
  }
}

class MainPage extends StatelessWidget {
  final CameraDescription camera;

  const MainPage({Key? key, required this.camera}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade200, // Set background color to gray
      // appBar: AppBar(
      //   title: Text('Face Recognition App'),
      // ),
      body: Column(
        children: [
          Expanded(
            flex: 4, // 30% of the screen
            child: TimeDateWidget(), // Display time and date
          ),
          Expanded(
            flex: 6, // 70% of the screen
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 14.0,
                mainAxisSpacing: 14.0,
                children: [
                  _buildCard(
                    context,
                    'Add Person',
                    Icons.person_add,
                    AddPersonPage(camera: camera),
                  ),
                  _buildCard(
                    context,
                    'Face Recognition',
                    Icons.face,
                    FaceRecognitionPage(camera: camera),
                  ),
                  _buildCard(
                    context,
                    'All Added Person',
                    Icons.verified_user,
                    DisplayAddedPersonsPage(),
                  ),
                  _buildCard(
                    context,
                    'All Added Person',
                    Icons.wallet,
                    DisplayAddedPersonsPage(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
      BuildContext context, String title, IconData icon, Widget page) {
    return Card(
      color: Colors.white, // Set card color to white
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: Colors.black, size: 50), // Set icon color to black
              SizedBox(height: 8.0),
              Text(title,
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.black)), // Set text color to black
            ],
          ),
        ),
      ),
    );
  }
}

class TimeDateWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('MMMM d, y').format(DateTime.now());
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment:
              CrossAxisAlignment.start, // Align text to the left
          children: [
            Text(
              '${TimeOfDay.now().format(context)}',
              style: TextStyle(fontSize: 48, color: Colors.black),
            ),
            SizedBox(height: 8.0),
            Text(
              formattedDate,
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}

// class AddPersonPage extends StatelessWidget {
//   final CameraDescription camera;
//   const AddPersonPage({Key? key, required this.camera}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Add Person')),
//       body: Center(child: Text('Add Person Page')),
//     );
//   }
// }

// class FaceRecognitionPage extends StatelessWidget {
//   final CameraDescription camera;
//   const FaceRecognitionPage({Key? key, required this.camera}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Face Recognition')),
//       body: Center(child: Text('Face Recognition Page')),
//     );
//   }
// }

// class DisplayAddedPersonsPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('All Added Person')),
//       body: Center(child: Text('All Added Person Page')),
//     );
//   }
// }
