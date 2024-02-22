// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qrcheck/core/extensions/l10n_exntesions.dart';
import 'package:qrcheck/database_helper.dart';
import 'package:qrcheck/firebase_helper.dart';
import 'package:qrcheck/main.dart';
import 'package:toast/toast.dart';

const int BG_CLR = 0xFF1E4F91;
bool _debugLocked = false;
DatabaseHelper db = DatabaseHelper();

class QRCodeScannerScreen extends StatefulWidget {
  const QRCodeScannerScreen({super.key});

  @override
  _QRCodeScannerScreenState createState() => _QRCodeScannerScreenState();
}

class _QRCodeScannerScreenState extends State<QRCodeScannerScreen> {
  late final GlobalKey qrKey = GlobalKey();
  late Barcode result;

  QRViewController? controller;

  @override
  Widget build(BuildContext context) {
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: const Color.fromARGB(255, 0, 110, 255),
        borderRadius: 10,
        borderLength: 35,
        borderWidth: 12,
        cutOutSize: 330,
      ),
    );
  }

  bool qrIdExist = false;
  bool derseKayitlimiyim = false;
  String email = "";
  String code = "";
  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    String email = (FirebaseAuth.instance.currentUser!.email) ?? "";
    bool cagrilmadi = true;

    controller.scannedDataStream.listen((scanData) async {
      if (!mounted) return; // Check if the widget is still mounted
      setState(() {
        result = scanData;
      });

      try {
        DateTime currentTime = DateTime.now();

        String lessonId = result.code.toString().split("-")[1];
        String lessonCode = result.code.toString().split("-")[3];
        String lessonQrId = result.code.toString().split("-")[5];
        List<String> doccode = result.code.toString().split("-");
        List<String> fruits;

        fruits = result.code.toString().split("-");
        code = fruits[3];
        await isQrExist(lessonQrId, doccode.sublist(0, 4).join("-"));
        await setUserEmail();
        await isUserExist(code, email);
        if (derseKayitlimiyim && mounted && qrIdExist) {
          controller.scanInvert(false);
          controller.stopCamera();
          FirebaseHelper.ddd = result.code.toString();
          FirebaseHelper.kaydet(email, result.code.toString());
          Navigator.popUntil(context, (route) {
            if (route.settings.name == '/') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CheckAuth()),
              );
              return true;
            }
            return false;
          });
          if (cagrilmadi) {
            db.insertLesson(lessonCode, currentTime, lessonId);
            showToast(context.translate.success_add);
          }
          cagrilmadi = false;
        } else {
          if (cagrilmadi) {
            controller.pauseCamera();
            showErrorMessage(context, context.translate.con_error,
                context.translate.time_qr, controller);
            cagrilmadi = false;
          }
        }
      } catch (e) {
        controller.pauseCamera();
        showErrorMessage(context, context.translate.con_error,
            context.translate.invalid_qr, controller);
      }
    });
  }

  Future<void> isQrExist(String qrId, String docId) async {
    FirebaseHelper firebaseHelper = FirebaseHelper();
    bool qrExists = await firebaseHelper.doesQRIdExist(qrId, docId);
    if (!mounted) return;

    setState(() {
      qrIdExist = qrExists;
    });
  }

  Future<void> isUserExist(String code, String mail) async {
    FirebaseHelper firebaseHelper = FirebaseHelper();
    bool userExists = await firebaseHelper.doesStudentExist(code, mail);
    if (!mounted) return;

    setState(() {
      derseKayitlimiyim = userExists;
    });
  }

  Future<void> setUserEmail() async {
    FirebaseHelper firebaseHelper = FirebaseHelper();
    email = (await firebaseHelper.getCurrUserEmail())!;
  }

  Future<String?> getCurrentUserEmail() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User? user = _auth.currentUser;

    if (user != null) {
      return user.email;
    } else {
      return null;
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
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

void showErrorMessage(BuildContext context, String title, String message,
    QRViewController controller) {
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
                  color: Colors.grey,
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
  ).then((value) {
    controller.resumeCamera();
  });
}

void showToast(String message) {
  Toast.show(message, duration: Toast.lengthLong, gravity: Toast.bottom);
}
