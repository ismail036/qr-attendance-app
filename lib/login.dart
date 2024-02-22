// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, constant_identifier_names, use_key_in_widget_constructors, unused_local_variable, avoid_print, use_build_context_synchronously, unused_import, unused_element, library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:qrcheck/faq.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_helper.dart';
import 'firebase_options.dart';
import 'package:qrcheck/main_page.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:qrcheck/core/extensions/l10n_exntesions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:device_info/device_info.dart';
import 'dart:io';

const int BG_CLR = 0xFF1E4F91;
final FirebaseAuth _auth = FirebaseAuth.instance;
String selectedOption = 'Öğrenci';
bool showErrorAnimation = true;
bool isLoading = false;
bool firstLoad = false;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: MyAppBar(),
        body: MyAppBody(),
      ),
    );
  }
}

class MyAppBody extends StatefulWidget {
  const MyAppBody({super.key});

  @override
  State<MyAppBody> createState() => _MyAppBodyState();
}

class _MyAppBodyState extends State<MyAppBody> {
  final TextEditingController _emailget = TextEditingController();
  final TextEditingController _passwordget = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (!firstLoad) {
      selectedOption = context.translate.student;
      firstLoad = !firstLoad;
    }
    return Scaffold(
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            Center(
              child: Image.asset(
                context.translate.logo,
                height: 140,
                width: 140,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 3),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: context.translate.user_name,
                  suffixText: setSuffixText(context),
                  prefixIcon: Icon(Icons.person),
                ),
                controller: _emailget,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 3),
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: context.translate.password,
                  prefixIcon: Icon(Icons.password),
                ),
                controller: _passwordget,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(
                    right: 20), // Add padding only from the right
                child: DropdownButton<String>(
                  value: selectedOption,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedOption = newValue!;
                    });
                  },
                  items: <String>[
                    context.translate.student,
                    context.translate.academician
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  icon: Icon(Icons.school_outlined, color: Color(BG_CLR)),
                  style: TextStyle(color: Colors.black),
                  underline: Container(),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 3),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_emailget.text == '' || _passwordget.text == '') {
                      showErrorMessage(context, context.translate.con_error,
                          context.translate.login_check);
                    } else {
                      _signIn(context, _emailget.text, _passwordget.text);
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Color(BG_CLR)),
                  ),
                  child: Text(
                    context.translate.login,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(
                    right: 20), // Add padding only from the right
                child: TextButton(
                  onPressed: () {
                    _openGoogle(
                        "https://qrcheck-password-reset.s3.amazonaws.com/main.html");
                  },
                  child: Text(context.translate.reset_password),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(
                    right: 20), // Add padding only from the right
                child: TextButton(
                  onPressed: () {
                    _openGoogle(
                        "https://device-reset.s3.amazonaws.com/main.html");
                  },
                  child: Text(context.translate.reset_device),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

_openGoogle(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(140.0);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: preferredSize.height,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius:
                    20.0, // Increase the blur radius for a larger shadow
                offset: Offset(0, 15), // Adjust the offset for shadow placement
              ),
            ],
          ),
        ),
        ClipPath(
          clipper: CustomAppBarShape(),
          child: Container(
            color: Colors.white,
            child: AppBar(
              automaticallyImplyLeading: false,
              titleSpacing: 40,
              centerTitle: true,
              toolbarHeight: 130.0,
              actions: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FaqPage()),
                    );
                  },
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Icon(
                        Icons.question_mark,
                        color: Color(BG_CLR),
                      ),
                    ),
                  ),
                ),
              ],
              title: Container(
                alignment: Alignment.center,
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "${context.translate.header}\n",
                        style: TextStyle(
                          color: Colors.white, // Set text color as needed
                          fontSize: 30.0,
                        ),
                      ),
                      TextSpan(
                        text: "${context.translate.sub_header}\n",
                        style: TextStyle(
                          color: Colors.white, // Set text color as needed
                          fontSize: 15.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CustomAppBarShape extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const curveHeight = 20.0;
    final path = Path()
      ..moveTo(0, size.height - curveHeight)
      ..quadraticBezierTo(
          size.width / 2, size.height, size.width, size.height - curveHeight)
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

void showErrorMessage(BuildContext context, String title, String message) {
  _closeKeyboard(context);
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return SafeArea(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 30,
                ),
              ),
              Flexible(
                child: Container(
                  padding: EdgeInsets.only(right: 10),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "$title\n",
                          style: TextStyle(color: Colors.black, fontSize: 18.0),
                        ),
                        TextSpan(
                          text: message,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void _closeKeyboard(BuildContext context) {
  FocusScope.of(context).requestFocus(FocusNode());
}

String setSuffixText(BuildContext context) {
  if (selectedOption == context.translate.student) {
    return "@st.biruni.edu.tr";
  }
  return "@biruni.edu.tr";
}

/// ************

class CustomSpinKitThreeBounce extends StatefulWidget {
  @override
  _CustomSpinKitThreeBounceState createState() =>
      _CustomSpinKitThreeBounceState();
}

class _CustomSpinKitThreeBounceState extends State<CustomSpinKitThreeBounce>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);

    _colorAnimation = ColorTweenSequence(
      [
        ColorTweenSequenceItem(1, Colors.blue),
        ColorTweenSequenceItem(2, Colors.blue.shade900),
        ColorTweenSequenceItem(3, Colors.orange),
      ],
    ).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SpinKitThreeBounce(
          color: _colorAnimation.value,
          size: 50.0,
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class ColorTweenSequenceItem {
  final double weight;
  final Color color;

  ColorTweenSequenceItem(this.weight, this.color);
}

class ColorTweenSequence extends TweenSequence<Color?> {
  ColorTweenSequence(List<ColorTweenSequenceItem> items)
      : super(
          items
              .map((item) => TweenSequenceItem(
                    tween: ColorTween(begin: item.color, end: item.color),
                    weight: item.weight,
                  ))
              .toList(),
        );
}

FirebaseHelper firebaseHelper = FirebaseHelper();

void _signIn(BuildContext context, email, String password) async {
  List<String> allIds = await getAllIds();
  String convertedString = "";
  bool doesDocumentExist =
      await checkDocumentExists(email + setSuffixText(context));
  getDeviceId().then((result) async {
    convertedString = result;
    if (doesDocumentExist == false) {
      if (allIds.contains(result) == false) {
        createDocument(email + setSuffixText(context), result);
        try {
          showLoading(context);
          final credential =
              await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: "$email${setSuffixText(context)}",
            password: password,
          );

          await firebaseHelper.fetchData(email + setSuffixText(context));
          saveValues();
          loadStoredValues();

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MainPage()),
          );
        } on FirebaseAuthException catch (e) {
          if (e.code == 'user-not-found') {
            Navigator.of(context).pop();
            showErrorMessage(context, context.translate.con_error,
                context.translate.info_check);
          } else if (e.code == 'Wrong password') {
            Navigator.of(context).pop();
            showErrorMessage(context, context.translate.con_error,
                context.translate.info_check);
          } else {
            Navigator.of(context).pop();
            showErrorMessage(context, context.translate.con_error, e.code);
          }
        }
      } else {
        showErrorMessage(
            context, context.translate.con_error, context.translate.con_id);
      }
    } else {
      String? idValue = "";
      idValue = await getIdForDocument(email + setSuffixText(context));
      if (idValue == convertedString) {
        try {
          showLoading(context);
          final credential =
              await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: "$email${setSuffixText(context)}",
            password: password,
          );

          await firebaseHelper.fetchData(email + setSuffixText(context));
          saveValues();
          loadStoredValues();

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MainPage()),
          );
        } on FirebaseAuthException catch (e) {
          if (e.code == 'user-not-found') {
            Navigator.of(context).pop();
            showErrorMessage(context, context.translate.con_error,
                context.translate.info_check);
          } else if (e.code == 'Wrong password') {
            Navigator.of(context).pop();
            showErrorMessage(context, context.translate.con_error,
                context.translate.info_check);
          } else {
            Navigator.of(context).pop();
            showErrorMessage(context, context.translate.con_error, e.code);
          }
        }
      } else {
        showErrorMessage(
            context, context.translate.con_error, context.translate.con_id);
      }
    }
  });
}

