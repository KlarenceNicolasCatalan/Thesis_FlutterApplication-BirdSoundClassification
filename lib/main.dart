import 'package:flutter/material.dart';
import 'package:bird_detector/bird_list.dart';
import 'package:bird_detector/recording.dart';
import 'history.dart';
import 'dart:math';
import 'bird_data.dart';

void main() => runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const BD_Home(),
        theme: ThemeData(
          fontFamily: 'OxygenB',
          scaffoldBackgroundColor: const Color(0xffefece2),
          appBarTheme: const AppBarTheme(
            color: Color(0xffe7e0c7),
          ),
          tabBarTheme: const TabBarTheme(
            labelColor: Color(0xff494744),
            unselectedLabelColor: Colors.black,
            indicator: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xff746e63),
                  width: 2.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );

class BD_Home extends StatefulWidget {
  const BD_Home({super.key});
  _BD_HomeState createState() => _BD_HomeState();
}

class _BD_HomeState extends State<BD_Home> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      length: 3,
      child: Scaffold(
        drawer: Drawer(
          child: ListView(padding: const EdgeInsets.all(0.0), children: [
            const DrawerHeader(
              child: Text(
                "2KM Bird Detector",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                    fontFamily: 'OxygenR'),
              ),
            ),
            ListTile(
              title: const Text("History"),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const History(),));
              },
            ),
          ]),
        ),
        appBar: AppBar(
          title: const Text('2KM Bird Detector'),
          centerTitle: true,
          elevation: 4.0,
          bottom: const TabBar(tabs: [
             Tab(text: "RECORDING"),
             Tab(text: "HOME"),
             Tab(text: "BIRD LIST"),
          ]),
        ),
        body: TabBarView(children: <Widget>[
          //Fix some issues identifying tabs.
          //Added "RecordingTab", "HomeTab", and "BirdListTab".
          const RecordingTab(),
          const HomeTab(),
          BirdListTab(),
        ]),
      ),
    );
  }
}



class HomeTab extends StatelessWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Random random =  Random();//0-50
    int randomBird = random.nextInt(birds.length);//50(0-49)
    var bird = birds[randomBird];
    String bird_text = bird["name"]!;
    String bird_image = bird["image"]!;
    String bird_desc = bird["desc"]!;
    String bird_audio = bird["audio"]!;


    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 40, 40, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const Text(
            'A Random Bird for You',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 30.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(
            height: 20.0,
          ),
           Center(
            child: CircleAvatar(
              backgroundImage: AssetImage(bird["image"]!),
              radius: 120.0,
            ),
          ),
          const Divider(height: 30.0, color: Colors.red),
          const SizedBox(
            height: 20.0,
          ),
           Text(
            textAlign: TextAlign.center,
            bird["name"]!,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20.0,
              fontStyle: FontStyle.italic,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 20),
             ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DetailsTab(
                              birdText: bird_text,
                              birdImage: bird_image,
                              birdDesc: bird_desc,
                              birdAudio: bird_audio,
                            ))),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                  ),
                   child: const Text('Go to Bird Info',
                  style: TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontSize: 16,
                    fontFamily: 'OxygenR',)))
          
        ],
      ),
    );
  }
}
