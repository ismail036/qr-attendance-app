// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, constant_identifier_names, use_key_in_widget_constructors, unused_local_variable, avoid_print, unused_import, unused_element, must_be_immutable

import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qrcheck/QRReader.dart';
import 'package:qrcheck/core/extensions/l10n_exntesions.dart';
import 'package:qrcheck/faq.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:qrcheck/firebase_helper.dart';
import 'package:qrcheck/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:toast/toast.dart';
import 'database_helper.dart';
import 'firebase_options.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:qrcheck/hesap.dart';
import 'package:qrcheck/student.dart';
import 'package:qrcheck/history.dart';
import 'package:path_provider/path_provider.dart';

String data = "";

const int BG_CLR = 0xFF1E4F91;
final FirebaseAuth _auth = FirebaseAuth.instance;

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    getDeviceId();
    loadStoredValues();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return PopScope(canPop: false, child: Scaffold(body: MyAppBody()));
  }
}

class MyAppBarPageOne extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(200.0);

  static String storedName = "";
  static String storedSurname = "";
  static String storedFaculty = "";
  static String storedDepartment = "";

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(BG_CLR),
      child: SafeArea(
        child: Wrap(
          children: [
            Column(
              children: [
                Container(
                  color: Color(BG_CLR),
                  width: MediaQuery.of(context).size.width,
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FaqPage(),
                              ),
                            );
                          },
                          child: Icon(
                            Icons.question_mark,
                            color: Color(BG_CLR),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HesapPage(),
                              ),
                            );
                          },
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                    ],
                  ),
                ),
                Container(
                  color: Color(BG_CLR),
                  width: MediaQuery.of(context).size.width,
                  height: 120,
                  child: Container(
                    alignment: Alignment.topCenter,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "${storedName} ${storedSurname} \n",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30.0,
                            ),
                          ),
                          TextSpan(
                            text: "${storedDepartment}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MyAppBody extends StatefulWidget {
  const MyAppBody({super.key});

  static String dd = "";

  @override
  State<MyAppBody> createState() => _MyAppBodyState();
}

class _MyAppBodyState extends State<MyAppBody> {
  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    PageOneBody(),
    PageTwoBody()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                color: Colors.black.withOpacity(.1),
              )
            ],
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            GNav(
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 8,
              activeColor: Colors.black,
              iconSize: 35,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              duration: Duration(milliseconds: 400),
              tabBackgroundColor: Color(0xFFE4E9EF),
              color: Colors.black,
              tabs: [
                GButton(
                  iconColor: Colors.grey,
                  iconActiveColor: Color(BG_CLR),
                  textColor: Color(BG_CLR),
                  icon: Icons.qr_code,
                  text: 'QR',
                ),
                GButton(
                  iconColor: Colors.grey,
                  iconActiveColor: Color(BG_CLR),
                  textColor: Color(BG_CLR),
                  icon: Icons.history,
                  text: context.translate.history,
                ),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ]),
        ),
      ),
    );
  }
}

class PageOneBody extends StatefulWidget {
  const PageOneBody({super.key});

  @override
  State<PageOneBody> createState() => _PageOneBodyState();
}

class _PageOneBodyState extends State<PageOneBody> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBarPageOne(),
      body: GestureDetector(
        onTap: () {
          FirebaseHelper.cagrildi = false;
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            showDragHandle: false,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
            builder: (BuildContext context) => DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.65,
              maxChildSize: 0.9,
              minChildSize: 0.32,
              builder: (context, scrollController) => Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _buildDragHandle(),
                  Text(
                    context.translate.scan_qr,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    context.translate.qr_align,
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Expanded(child: QRCodeScannerScreen())
                ],
              ),
            ),
          );
        },
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(
              Icons.qr_code_scanner,
              size: 150,
              color: Color(BG_CLR),
            ),
          ]),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                context.translate.for_read,
                style: TextStyle(color: Color(BG_CLR), fontSize: 15),
              )
            ],
          )
        ]),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      width: 50,
      height: 5,
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}

class MyAppBarPageTwo extends StatefulWidget implements PreferredSizeWidget {
  final VoidCallback onDeletePressed;
  final VoidCallback onSortPressed;

  MyAppBarPageTwo({required this.onDeletePressed, required this.onSortPressed});

  @override
  _MyAppBarPageTwoState createState() => _MyAppBarPageTwoState();

  @override
  Size get preferredSize => Size.fromHeight(180.0);
}

class _MyAppBarPageTwoState extends State<MyAppBarPageTwo> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Color(BG_CLR),
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.list),
        onPressed: () {
          widget.onSortPressed();
        },
      ),
      actions: [
        IconButton(
          onPressed: () {
            widget.onDeletePressed();
          },
          icon: Icon(Icons.delete),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          context.translate.history,
          style: TextStyle(fontSize: 30),
        ),
        centerTitle: true,
      ),
    );
  }
}

//////////////////////////

class PageTwoBody extends StatefulWidget {
  const PageTwoBody({super.key});

  @override
  State<PageTwoBody> createState() => _PageTwoBodyState();
}

List<History> historyList = [];

class _PageTwoBodyState extends State<PageTwoBody> {
  DatabaseHelper dbHelper = DatabaseHelper();

  void refreshPageTwoBody() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(context.translate.info),
          content: Text(context.translate.course_sure),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(context.translate.dismiss),
            ),
            TextButton(
              onPressed: () async {
                DatabaseHelper db = DatabaseHelper();
                await db.deleteAllLessons();
                setState(() {
                  Navigator.of(context).pop();
                });
              },
              child: Text(context.translate.delete),
            ),
          ],
        );
      },
    );
  }

  void sortHistory() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBarPageTwo(
        onDeletePressed: refreshPageTwoBody,
        onSortPressed: sortHistory,
      ),
      body: ScrollConfiguration(
        behavior: ScrollBehavior(),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: FutureBuilder<List<Row>>(
            future: getHistory(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(); // or any loading indicator
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                // Use the data from the snapshot
                List<Row> data = snapshot.data ?? [];
                return Column(
                  children: data,
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Future<List<Row>> getHistory() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    List<Map<String, dynamic>> lessonInfoList = await dbHelper.getAllLessons();

    historyList = [];
    for (Map<String, dynamic> lessonInfo in lessonInfoList) {
      History history = History(
          lessonCode: lessonInfo["lesson_code"],
          date: lessonInfo["lesson_date"],
          lessonId: lessonInfo["lesson_id"]);
      historyList.add(history);
    }

    List<Row> data = [];
    if (historyList.length > 0) {
      for (int i = 0; i < historyList.length; i++) {
        data.add(
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "${historyList[i].lessonCode} - ${historyList[i].lessonId}",
                    ),
                    Text(
                      historyList[i].date,
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      }
    } else {
      data.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 2,
              alignment: Alignment.center,
              child: Text(context.translate.rec_not_found),
            ),
          ],
        ),
      );
    }
    return data;
  }
}

void getDeviceId() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  try {
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      String deviceId = androidInfo.androidId;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      String deviceId = iosInfo.identifierForVendor;
    }
  } catch (e) {}
}

void loadStoredValues() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  MyAppBarPageOne.storedName = prefs.getString('name') ?? "";
  MyAppBarPageOne.storedSurname = prefs.getString('surname') ?? "";
  MyAppBarPageOne.storedFaculty = prefs.getString('faculty') ?? "";
  MyAppBarPageOne.storedDepartment = prefs.getString('department') ?? "";
}
