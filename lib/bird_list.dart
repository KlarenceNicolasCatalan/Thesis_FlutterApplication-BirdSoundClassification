import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'bird_data.dart';

class BirdListTab extends StatelessWidget {
  final audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: birds.length,
      itemBuilder: (context, index) {
        var bird = birds[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Material(
            borderRadius: BorderRadius.circular(5.0),
            color: const Color(0xffefece2),
            child: InkWell(
              onTap: () {
                String bird_text = bird["name"]!;
                String bird_image = bird["image"]!;
                String bird_desc = bird["desc"]!;
                String bird_audio = bird["audio"]!;
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DetailsTab(
                              birdText: bird_text,
                              birdImage: bird_image,
                              birdDesc: bird_desc,
                              birdAudio: bird_audio,
                            )));
              }, // Add another page here for bird's info. Maybe TabBar for "info" and "sound".
              // Pero pwede rin naman pagsamahin yung info and sound in one page.
              borderRadius: BorderRadius.circular(10.0),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage(bird["image"]!),
                  radius: 30.0,
                ),
                title: Text(
                  bird["name"]!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'OxygenR',
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class DetailsTab extends StatelessWidget {
  final String birdText;
  final String birdImage;
  final String birdDesc;
  final String birdAudio;

  DetailsTab(
      {required this.birdText,
      required this.birdImage,
      required this.birdDesc,
      required this.birdAudio});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("2KM Bird Detector"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                  child: CircleAvatar(
                      backgroundImage: AssetImage(birdImage), radius: 100.0)),
              const SizedBox(height: 20),
              Container(
                child: Text(birdText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                      fontFamily: 'OxygenR',
                    )),
              ),
              const Divider(height: 30.0, color: Colors.blue),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text(birdDesc,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: 'OxygenR',
                    )),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () {
                    final player = AudioPlayer();
                    player.play(AssetSource(birdAudio));
                    print(birdAudio);

                
                    print("pressed");
                  },
                  child: const Text("Click for Sound",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: 'OxygenR',
                      ))),
              const SizedBox(height: 20),
            ]),
      ),
    );
  }
}
