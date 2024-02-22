// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, constant_identifier_names, use_key_in_widget_constructors, unused_local_variable, avoid_print, use_build_context_synchronously, unused_import, unused_element, library_private_types_in_public_api, unnecessary_null_comparison, unused_field

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'student.dart';

User? user = FirebaseAuth.instance.currentUser;
String email = FirebaseAuth.instance.currentUser?.email ?? '';

class FirebaseHelper {
  String name = "";
  String surname = "";
  String faculty = "";
  String department = "";

  static String ddd = "";
  static bool cagrildi = false;

  static void kaydet(String e, String c) {
    if (cagrildi == false) {
      cagrildi = true;
      looadToFirebase(e, c);
    }
  }

  static Future<void> looadToFirebase(String e, String c) async {
    try {
      List<dynamic> attendanceList = [];
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      List<String> doccode = c.toString().split("-");
      DocumentSnapshot documentSnapshot = await firestore
          .collection('attendance')
          .doc(doccode.sublist(0, 4).join("-"))
          .get();
      if (documentSnapshot.exists) {
        Map<String, dynamic> data = {
          'name': e,
          'time':
              "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}:${DateTime.now().second.toString().padLeft(2, '0')}",
        };

        attendanceList =
            List.from(documentSnapshot['attendance']); // Convert to list

        List<String> mailList = [];
        attendanceList.forEach((attendance) {
          mailList.add(attendance['name']);
        });

        if (mailList.contains(e) == false) {
          attendanceList.add(data);
        } else {} // Append map to list
      } else {}

      DocumentReference documentReference = firestore
          .collection('attendance')
          .doc(doccode.sublist(0, 4).join("-"));
      documentSnapshot = await documentReference.get();

      if (documentSnapshot.exists) {
        await documentReference.update({'attendance': attendanceList});
      } else {}
    } catch (e) {}
  }

  Future<void> fetchData(String e) async {
    try {
      var student = await getStudentById(e);
      if (student != null) {
        name = student.name;
        surname = student.surname;
        faculty = student.faculty;
        department = student.department;
      } else {}
    } catch (e) {}
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Student> getStudentById(String studentId) async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('students')
        .doc(studentId)
        .get();

    var studentData = documentSnapshot.data() as Map<String, dynamic>;
    Student student = Student.fromMap(studentData);
    return student;
  }

  Future<bool> doesStudentExist(String lessonCode, String studentId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('lesson')
              .where('code', isEqualTo: lessonCode)
              .where('id', isEqualTo: studentId)
              .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<bool> doesQRIdExist(String qrId, String docId) async {
    try {
      // Firestore bağlantısını al
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Belirli koleksiyon ve belge adı ile referans oluştur
      DocumentReference documentReference =
          firestore.collection("attendance").doc(docId);

      // Belge verilerini al
      DocumentSnapshot documentSnapshot = await documentReference.get();

      // qrId değerini al
      if (documentSnapshot.exists) {
        if (qrId == documentSnapshot["qrId"]) {
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<String?> getCurrUserEmail() async {
    try {
      // Firebase Auth nesnesini oluştur
      FirebaseAuth auth = FirebaseAuth.instance;

      // Mevcut kullanıcıyı al
      User? user = auth.currentUser;

      // Kullanıcı oturum açmışsa
      if (user != null) {
        // Kullanıcının e-posta adresini döndür
        return user.email;
      } else {
        // Oturum açmış bir kullanıcı bulunamadıysa null döndür
        return null;
      }
    } catch (e) {
      // Hata durumunda null döndür
      return null;
    }
  }

  Future<void> setStudent() async {
    Future<Student> studentFuture = getStudentById(email);
    Student student = await studentFuture;
    name = student.name;
    surname = student.surname;
    department = student.department;
    faculty = student.faculty;
  }
}
