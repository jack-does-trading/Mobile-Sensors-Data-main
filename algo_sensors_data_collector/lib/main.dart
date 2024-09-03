import 'dart:async';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'accelerometer_data.dart';
import 'gyroscope_data.dart';
import 'dart:convert';
import 'location.dart';
import 'package:battery_info/battery_info_plugin.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {


    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sensors Demo',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const MyHomePage(title: 'Flutter Sensor Data Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<double>? _accelerometerValues;
  List<double>? _gyroscopeValues;
  var apistatus;
  double bandwidth=0.0;
  var current;
  var ip;
  var voltage;
  var initial_consumption;
  var current_consumption;
  var total_consumption;
  List<StreamSubscription<dynamic>> _streamSubscriptions = [];
  late StreamSubscription<GyroscopeEvent>gyrosubs;
  int select_time=1;
  List<AccelerometerData> _accelerometerData = [];
  List<GyroscopeData> _gyroscopeData = [];
  List<AccelerometerData> _accelerometerData_for_turning = [];
  List<GyroscopeData> _gyroscopeData_for_turning = [];
  List<location_data> locations=[];
  String activity_name='Normal';
  String activity_name_for_turning='Normal';
  double acc_sampling=0.0;
  double gyro_sampling=0.0;
  late Timer timer;
  final file_name=TextEditingController();
  bool listen_gyro=false;
  bool listen_gyro_for_turning=false;
  double acc=0,breaking=0,right=0,left=0,acc_check=0,acc_check_for_turning=0;

  @override
  Widget build(BuildContext context) {
    final accelerometer =
    _accelerometerValues?.map((double v) => v.toStringAsFixed(1)).toList();
    final gyroscope =
    _gyroscopeValues?.map((double v) => v.toStringAsFixed(1)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('RouteMinder Profiler'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left:MediaQuery.of(context).size.width/40,right:MediaQuery.of(context).size.width/40,top:MediaQuery.of(context).size.width/40,bottom: MediaQuery.of(context).size.width/80),
              child: RichText(
                text: TextSpan(
                  text: 'Date: ',
                  style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black,fontSize: 12),
                  children: <TextSpan>[
                    TextSpan(
                      text:'${DateTime.now()}',
                      style: TextStyle(fontWeight: FontWeight.w300, color: Colors.black,fontSize: 12),
                    ),

                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left:MediaQuery.of(context).size.width/40,right:MediaQuery.of(context).size.width/40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      text: 'Activity: ',
                      style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black,fontSize: 12),
                      children: <TextSpan>[
                        TextSpan(
                          text:activity_name,
                          style: TextStyle(fontWeight: FontWeight.w300, color: Colors.black,fontSize: 12),
                        ),

                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width/2.5,
                    child: TextFormField(
                      onChanged: (value) {
                      ip=value;
                      },

                      keyboardType: TextInputType.name
                      ,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(20),
                      ],
                      enableInteractiveSelection: false,
                      style: TextStyle(color: Color(0xff335F5E)),
                      textAlign: TextAlign.left,
                      decoration: InputDecoration(hintText: 'IP',hintStyle: TextStyle(fontWeight: FontWeight.w400,color: Colors.black,fontSize: 12)),

                      validator: (firstname) =>
                      firstname != null && firstname.length! < 10
                          ? 'First name cannot be empty'
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding:  EdgeInsets.only(top: MediaQuery.of(context).size.width/150,
                  left: MediaQuery.of(context).size.width/40,
                  right:  MediaQuery.of(context).size.width/40,
                  bottom: MediaQuery.of(context).size.width/40 ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width/2.5,
                    child: TextFormField(
                      onChanged: (value) {
                        select_time=int.parse(value);
                      },
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(10),
                      ],

                      enableInteractiveSelection: false,
                      style: TextStyle(color: Color(0xff335F5E)),
                      textAlign: TextAlign.left,
                      decoration: InputDecoration(hintText: 'Time For Other Calculation',hintStyle: TextStyle(fontWeight: FontWeight.w400,color: Colors.black,fontSize: 12)),

                      validator: (firstname) =>
                      firstname != null && firstname.length! < 10
                          ? 'First name cannot be empty'
                          : null,
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width/2.5,
                    child: TextFormField(
                      onChanged: (value) {

                      },
                      controller: file_name,
                      keyboardType: TextInputType.name
                      ,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(20),
                      ],
                      enableInteractiveSelection: false,
                      style: TextStyle(color: Color(0xff335F5E)),
                      textAlign: TextAlign.left,
                      decoration: InputDecoration(hintText: 'Filename',hintStyle: TextStyle(fontWeight: FontWeight.w400,color: Colors.black,fontSize: 12)),

                      validator: (firstname) =>
                      firstname != null && firstname.length! < 10
                          ? 'First name cannot be empty'
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding:   EdgeInsets.only(left:MediaQuery.of(context).size.width/40,right:MediaQuery.of(context).size.width/40,bottom:MediaQuery.of(context).size.width/20,  ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width/5,
                    child: TextFormField(
                      onChanged: (value) {
                        acc=double.parse(value);
                      },
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(10),
                      ],

                      enableInteractiveSelection: false,
                      style: TextStyle(color: Color(0xff335F5E)),
                      textAlign: TextAlign.left,
                      decoration: InputDecoration(hintText: 'Acceleration',hintStyle: TextStyle(fontWeight: FontWeight.w400,color: Colors.black,fontSize: 12)),

                      validator: (firstname) =>
                      firstname != null && firstname.length! < 10
                          ? 'First name cannot be empty'
                          : null,
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width/5,
                    child: TextFormField(
                      onChanged: (value) {
                        breaking=double.parse(value);
                      },
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(10),
                      ],

                      enableInteractiveSelection: false,
                      style: TextStyle(color: Color(0xff335F5E)),
                      textAlign: TextAlign.left,
                      decoration: InputDecoration(hintText: 'Break',hintStyle: TextStyle(fontWeight: FontWeight.w400,color: Colors.black,fontSize: 12)),

                      validator: (firstname) =>
                      firstname != null && firstname.length! < 10
                          ? 'First name cannot be empty'
                          : null,
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width/5,
                    child: TextFormField(
                      onChanged: (value) {
                        left=double.parse(value);
                      },
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(10),
                      ],

                      enableInteractiveSelection: false,
                      style: TextStyle(color: Color(0xff335F5E)),
                      textAlign: TextAlign.left,
                      decoration: InputDecoration(hintText: 'Left',hintStyle: TextStyle(fontWeight: FontWeight.w400,color: Colors.black,fontSize: 12)),

                      validator: (firstname) =>
                      firstname != null && firstname.length! < 10
                          ? 'First name cannot be empty'
                          : null,
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width/5,
                    child: TextFormField(
                      onChanged: (value) {
                        right=double.parse(value);
                      },
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(10),
                      ],

                      enableInteractiveSelection: false,
                      style: TextStyle(color: Color(0xff335F5E)),
                      textAlign: TextAlign.left,
                      decoration: InputDecoration(hintText: 'Right',hintStyle: TextStyle(fontWeight: FontWeight.w400,color: Colors.black,fontSize: 12)),

                      validator: (firstname) =>
                      firstname != null && firstname.length! < 10
                          ? 'First name cannot be empty'
                          : null,
                    ),
                  ),
                   ],),
            ),
            Padding(
              padding:   EdgeInsets.only(left:MediaQuery.of(context).size.width/40,right:MediaQuery.of(context).size.width/40 ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MaterialButton(onPressed: (){
                    checkAccelerometerSamplingRate();
                    checkgyroSamplingRate();
                  },height: 30,
                    minWidth: 40,child: Text("   Sampling   ", style: TextStyle(color: Colors.white,fontSize: 12)),color: Colors.teal,),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      RichText(
                        text: TextSpan(
                          text: 'Acc Sampling: ',
                          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black,fontSize: 12),
                          children: <TextSpan>[
                            TextSpan(
                              text:'$acc_sampling',
                              style: TextStyle(fontWeight: FontWeight.w300, color: Colors.black,fontSize: 12),
                            ),

                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          text: 'Gyro Sampling: ',
                          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black,fontSize: 12),
                          children: <TextSpan>[
                            TextSpan(
                              text:'$gyro_sampling',
                              style: TextStyle(fontWeight: FontWeight.w300, color: Colors.black,fontSize: 12),
                            ),

                          ],
                        ),
                      ),

                    ],
                  ),


                ],),
            ),
            Padding(
              padding:  EdgeInsets.only(top: MediaQuery.of(context).size.width/40,
                  left: MediaQuery.of(context).size.width/40,
                  right:  MediaQuery.of(context).size.width/40,
                  bottom: MediaQuery.of(context).size.width/40 ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MaterialButton(onPressed: () async {
                    current=(await BatteryInfoPlugin().androidBatteryInfo)?.currentNow;
                    voltage=(await BatteryInfoPlugin().androidBatteryInfo)?.voltage;
                    setState(() {

                      initial_consumption=(voltage/1000)*(current/1000)*select_time;
                    });

                  } ,minWidth: 10, height: 30,
                    child: Text("Initial Energy", style: TextStyle(color: Colors.white,fontSize: 12,fontWeight: FontWeight.w500),),color: Colors.teal,),

                  RichText(
                    textAlign: TextAlign.end,
                    text: TextSpan(
                      text: 'Initial Energy in $select_time Sec\n',
                      style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black,fontSize: 12),
                      children: <TextSpan>[
                        TextSpan(
                          text:'$initial_consumption Joules',
                          style: TextStyle(fontWeight: FontWeight.w300, color: Colors.black,fontSize: 12),
                        ),

                      ],
                    ),
                  ),



                ],
              ),
            ),
            Padding(
              padding:  EdgeInsets.only(top: MediaQuery.of(context).size.width/20,left: MediaQuery.of(context).size.width/40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  RichText(
                    text: TextSpan(
                      text: 'Accelerometer: ',
                      style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black,fontSize: 12),
                      children: <TextSpan>[
                        TextSpan(
                          text:'$accelerometer',
                          style: TextStyle(fontWeight: FontWeight.w300, color: Colors.black,fontSize: 12),
                        ),

                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      text: 'Gyroscope: ',
                      style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black,fontSize: 12),
                      children: <TextSpan>[
                        TextSpan(
                          text:'$gyroscope',
                          style: TextStyle(fontWeight: FontWeight.w300, color: Colors.black,fontSize: 12),
                        ),

                      ],
                    ),
                  ),

                ],
              ),
            ),
            Padding(
              padding:  EdgeInsets.only(top: MediaQuery.of(context).size.width/20,
                  left: MediaQuery.of(context).size.width/40,
                    ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  RichText(
                    text: TextSpan(
                      text: 'Energy Consuming in $select_time: ',
                      style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black,fontSize: 12),
                      children: <TextSpan>[
                        TextSpan(
                          text:'$total_consumption Joules',
                          style: TextStyle(fontWeight: FontWeight.w300, color: Colors.black,fontSize: 12),
                        ),

                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      text: 'Bandwidth: ',
                      style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black,fontSize: 12),
                      children: <TextSpan>[
                        TextSpan(
                          text:'$bandwidth Mbps',
                          style: TextStyle(fontWeight: FontWeight.w300, color: Colors.black,fontSize: 12),
                        ),

                      ],
                    ),
                  ),

                ],
              ),
            ),
            Padding(
              padding:  EdgeInsets.only(top: MediaQuery.of(context).size.width/20,left: MediaQuery.of(context).size.width/40 ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  RichText(
                    text: TextSpan(
                      text: 'Length Accelerometer: ',
                      style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black,fontSize: 12),
                      children: <TextSpan>[
                        TextSpan(
                          text:'${_accelerometerData.length}',
                          style: TextStyle(fontWeight: FontWeight.w300, color: Colors.black,fontSize: 12),
                        ),

                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      text: 'Length Gyro: ',
                      style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black,fontSize: 12),
                      children: <TextSpan>[
                        TextSpan(
                          text:'${_gyroscopeData.length}',
                          style: TextStyle(fontWeight: FontWeight.w300, color: Colors.black,fontSize: 12),
                        ),

                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      text: 'Length Accelerometer Turning: ',
                      style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black,fontSize: 12),
                      children: <TextSpan>[
                        TextSpan(
                          text:'${_accelerometerData_for_turning.length}',
                          style: TextStyle(fontWeight: FontWeight.w300, color: Colors.black,fontSize: 12),
                        ),

                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      text: 'Length Gyro Turning: ',
                      style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black,fontSize: 12),
                      children: <TextSpan>[
                        TextSpan(
                          text:'${_gyroscopeData_for_turning.length}',
                          style: TextStyle(fontWeight: FontWeight.w300, color: Colors.black,fontSize: 12),
                        ),

                      ],
                    ),
                  ),

                ],
              ),
            ),
            Padding(
              padding:  EdgeInsets.only(top: MediaQuery.of(context).size.width/20,left: MediaQuery.of(context).size.width/40,bottom:MediaQuery.of(context).size.width/40 ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  RichText(
                    text: TextSpan(
                      text: 'Current: ',
                      style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black,fontSize: 12),
                      children: <TextSpan>[
                        TextSpan(
                          text:'$current',
                          style: TextStyle(fontWeight: FontWeight.w300, color: Colors.black,fontSize: 12),
                        ),

                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      text: 'Voltage: ',
                      style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black,fontSize: 12),
                      children: <TextSpan>[
                        TextSpan(
                          text:'$voltage',
                          style: TextStyle(fontWeight: FontWeight.w300, color: Colors.black,fontSize: 12),
                        ),

                      ],
                    ),
                  ),

                ],
              ),
            ),
            Padding(
              padding:  EdgeInsets.only(top: MediaQuery.of(context).size.width/20,left: MediaQuery.of(context).size.width/40,bottom:MediaQuery.of(context).size.width/20 ),
              child: RichText(
                text: TextSpan(
                  text: 'Api Status: ',
                  style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black,fontSize: 12),
                  children: <TextSpan>[
                    TextSpan(
                      text:'$apistatus',
                      style: TextStyle(fontWeight: FontWeight.w300, color: Colors.black,fontSize: 12),
                    ),

                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MaterialButton(
                  child: Text(
                    "Start",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onPressed: () async {
                    await Geolocator.checkPermission();
                    await Geolocator.requestPermission();
                    _accelerometerData.clear();
                    _gyroscopeData.clear();
                    _accelerometerData_for_turning.clear();
                    _gyroscopeData_for_turning.clear();
                     _streamSubscriptions = [];
                     print("$acc, $breaking, $left, $right");
                    _streamSubscriptions.add(
                      accelerometerEvents.listen((AccelerometerEvent event) {

                        if (event.z > acc) {
                          print(acc_check);
                          acc_check++;
                          if (acc_check > 2) {
                            activity_name='Acceleration';
                            setState(() {
                              listen_gyro=true;
                              _accelerometerData.add(AccelerometerData(
                                DateTime.now(),
                                <double>[event.x, event.y, event.z],
                                activity_name,
                              ));
                            });
                          }
                        }
                        else if (event.z < breaking) {
                          acc_check++;
                          if (acc_check > 1) {
                            activity_name='Breaking';
                            setState(() {
                              listen_gyro=true;
                              _accelerometerData.add(AccelerometerData(
                                DateTime.now(),
                                <double>[event.x, event.y, event.z],
                                activity_name,
                              ));
                            });
                          }
                        }
                        else if ((acc_check != 0 && event.z < acc)||(acc_check !=0 && event.z > breaking)) {
                          acc_check = 0;
                          listen_gyro=false;
                          printing_all_data(0);
                        }


                     if (event.x >right) {
                       acc_check_for_turning++;
                          if (acc_check_for_turning > 2) {
                            activity_name_for_turning='Right';
                            setState(() {
                              listen_gyro_for_turning=true;
                              _accelerometerData_for_turning.add(AccelerometerData(
                                DateTime.now(),
                                <double>[event.x, event.y, event.z],
                                activity_name_for_turning,
                              ));
                            });
                          }
                        }
                     else if (event.x < -left) {
                       acc_check_for_turning++;
                          if (acc_check_for_turning > 2) {
                            activity_name_for_turning='Left';
                            setState(() {
                              listen_gyro_for_turning=true;
                              _accelerometerData_for_turning.add(AccelerometerData(
                                DateTime.now(),
                                <double>[event.x, event.y, event.z],
                                activity_name_for_turning,
                              ));
                            });
                          }
                        }
                      else if ( (acc_check_for_turning !=0 && event.x > (-left)) || (acc_check_for_turning !=0 && event.x < right)) {
                       acc_check_for_turning = 0;
                       listen_gyro_for_turning=false;
                        printing_all_data(1);

                        }
                      }),

                    );
                    gyroscopeEvents.listen((GyroscopeEvent event) {
                      setState(() {
                        if(listen_gyro==true){
                          _gyroscopeData.add(GyroscopeData(
                            DateTime.now(),
                            <double>[event.x, event.y, event.z],
                            activity_name,
                          ));
                        }
                         if(listen_gyro_for_turning==true){
                          _gyroscopeData_for_turning.add(GyroscopeData(
                            DateTime.now(),
                            <double>[event.x, event.y, event.z],
                            activity_name_for_turning,
                          ));
                        }
                      });
                    });
                    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((Position position) {
                      setState(() {
                        locations.add(
                          location_data(
                            position.latitude,
                            position.longitude,
                            activity_name,
                            DateTime.now(),
                          ),
                        );
                      });
                    });
                  },
                  color: Colors.teal,
                  minWidth: 10,
                  height: 25,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width/6,
                ),
                MaterialButton(
                  child:  Text("Stop",style: TextStyle(color: Colors.white,fontSize: 12,fontWeight: FontWeight.w500),),

                  onPressed: () {

                   listen_gyro=false;
                   listen_gyro_for_turning=false;
                    print("length: ${_accelerometerData.length}");
                    print("length: ${_gyroscopeData.length}");
                   print("length turning acc: ${_accelerometerData_for_turning.length}");
                   print("length turning gyro: ${_gyroscopeData_for_turning.length}");
                    _streamSubscriptions.forEach((subscription) {
                      subscription.pause();
                    });

                    _accelerometerData.clear();
                    _gyroscopeData.clear();
                   _accelerometerData_for_turning.clear();
                   _gyroscopeData_for_turning.clear();

                    timer.cancel();


                  },
                  color: Colors.red,
                  minWidth: 10,
                  height: 25,
                ),
              ],
            ),



          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }
  @override
  void initState() {
    super.initState();
    _streamSubscriptions.add(
      accelerometerEvents.listen((AccelerometerEvent event) {
          _accelerometerValues = <double>[event.x, event.y, event.z];
      }),
    );
    _streamSubscriptions.add(
      gyroscopeEvents.listen((GyroscopeEvent event) {

          _gyroscopeValues = <double>[event.x, event.y, event.z];

      }),
    );
  }
  printing_all_data( int identity) async {
    try {
      final url = Uri.parse('http://$ip:8000/print_data');
      List<Map<String, dynamic>> getAccelerometerJsonData() {
        return _accelerometerData
            .map<Map<String, dynamic>>((data) => data.toJson())
            .toList();
      }

      List<Map<String, dynamic>> getGyroscopeJsonData() {
        return  _gyroscopeData.map<Map<String, dynamic>>((data) => data.toJson())
            .toList();}
      List<Map<String, dynamic>> getAccelerometerJsonData_or_turning() {
        return _accelerometerData_for_turning
            .map<Map<String, dynamic>>((data) => data.toJson())
            .toList();
      }
      List<Map<String, dynamic>> getGyroscopeJsonData_for_turning() {
        return  _gyroscopeData_for_turning.map<Map<String, dynamic>>((data) => data.toJson())
            .toList();}


      final gpsData = locations.map((data) => data.toJson()).toList();

      final accelerometerValues = getAccelerometerJsonData();
      final gyroscopeValues = getGyroscopeJsonData();

      final accelerometerValues_for_turning = getAccelerometerJsonData_or_turning();
      final gyroscopeValues_for_turning  = getGyroscopeJsonData_for_turning();

      var start_time=DateTime.now();
      current=(await BatteryInfoPlugin().androidBatteryInfo)?.currentNow;
      voltage=(await BatteryInfoPlugin().androidBatteryInfo)?.voltage;


      current_consumption=(voltage/1000)*(current/1000)*select_time;
      // print(current_consumption-initial_consumption);
      total_consumption=current_consumption-initial_consumption;
      var batt=(await BatteryInfoPlugin().androidBatteryInfo)?.batteryLevel;



      final requestBody = {
        'fname':file_name.text.trim(),
        'location':gpsData,
        'acc': accelerometerValues ,
        'gyro': gyroscopeValues,
        'acc_turning':accelerometerValues_for_turning,
        'gyro_turning':gyroscopeValues_for_turning,
        'start_time':start_time.toIso8601String(),
        'energy_consumption':total_consumption,
        'battery_percentage':batt
      };

      final response = await http.post(
        url,
        body: json.encode(requestBody),
        headers: {'Content-Type': 'application/json'},
      );
      apistatus=response.statusCode;

      if (response.statusCode == 200) {
        final requestBodyJson = json.encode(requestBody);
        final requestBodySize = utf8.encode(requestBodyJson).length;
        print('Request body size: $requestBodySize bytes');


        final responseJson = await json.decode(response.body);
        var endTime = DateTime.parse(responseJson);

        var timeDifference = endTime.difference(start_time);
        print('Time difference: ${timeDifference.inMilliseconds} ms');

        var bandwidthMbps = (requestBodySize * 8 / 1000000) / timeDifference.inSeconds;

        bandwidth=bandwidthMbps;


        var othersnackbar = SnackBar(
          content: Text('Data Sent Successfully'),
          backgroundColor: Color(0xff335F5E),
          shape: OutlineInputBorder(borderRadius: BorderRadius.circular(1)),
          duration: Duration(milliseconds: 2000),
          behavior: SnackBarBehavior.floating,
        );
        setState(() {
          ScaffoldMessenger.of(context).showSnackBar(othersnackbar);
        });
      } else {

        var othersnackbar = SnackBar(
          content: Text('Failed to send data. Error: ${response.statusCode}'),
          backgroundColor: Color(0xff335F5E),
          shape: OutlineInputBorder(borderRadius: BorderRadius.circular(1)),
          duration: Duration(milliseconds: 2000),
          behavior: SnackBarBehavior.floating,
        );
        setState(() {
          ScaffoldMessenger.of(context).showSnackBar(othersnackbar);
        });
      }

      if(identity==0){
        _accelerometerData.clear();
        _gyroscopeData.clear();
        getAccelerometerJsonData().clear();
        getGyroscopeJsonData().clear();
      }else{
        _accelerometerData_for_turning.clear();
        _gyroscopeData_for_turning.clear();
        getAccelerometerJsonData_or_turning().clear();
        getGyroscopeJsonData_for_turning().clear();

      }




    } on Exception catch (e) {
      var othersnackbar = SnackBar(
        content: Text('$e'),
        backgroundColor: Color(0xff335F5E),
        shape: OutlineInputBorder(borderRadius: BorderRadius.circular(1)),
        duration: Duration(milliseconds: 2000),
        behavior: SnackBarBehavior.floating,
      );
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(othersnackbar);
      });

    }

   // print("Current: ${(await BatteryInfoPlugin().androidBatteryInfo)?.currentNow}");
  //  print("Voltage: ${(await BatteryInfoPlugin().androidBatteryInfo)?.voltage}");

  }
  void checkAccelerometerSamplingRate() {
    int eventCount = 0;
    final startTime = DateTime.now();

    StreamSubscription<AccelerometerEvent>? subscription;

    subscription = accelerometerEvents.listen((AccelerometerEvent event) {
      eventCount++;

      final currentTime = DateTime.now();
      final elapsed = currentTime.difference(startTime).inMilliseconds;

      if (elapsed >= 1000) {
        final samplingRate = eventCount / (elapsed / 1000); // Divide by 1000 to get rate in Hz
        setState(() {
          acc_sampling=samplingRate;
        });
        print('Accelerometer Sampling Rate: $samplingRate Hz');
        subscription?.cancel();
      }
    });
  }
  void checkgyroSamplingRate () {
    int eventCount = 0;
    final startTime = DateTime.now();

    StreamSubscription<GyroscopeEvent>? subscription;

    subscription = gyroscopeEvents.listen((GyroscopeEvent event) {
      eventCount++;

      final currentTime = DateTime.now();
      final elapsed = currentTime.difference(startTime).inMilliseconds;

      if (elapsed >= 1000) {
        final samplingRate = eventCount / (elapsed / 1000); // Divide by 1000 to get rate in Hz
        setState(() {
          gyro_sampling=samplingRate;
        });
        subscription?.cancel();
      }
    });
  }

}