// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, constant_identifier_names, use_key_in_widget_constructors, unused_local_variable, avoid_print, use_build_context_synchronously, unused_import, unused_element, library_private_types_in_public_api, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qrcheck/core/extensions/l10n_exntesions.dart';
import 'package:qrcheck/database_helper.dart';
import 'package:qrcheck/login.dart';
import 'package:qrcheck/main.dart';
import 'package:qrcheck/student.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_helper.dart';

class HesapPage extends StatefulWidget {
  const HesapPage({super.key});

  @override
  State<HesapPage> createState() => _HesapPageState();
}

String storedName = "";
String storedSurname = "";
String storedFaculty = "";
String storedDepartment = "";

class _HesapPageState extends State<HesapPage> {
  Future<void> loadStoredValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    storedName = prefs.getString('name') ?? "";
    storedSurname = prefs.getString('surname') ?? "";
    storedFaculty = prefs.getString('faculty') ?? "";
    storedDepartment = prefs.getString('department') ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: loadStoredValues(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return buildContent();
          }
        },
      ),
    );
  }

  Widget buildContent() {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.translate.account),
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  margin: EdgeInsets.only(left: 8.0),
                  child: Text(context.translate.name,
                      style: TextStyle(fontSize: 18)),
                ),
                Container(
                  margin: EdgeInsets.only(right: 8.0),
                  child: Text(storedName.toUpperCase(),
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 12)),
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Container(
                  margin: EdgeInsets.only(left: 8.0),
                  child: Text(context.translate.surname,
                      style: TextStyle(fontSize: 18)),
                ),
                Container(
                  margin: EdgeInsets.only(right: 8.0),
                  child: Text(storedSurname.toUpperCase(),
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 12)),
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Container(
                  margin: EdgeInsets.only(left: 8.0),
                  child: Text(context.translate.faculty,
                      style: TextStyle(fontSize: 18)),
                ),
                Container(
                  margin: EdgeInsets.only(right: 8.0),
                  child: Text(storedFaculty.toUpperCase(),
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 12)),
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Container(
                  margin: EdgeInsets.only(left: 8.0),
                  child: Text(context.translate.department,
                      style: TextStyle(fontSize: 18)),
                ),
                Container(
                  margin: EdgeInsets.only(right: 8.0),
                  child: Text(storedDepartment.toUpperCase(),
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 12)),
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),
            SizedBox(
              height: 15,
            ),
            SizedBox(
              width: 360,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent, elevation: 0),
                onPressed: () {
                  _showLogoutDialog(context);
                },
                child: Text(context.translate.exit,
                    style: TextStyle(color: Colors.blue)),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(context.translate.info),
          content: Text(context.translate.account_sure),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(context.translate.dismiss),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                await deleteValue();

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CheckAuth()),
                );
              },
              child: Text(context.translate.exit),
            ),
          ],
        );
      },
    );
  }
}

Future<void> deleteValue() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('name');
  await prefs.remove('surname');
  await prefs.remove('faculty');
  await prefs.remove('department');
}
