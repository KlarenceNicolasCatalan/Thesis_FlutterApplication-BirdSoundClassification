import 'package:flutter/material.dart';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  //history.txt to history[] list for listview builder
  List _history = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Bird Recording History"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Expanded(flex: 8,
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: _history.length, 
                itemBuilder: (BuildContext context, int index) => _history[index],
                padding: const EdgeInsets.all(20),
              ),),
            Expanded(
              flex: 1,
              child: 
              Padding( 
                padding: const EdgeInsets.all(10),
                child: 
              ElevatedButton(
                onPressed: () async{
              final directory = await getApplicationDocumentsDirectory();
              File historyFile = File('${directory.path}/history.txt');
              _history.add(Text(historyFile.readAsStringSync(), 
                  style: const TextStyle(
                    color: Color.fromARGB(255, 54, 48, 48),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    fontFamily: 'OxygenR',)));
              //print(_history);
              setState(() {
                
              });
            }, child: const Text("Show History", 
                    style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'OxygenR',))),)
            ),
            Expanded(
              flex: 1,
              child: 
              Padding(
                padding: EdgeInsets.all(10),
                child: 
              ElevatedButton(onPressed: () async{
                showDialog(context: context, builder: (BuildContext context) => Dialog(
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    width: 200,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Are you sure to delete the current recorded history?',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 10,),
                        TextButton(onPressed: () => Navigator.pop(context), 
                        child: const Text('Close')),
                        TextButton(onPressed: () async{
                          final directory = await getApplicationDocumentsDirectory();
                          File historyFile = File('${directory.path}/history.txt');
                          historyFile.delete();
                          _history.clear();
                          setState(() {
                  
                  
                          });
                          Navigator.pop(context);
                        }, child: Text('Confirm'))
                      ],
                    ),
                  )
                ));
                
              }, child: const Text("Delete History", style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: 'OxygenR',))),)
            )
          ],
        )

      ), 
    );
  }
}
