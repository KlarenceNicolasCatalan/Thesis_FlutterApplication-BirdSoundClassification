import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bird_detector/history.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class RecordingTab extends StatefulWidget {
  const RecordingTab({super.key});
  _RecordingClassState createState() => _RecordingClassState();
}

class _RecordingClassState extends State<RecordingTab> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  String? _filePath;
  File? selectedAudio;
  String? message = '';

  bool _isAuthenticated = false;
  String? authMsg = "Not Verified";
  var controller_username = TextEditingController();
  var controller_pass = TextEditingController();
  

  @override
  void dispose() {
    _audioPlayer.dispose();
    _recorder.dispose();
    super.dispose();
  }

  auth() async{
    //final request = http.MultipartRequest("POST", Uri.parse("http://192.168.18.28:5000/upload"));
    //final request = http.MultipartRequest("POST", Uri.parse("https://furfpcd48qxb.share.zrok.io/auth"));
    //final request = http.MultipartRequest("POST", Uri.parse("https://f7bxa276lngg.share.zrok.io/upload"));
    final request = http.MultipartRequest("POST", Uri.parse("http://13.250.63.76/auth"));

    final login_form = {"user": controller_username.text, "pass": controller_pass.text};
    final headers = {"Content-type": "multipart/form-data"};

    request.fields.addAll(login_form);
    request.headers.addAll(headers);
    final response = await request.send();
    http.Response res = await http.Response.fromStream(response);
    final resJson = jsonDecode(res.body);
    message = resJson['message'];
    final message_decoded = json.decode(res.body) as Map<String, dynamic>;

    //auths message
    String authStatus = message_decoded['message'];
    //authMsg = authMsg.replaceAll('_', ' ');
    authMsg = authStatus;
    setState(() {
      
    });
    print(message);
  }

  uploadFile() async{
    //final request = http.MultipartRequest("POST", Uri.parse("http://192.168.18.28:5000/upload"));
    final request = http.MultipartRequest("POST", Uri.parse("http://13.250.63.76/upload"));
    //final request = http.MultipartRequest("POST", Uri.parse("https://furfpcd48qxb.share.zrok.io/upload"));
    //final request = http.MultipartRequest("POST", Uri.parse("https://f7bxa276lngg.share.zrok.io/upload"));
    
    var currentLocation = await location.getLocation();
    String longitude = currentLocation.longitude.toString();
    String latitude = currentLocation.latitude.toString();
    final locations = {'1': longitude, '2':latitude, "auth": authMsg!};

    final headers = {"Content-type": "multipart/form-data"};

    request.files.add(http.MultipartFile('image', selectedAudio!.readAsBytes().asStream(), selectedAudio!.lengthSync(), filename: selectedAudio!.path.split("/").last));
    request.fields.addAll(locations);
    request.headers.addAll(headers);
    final response = await request.send();
    http.Response res = await http.Response.fromStream(response);
    final resJson = jsonDecode(res.body);
    message = resJson['message'];
    final message_decoded = json.decode(res.body) as Map<String, dynamic>;

    //adding widget to _records
    String birdName = message_decoded['message'];
    birdName = birdName.replaceAll('_', ' ');
    _records.add(CircleAvatar(
      backgroundImage: AssetImage('assets/images/Birds/${message_decoded['message']}.jpg'),
      radius: 60,
    ));
    _records.add(Text("\n   Identification: \n   $birdName",  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'OxygenR',
                    wordSpacing: 2)));
    _historyRecord.add("\nIdentification: $birdName");
  }

  Future<void> _startRecording() async {
    final bool isPermissionGranted = await _recorder.hasPermission();
    if (!isPermissionGranted) {
      return;
    }

    final directory = await getApplicationDocumentsDirectory();
    String fileName = 'recording_${DateTime.now().millisecondsSinceEpoch}.wav';
    _filePath = '${directory.path}/$fileName';
    selectedAudio = File(_filePath!);

    // Define the configuration for the recording
    const config = RecordConfig(
      encoder: AudioEncoder.wav, 
      sampleRate: 44100,
      bitRate: 128000,
    );

    await _recorder.start(config, path: _filePath!);
    setState(() {
      _isRecording = true;
    });

    //stopping the recorder after 3 seconds
    DateTime time;
    Timer(const Duration(seconds: 3), _stopRecording);
  }

  Future<void> _stopRecording() async {
    print("stopped recording");
    final path = await _recorder.stop();
    setState(() {
      _isRecording = false;
    });
  }

  Future<void> _predictRecording() async {
    if (_filePath != null) {
      _records.clear();
      _historyRecord.clear();

      var currentLocation = await location.getLocation();
      String longitude = currentLocation.longitude.toString();
      String latitude = currentLocation.latitude.toString();
      _records.add(Text("Audio: $_filePath \nLongitude: $longitude\nLatitude: $latitude", style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'OxygenR',
                    wordSpacing: 2)));
      _historyRecord.add("Audio: $_filePath \nLongitude: $longitude\nLatitude: $latitude");

      await uploadFile(); 
      await writingFile();
      setState(() {
        
      });

      
    }
  }

  writingFile () async{
    //Save to history.txt, then reset the list
    final directory = await getApplicationDocumentsDirectory();
    File history = File('${directory.path}/history.txt');
    if (history.existsSync()){
      history.writeAsStringSync("\n${_historyRecord.toString().replaceAll("[", "").replaceAll("]", "\n\n")}\n", mode: FileMode.append);
      print(history.readAsString());
    }
    else{
      history.create(recursive: true);
      history.writeAsString(_historyRecord.toString().replaceAll("[", "").replaceAll("]", "\n\n"));
      print(history.readAsString());
    }
  }

  List<Widget> _records = [];
  List<String> _historyRecord = [];
  Location location = new Location();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView( 
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: const BoxDecoration(color: Color.fromARGB(255, 168, 131, 119), borderRadius: BorderRadius.all(Radius.circular(20))),
              padding: const EdgeInsets.all(15),
              child: _isRecording ? const Text(
                "Recording will stop after 3 seconds"
              ) : const Text(
                "Press the Record button to record.\nPress the Identify button after recording to show the recording's classification."
              ),
            ),
            Icon(
              _isRecording ? Icons.mic : Icons.mic_none,
              size: 100,
              color: _isRecording ? Colors.red : Colors.blue,
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isRecording ? null : _startRecording,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                  ),
                  child: const Text('Record',
                  style: TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontSize: 16,
                    fontFamily: 'OxygenR',)),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _isRecording ? _stopRecording : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                  ),
                  child: const Text('Stop',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'OxygenR',)),
                ),
                const SizedBox(height: 20),
              ],
            ),
            const SizedBox(height: 20),
             ElevatedButton(
              onPressed: () async{
                showDialog(
                  barrierDismissible: false,
                  context: context, builder: (BuildContext context) => Dialog(
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    width: 200,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'IDENTIFYING...',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  )
                ));
                //!_isRecording ? _predictRecording : null;
                await _predictRecording();
                Navigator.pop(context);
              },
              //!_isRecording ? _predictRecording : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text('Identify',
              style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'OxygenR',)),
            ),     
            const SizedBox(height: 40,),
            Container(
              decoration: const BoxDecoration(color: Color.fromARGB(255, 168, 131, 119), borderRadius: BorderRadius.all(Radius.circular(20))),
              padding: const EdgeInsets.all(15),
              child: Wrap(
            children: _records),
            ),
            const SizedBox(height: 20),
             ElevatedButton(
              onPressed: () async{
                showDialog(
                  barrierDismissible: false,
                  context: context, 
                  builder: (BuildContext context) => Dialog(
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    width: 200,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextField(
                          decoration: const InputDecoration(hintText: "Enter your username."),
                          controller: controller_username,
                        ),
                        TextField(
                          decoration: const InputDecoration(hintText: "Enter your password."),
                          controller: controller_pass,
                          obscureText: true,
                        ),
                        TextButton(onPressed: () {
                          Navigator.pop(context);
                        }, child:const Text("Cancel")),
                        TextButton(onPressed: () async {
                          await auth();
                          Navigator.pop(context);
                        }, child:const Text("Login")),
                      ],
                    ),
                  ),
                )
                );
              },
              //!_isRecording ? _predictRecording : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text('Authenticate',
              style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'OxygenR',)),
            ),
            const SizedBox(height: 20,),
            Container(
              decoration: const BoxDecoration(color: Color.fromARGB(255, 168, 131, 119), borderRadius: BorderRadius.all(Radius.circular(20))),
              padding: const EdgeInsets.all(15),
              child: Text(authMsg!),
            ),
            
          ],
        ),
        )
      ),
    );
  }
}


/*
runModel () async {
  final interpreter = await Interpreter.fromAsset('assets/bird_sound_detector_10birds.tflite');

}
*/
/**
 * _records.add(Text("Audio: $_filePath \nLongitude: $longitude\nLatitude: $latitude"));
 */