void saveValues() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('name', firebaseHelper.name);
  prefs.setString('surname', firebaseHelper.surname);
  prefs.setString('faculty', firebaseHelper.faculty);
  prefs.setString('department', firebaseHelper.department);
}

void loadStoredValues() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  MyAppBarPageOne.storedName = prefs.getString('name') ?? "";
  MyAppBarPageOne.storedSurname = prefs.getString('surname') ?? "";
  MyAppBarPageOne.storedFaculty = prefs.getString('faculty') ?? "";
  MyAppBarPageOne.storedDepartment = prefs.getString('department') ?? "";
}

void showLoading(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [CustomSpinKitThreeBounce()],
          ),
        ),
      );
    },
  );
}

Future<String> getDeviceId() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String deviceId = "";
  try {
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceId = androidInfo.androidId;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor;
    }
  } catch (e) {}
  return deviceId;
}

void createDocument(String mail, String id) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference devicesCollection = firestore.collection('devicesID');
  try {
    await devicesCollection.doc(mail).set({
      'id': id,
    });
  } catch (e) {}
}

Future<bool> checkDocumentExists(String documentId) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference devicesCollection = firestore.collection('devicesID');
  DocumentSnapshot documentSnapshot =
      await devicesCollection.doc(documentId).get();
  return documentSnapshot.exists;
}

Future<String?> getIdForDocument(String documentId) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference devicesCollection = firestore.collection('devicesID');
  try {
    DocumentSnapshot documentSnapshot =
        await devicesCollection.doc(documentId).get();
    if (documentSnapshot.exists) {
      Map<String, dynamic> data =
          documentSnapshot.data() as Map<String, dynamic>;
      String? idValue = data['id'] as String?;
      return idValue;
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}

Future<List<String>> getAllIds() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference devicesCollection = firestore.collection('devicesID');

  try {
    QuerySnapshot querySnapshot = await devicesCollection.get();

    // Tüm dokümanlardan id'leri içeren bir liste oluştur
    List<String> idList = [];

    querySnapshot.docs.forEach((DocumentSnapshot documentSnapshot) {
      Map<String, dynamic> data =
          documentSnapshot.data() as Map<String, dynamic>;
      String? idValue = data['id'] as String?;

      if (idValue != null) {
        idList.add(idValue);
      }
    });

    return idList;
  } catch (e) {
    return [];
  }
}
