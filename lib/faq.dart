// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, constant_identifier_names

import 'package:flutter/material.dart';
import 'package:qrcheck/core/extensions/l10n_exntesions.dart';

const int BG_CLR = 0xFF1E4F91;

class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.translate.faq),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Icon(
                    Icons.info,
                    color: Color.fromARGB(255, 114, 114, 114),
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
                            text: "${context.translate.faq1}\n",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 17.0,
                                fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: context.translate.faq1_text,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Icon(
                    Icons.info,
                    color: Color.fromARGB(255, 114, 114, 114),
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
                            text: "${context.translate.faq2}\n",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 17.0,
                                fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: context.translate.faq2_text,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Icon(
                    Icons.info,
                    color: Color.fromARGB(255, 114, 114, 114),
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
                            text: "${context.translate.faq3}\n",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 17.0,
                                fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: context.translate.faq3_text,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
