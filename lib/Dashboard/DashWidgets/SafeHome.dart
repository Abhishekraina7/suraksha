import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:location/location.dart';
import 'package:sms_advanced/sms_advanced.dart' as smsSender;
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gosecure/Dashboard/ContactScreens/phonebook_view.dart';

class SafeHome extends StatefulWidget {
  const SafeHome({required Key key}) : super(key: key);

  @override
  _SafeHomeState createState() => _SafeHomeState();
}

class _SafeHomeState extends State<SafeHome> {
  bool getHomeSafeActivated = false;
  List<String> numbers = [];
  var timer;

  checkGetHomeActivated() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      getHomeSafeActivated = prefs.getBool("getHomeSafe") ?? false;
    });
  }

  changeStateOfHomeSafe(value) async {
    if (value) {
      Fluttertoast.showToast(msg: "Service Activated in Background!");
    } else {
      Fluttertoast.showToast(msg: "Service Disabled!");
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      getHomeSafeActivated = value;
      prefs.setBool("getHomeSafe", value);
    });
  }

  @override
  void initState() {
    super.initState();
    checkGetHomeActivated();
    // if(getHomeSafeActivated){
    //   print("&&&&&&&&&&&&&&&&&&&*****************");
    //   Timer.periodic(Duration(seconds: 10), (Timer t) => sendPeriodicMsg());
    // }
  }

  sendPeriodicMsg() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> numbers = prefs.getStringList("numbers") ?? [];
    LocationData? myLocation;
    String error;
    Location location = Location();
    String link = '';
    try {
      myLocation = await location.getLocation();
      var currentLocation = myLocation;

      if (numbers.isEmpty) {
        return Fluttertoast.showToast(
          msg: 'No Contacts Found!',
          backgroundColor: Colors.red,
        );
      } else {
        //var coordinates =
        //    Coordinates(currentLocation.latitude, currentLocation.longitude);
        //var addresses =
        //    await Geocoder.local.findAddressesFromCoordinates(coordinates);
        // var first = addresses.first;
        String li =
            "http://maps.google.com/?q=${currentLocation.latitude},${currentLocation.longitude}";
        link = "I am on my way, track me here\n$li";
        for (int i = 0; i < numbers.length; i++) {
          sendSMS(numbers[i].split("***")[1], link);
        }
      }
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = 'Please grant permission';
        print('Error due to Denied: $error');
      }
      if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        error = 'Permission denied- please enable it from app settings';
        print("Error due to not Asking: $error");
      }
      myLocation = null;
    }
  }

  // void sendSMS(String number, String msgText) {
  //   print(number);
  //   print(msgText);
  //   smsSender.SmsMessage msg = new smsSender.SmsMessage(number, msgText);
  //   final smsSender.SmsSender sender = new smsSender.SmsSender();
  //   msg.onStateChanged.listen((state) {
  //     if (state == smsSender.SmsMessageState.Sending) {
  //       return Fluttertoast.showToast(
  //         msg: 'Sending Alert...',
  //         backgroundColor: Colors.blue,
  //       );
  //     } else if (state == smsSender.SmsMessageState.Sent) {
  //       return Fluttertoast.showToast(
  //         msg: 'Alert Sent Successfully!',
  //         backgroundColor: Colors.green,
  //       );
  //     } else if (state == smsSender.SmsMessageState.Fail) {
  //       return Fluttertoast.showToast(
  //         msg: 'Failure! Check your credits & Network Signals!',
  //         backgroundColor: Colors.red,
  //       );
  //     } else {
  //       return Fluttertoast.showToast(
  //         msg: 'Failed to send SMS. Please Wait!',
  //         backgroundColor: Colors.red,
  //       );
  //     }
  //   });
  //   sender.sendSms(msg);
  // }

  void sendSMS(String number, String msgText) {
    print(number);
    print(msgText);
    smsSender.SmsMessage msg = smsSender.SmsMessage(number, msgText);
    final smsSender.SmsSender sender = smsSender.SmsSender();

    msg.onStateChanged.listen((state) {
      if (state == smsSender.SmsMessageState.Sending) {
        Fluttertoast.showToast(
          msg: 'Sending Alert...',
          backgroundColor: Colors.blue,
        );
      } else if (state == smsSender.SmsMessageState.Sent) {
        Fluttertoast.showToast(
          msg: 'Alert Sent Successfully!',
          backgroundColor: Colors.green,
        );
      } else if (state == smsSender.SmsMessageState.Fail) {
        Fluttertoast.showToast(
          msg: 'Failure! Check your credits & Network Signals!',
          backgroundColor: Colors.red,
        );
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to send SMS. Please Wait!',
          backgroundColor: Colors.red,
        );
      }
    });

    sender.sendSms(msg);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
      child: InkWell(
        onTap: () {
          showModelSafeHome(getHomeSafeActivated);
        },
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            height: 180,
            width: MediaQuery.of(context).size.width * 0.7,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const ListTile(
                        title: Text("Get Home Safe"),
                        subtitle: Text("Share Location Periodically"),
                      ),
                      Visibility(
                        visible: getHomeSafeActivated,
                        child: const Padding(
                            padding: EdgeInsets.all(18.0),
                            child: Row(
                              children: [
                                SpinKitDoubleBounce(
                                  color: Colors.red,
                                  size: 15,
                                ),
                                SizedBox(width: 15),
                                Text("Currently Running...",
                                    style: TextStyle(
                                        color: Colors.red, fontSize: 10)),
                              ],
                            )),
                      ),
                    ],
                  ),
                ),
                ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      "assets/route.jpg",
                      height: 140,
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  showModelSafeHome(bool processRunning) async {
    int selectedContact = -1;
    bool getHomeActivated = processRunning;
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        enableDrag: true,
        isScrollControlled: true,
        isDismissible: true,
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Container(
                height: MediaQuery.of(context).size.height / 1.4,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        children: [
                          Expanded(
                              child: Divider(
                            indent: 20,
                            endIndent: 20,
                          )),
                          Text("Get Home Safe"),
                          Expanded(
                              child: Divider(
                            indent: 20,
                            endIndent: 20,
                          )),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: const Color(0xFFF5F4F6)),
                      child: SwitchListTile(
                        secondary: Lottie.asset("assets/routes.json"),
                        value: getHomeActivated,
                        onChanged: (val) async {
                          if (val && selectedContact == -1) {
                            Fluttertoast.showToast(
                                msg: "Please select one contact!");
                            return;
                          }
                          setModalState(() {
                            getHomeActivated = val;
                          });
                          if (getHomeActivated) {
                            changeStateOfHomeSafe(true);
                            timer = Timer.periodic(const Duration(minutes: 15),
                                (Timer t) => sendPeriodicMsg());
                          } else {
                            changeStateOfHomeSafe(false);
                            timer.cancel();
                            // await Workmanager().cancelByTag("3");
                          }
                        },
                        subtitle: const Text(
                            "Your location will be shared with one of your contacts every 15 minutes"),
                      ),
                    ),
                    Expanded(
                        child: FutureBuilder(
                            future: getSOSNumbers(),
                            builder: (context,
                                AsyncSnapshot<List<String>> snapshot) {
                              if (snapshot.hasData &&
                                  snapshot.data!.isNotEmpty) {
                                return ListView.separated(
                                    itemCount: snapshot.data!.length,
                                    separatorBuilder: (context, index) {
                                      return const Divider(
                                        indent: 20,
                                        endIndent: 20,
                                      );
                                    },
                                    itemBuilder: (context, index) {
                                      String contactData =
                                          snapshot.data![index];
                                      return ListTile(
                                        onTap: () {
                                          setModalState(() {
                                            selectedContact = index;
                                          });
                                        },
                                        leading: const CircleAvatar(
                                          backgroundImage:
                                              AssetImage("assets/user.png"),
                                        ),
                                        title:
                                            Text(contactData.split("***")[0]),
                                        subtitle:
                                            Text(contactData.split("***")[1]),
                                        trailing: selectedContact == index
                                            ? const Icon(
                                                Icons.check_circle,
                                                color: Colors.green,
                                              )
                                            : null,
                                      );
                                    });
                              } else {
                                return ListTile(
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const PhoneBook(),
                                      ),
                                    );
                                  },
                                  title: const Text("No contact found!"),
                                  subtitle:
                                      const Text("Please add atleast one Contact"),
                                  trailing: const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: Colors.grey),
                                );
                              }
                            }))
                  ],
                ),
              );
            },
          );
        });
  }

  Future<List<String>> getSOSNumbers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    numbers = prefs.getStringList("numbers") ?? [];

    return numbers;
  }
}
