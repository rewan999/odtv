import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'bndbox.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';
import 'package:device_apps/device_apps.dart';

import 'dart:math' as math;

import 'camera.dart';
import 'bndbox.dart';
import 'models.dart';

class HomePage extends StatefulWidget {
  final List<CameraDescription> cameras;

  HomePage(this.cameras);

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<dynamic> _recognitions;
  final Null ans = null;
  FlutterTts flutterTts = new FlutterTts();
  int _imageHeight = 0;
  int _imageWidth = 0;
  String _model = "";
  double screenH=0;
  double screenW=0;
  late int previewH;
  late int previewW;
  double left =0;
  double top =0;
  double mid=0;
  double woo=0;


  @override
  void initState() {
    super.initState();
    customSpeak("Welcome to a odto, ready for your service");
  }

  loadModel() async {
    //FlutterTts flutterTts = new FlutterTts();

    customSpeak("Your object detection has been started using SSD Mobilenet Model");

    String res;
    switch (_model) {
      case yolo:
        res = (await Tflite.loadModel(
          model: "assets/yolov2_tiny.tflite",
          labels: "assets/yolov2_tiny.txt",
        ))!;
        break;

      case mobilenet:
        res = (await Tflite.loadModel(
            model: "assets/mobilenet_v1_1.0_224.tflite",
            labels: "assets/mobilenet_v1_1.0_224.txt"))!;
        break;

      case posenet:
        res = (await Tflite.loadModel(
            model: "assets/posenet_mv1_075_float_from_checkpoints.tflite"))!;
        break;

      default:
        res = (await Tflite.loadModel(
            model: "assets/ssd_mobilenet.tflite",
            labels: "assets/ssd_mobilenet.txt"))!;
    }
    print(res);
  }

  onSelect(model) {
    setState(() {
      _model = model;
      Fluttertoast.showToast(
          msg: "You are using $_model model for object detection !!!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM);
    });

    // Call setRecognitions to initialize _recognitions
    setRecognitions([], 0, 0);
    loadModel();
  }


  setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(() {
      _recognitions = recognitions ?? []; // Initialize with an empty list if null
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;

      try1();
    });
  }


  try1(){
    Size screen = MediaQuery.of(context).size;
    screenW=screen.width;
    screenH=screen.height;
    previewH=math.max(_imageHeight, _imageWidth);
    previewW=math.min(_imageHeight, _imageWidth);
    //print(_recognitions);
    _recognitions == null ? [] : _recognitions.map((re){


      var _x = re["rect"]["x"];
      var _w = re["rect"]["w"];
      var _y = re["rect"]["y"];
      var _h = re["rect"]["h"];
      var scaleW, scaleH, x, y, w, h;
      //print(_x);
      //print(_y);

      if (screenH / screenW > previewH / previewW) {

        scaleW = screenH / previewH * previewW;
        scaleH = screenH;
        //print(scaleH);
        //print(scaleW);
        var difW = (scaleW - screenW) / scaleW;
        x = (_x - difW / 2) * scaleW;
        w = _w * scaleW;
        if (_x < difW / 2) w -= (difW / 2 - _x) * scaleW;
        y = _y * scaleH;
        h = _h * scaleH;
        //print(x);
        //print(y);
      } else {
        scaleH = screenW / previewW * previewH;
        scaleW = screenW;
        var difH = (scaleH - screenH) / scaleH;
        x = _x * scaleW;
        w = _w * scaleW;
        y = (_y - difH / 2) * scaleH;
        h = _h * scaleH;
        //print(x);
        //print(y);
        if (_y < difH / 2) h -= (difH / 2 - _y) * scaleH;
        //print(x);
        //print(y);



      }

      left=math.max(0,x);
      top=math.max(0,y);

      print(left);
      print(w);
      woo=math.min(left+w,480);
      mid=(left+w)/2;
      print("-------");
      print("This is ${re["detectedClass"]} with ${re["confidenceInClass"]}");
      print(mid);
      print("-------");
      if(re["confidenceInClass"]>0.5){
       // FlutterTts flutterTts = new FlutterTts();
        flutterTts.speak("There is a ${re["detectedClass"]} ahead");
        //flutterTts.setSilence(3);
        //VoiceController controller =
        //                  FlutterTextToSpeech.instance.voiceController();
        //controller.init().then((_) {
        //    controller.speak("There is a ${re["detectedClass"]} ahead!!!",
        //    VoiceControllerOptions(delay: 3));
        //});
        //print(math.max(0,x));
        if(mid>=165){
          flutterTts.speak("There is a ${re["detectedClass"]} on your right side");
        }
        else{

          flutterTts.speak("There is a ${re["detectedClass"]} on your left side");
        }


        //print("This is ${re["detectedClass"]} with ${re["confidenceInClass"]}");
        Fluttertoast.showToast(msg: "There is a ${re["detectedClass"]} ahead!!!",  toastLength: Toast.LENGTH_SHORT, gravity:  ToastGravity.BOTTOM);

      }

    }).toList();
    //var object = recognitions.where((user) => user[""] > 50);
    //print(object);





  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color(0xff7F84BE),
      body: _model == ""
          ? Center(
        child: ListView(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 10),
                  SizedBox(height: 10),
                  Image.asset(
                    'assets/icon/lol.png',
                  ),
                  SizedBox(height: 10),
                  Text(
                    "ODTO",
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 30.0,
                        fontFamily: "Raleway"),

                  ),
                  /*
                    Container(
                      width: 300.0,
                      child: TextFormField(
                        decoration: InputDecoration(labelText: 'Username'),
                      ),
                    ),
                    Container(
                      width: 300.0,
                      child: TextFormField(
                        decoration: InputDecoration(labelText: 'Password'),
                      ),
                    ),
                    */
                  SizedBox(height: 10),
                  SizedBox(height: 10),

                  ButtonTheme(
                    minWidth: 180.0,
                    height: 40.0,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.deepPurpleAccent,
                      ),
                      onPressed: () => onSelect(ssd),
                      child: Text(
                        "Start Object Detection !",
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 17,
                          fontFamily: "Raleway",
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 10),


                ],
              ),]
        ),
      ): _recognitions == null
          ? Center(
        child: CircularProgressIndicator(), // Loading indicator
      )
          : Stack(
        children: [
          Camera(
            widget.cameras,
            _model,
            setRecognitions,
          ),
          BndBox(
            _recognitions,
            math.max(_imageHeight, _imageWidth),
            math.min(_imageHeight, _imageWidth),
            screen.height,
            screen.width,
            _model,
          ),
        ],
      ),
    );
  }
  speak() async{
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1);
    await flutterTts.setSpeechRate(0.4);

  }
  customSpeak(text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.1);
    await flutterTts.setSpeechRate(0.3);
    await flutterTts.speak(text);
  }
}
