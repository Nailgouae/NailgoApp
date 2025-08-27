import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nailgonew/screens/directions_screen_2.dart';
import 'package:nailgonew/screens/home.dart';
import 'package:nailgonew/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Camera2Screen extends StatefulWidget {
  @override
  _Camera2ScreenState createState() => _Camera2ScreenState();
}

class _Camera2ScreenState extends State<Camera2Screen> {
  CameraController? _controller;
  XFile? _imageFile;
  bool _isCaptureInProgress = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      List<CameraDescription> cameras = await availableCameras();
      if (cameras.isEmpty) {
        print('Error');
        return;
      }

      _controller = CameraController(cameras[0], ResolutionPreset.medium);
      await _controller?.initialize();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('$e');
    }
  }

  Future<void> _captureImage() async {
    try {
      if (_isCaptureInProgress) {
        return;
      }

      setState(() {
        _isCaptureInProgress = true;
      });

      if (_controller != null && _controller!.value.isInitialized) {
        try {
          final XFile? imageFile = await _controller!.takePicture();
          if (imageFile != null) {
            setState(() {
              _imageFile = imageFile;
            });

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => LoadingScreen(imageFile: imageFile),
              ),
            );
          } else {
            print('Error');
          }
        } catch (e) {
          print('$e');
        }
      }
    } finally {
      setState(() {
        _isCaptureInProgress = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final squareSize = screenWidth * 0.8;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('camera'.tr()),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          CameraPreview(_controller!),
          Positioned(
            top: 90,
            left: (MediaQuery.of(context).size.width - squareSize) / 2,
            child: Container(
              width: squareSize,
              height: squareSize,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 2.0),
              ),
            ),
          ),
          if (_imageFile != null)
            Image.file(
              File(_imageFile!.path),
              fit: BoxFit.cover,
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown,
        onPressed: () {
          _captureImage();
        },
        child: Icon(Icons.camera_alt, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class LoadingScreen extends StatefulWidget {
  final XFile imageFile;

  LoadingScreen({required this.imageFile});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  bool _isLoading = false;

  Future<void> _uploadImage(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      String apiUrl = 'http://93.127.199.143:5017/upload/thumb';

      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          widget.imageFile.path,
        ),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        print('Response Body: $responseBody');

        Map<String, dynamic> responseMap = json.decode(responseBody);

        if (responseMap.containsKey('error')) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Error'),
                content: Text(responseMap['error']),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Camera2Screen(),
                        ),
                      );
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          _processApiResponse(context, responseBody);
        }
      } else {
        print('Error uploading image. Status code: ${response.statusCode}');
        print('Response body: ${await response.stream.bytesToString()}');
        _showMessage(context, 'Failed to upload image', Colors.red);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Camera2Screen(),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('Error uploading image: $e');
      print('Stack trace: $stackTrace');
      _showMessage(context, 'Failed to upload image', Colors.red);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Camera2Screen(),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

Future<void> _processApiResponse(BuildContext context, String responseBody) async {
  try {
    Map<String, dynamic> responseMap = json.decode(responseBody);

    if (responseMap.containsKey('data') && responseMap['data'] is List<dynamic>) {
      List<Map<String, String>> fingerDetails = [];

      // Retrieve the saved four-finger measurements from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedFingerDetails = prefs.getString('finger_details');
      if (savedFingerDetails != null) {
        List<dynamic> savedDetails = jsonDecode(savedFingerDetails);
        // Safely cast each map item to Map<String, String>
        fingerDetails = savedDetails.map((item) {
          return Map<String, String>.from(item);
        }).toList();
      }

      // Process the thumb measurement from the response
      for (var item in responseMap['data']) {
        if (item.containsKey('Finger') && item['Finger'] is List) {
          List<dynamic> fingerList = item['Finger'];
          if (fingerList.length >= 2) {
            String width = fingerList[0]['width in cm'] ?? 'N/A';
            String height = fingerList[1]['height in cm'] ?? 'N/A';
            fingerDetails.add({
              'width': width,
              'height': height,
            });
          }
        }
      }

      if (fingerDetails.length == 5) {
        // Save the updated five-finger measurements in SharedPreferences
        String updatedFingerDetailsJson = jsonEncode(fingerDetails);
        await prefs.setString('finger_details', updatedFingerDetailsJson);

        // Call API to store all 5 finger measurements
        await _storeFingerData(fingerDetails);

        _showSuccessPopup(context, fingerDetails);
        _showMessage(context, 'Thumb measurements saved successfully', Colors.green);

        // Save the image path if needed
        await prefs.setString('saved_image_path', widget.imageFile.path);
      } else {
        print('Error: Incomplete finger measurements');
        _showMessage(context, 'Failed to process API response', Colors.red);
        Navigator.pop(context);
      }
    } else {
      print('Error: Unexpected API response format');
      _showMessage(context, 'Failed to process API response', Colors.red);
      Navigator.pop(context);
    }
  } catch (e) {
    print('Error processing API response: $e');
    _showMessage(context, 'Failed to process API response', Colors.red);
    Navigator.pop(context);
  }
}

// Method to call API and store all 5 finger data
Future<void> _storeFingerData(List<Map<String, String>> fingerDetails) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final accessToken = prefs.getString('accessToken') ?? '';
  final userId = prefs.getString('userId') ?? '';

  final url = Uri.parse('http://nailgo.ae/api/v2/storefingerdata');

  // Prepare the data
  Map<String, dynamic> requestBody = {
    'id': userId,
    'data': jsonEncode(fingerDetails),  // Finger details in JSON format
  };

  // Log the request body to see the data before sending it to the API
  print("Sending data to API: ${jsonEncode(requestBody)}");

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      print(response.body);
      print('Finger data stored successfully');
    } else {
      print('Error: Failed to store finger data');
    }
  } catch (e) {
    print('Error sending finger data to API: $e');
  }
}


void _showSuccessPopup(
    BuildContext context, List<Map<String, String>> fingerDetails) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/checked.png'),
            Text(
              'success'.tr(),
              style: TextStyle(color: Colors.green),
            )
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                  'fivefinger'.tr()),
              SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: fingerDetails.asMap().entries.map((entry) {
                  int index = entry.key + 1;
                  Map<String, String> finger = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Finger $index Measurement',
                            style: TextStyle(
                              fontSize: 15,
                              color: Color.fromARGB(255, 185, 92, 4),
                            )),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Width: ${finger['width']}',
                                style: TextStyle(fontSize: 15)),
                            Text('Height: ${finger['height']}',
                                style: TextStyle(fontSize: 15)),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => Home(),  // Navigate to Login Page
                ),
              );
            },
            child: Text(
              'gotoshop'.tr(),
              style: TextStyle(
                  color: Color.fromARGB(255, 185, 92, 4),
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
          ),
        ],
      );
    },
  );
}


  void _showMessage(
      BuildContext context, String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.file(
                  File(widget.imageFile.path),
                  width: 300,
                  height: 300,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 20),
                BrownButton(
                  label: 'UPLOAD',
                  onPressed: () {
                    _uploadImage(context);
                  },
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(
                  color: Color.fromARGB(255, 185, 92, 4),
                  strokeWidth: 2,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
