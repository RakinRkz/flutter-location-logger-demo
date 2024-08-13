import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

import 'location_handler.dart';

class MyApp extends StatefulWidget {
  const MyApp ({Key? key})  : super (key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String str = 'start';
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('service demo app'),
        ),
        body: Column(
          children: [
            Text('GPS: '+ LocationHandler.instance.userCoordinates_string),
            Text('Location: ' + LocationHandler.instance.userLocation),
            ElevatedButton(
              onPressed: () async{
                final service = FlutterBackgroundService();
                var isRunning = await service.isRunning();

                if (isRunning){
                  service.invoke('stopService');
                  str = 'start';
                }
                else{
                  await LocationHandler.instance.handleLocationPermission(context);
                  await LocationHandler.instance.updateLocation();
                  service.startService();
                  str = 'stop';
                }

                setState(() {});
              },
              child: Text(str)),

          ],
        ),
      ),
    );
  }
}