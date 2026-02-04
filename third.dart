import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'fifth.dart';

class ThirdPage extends StatefulWidget {
  final String uid;
  final String parentName;
  final String email;

  const ThirdPage({
    super.key,
    required this.uid,
    required this.parentName,
    required this.email,
  });

  @override
  State<ThirdPage> createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ThirdPage> {
  final studentName = TextEditingController();
  final studentNumber = TextEditingController();
  final rollNumber = TextEditingController();
  final guardian1 = TextEditingController();
  final guardian2 = TextEditingController();

  Future<void> save() async {
    await FirebaseFirestore.instance
        .collection('students')
        .doc(widget.uid)
        .set({
      'parentName': widget.parentName,
      'email': widget.email,
      'studentName': studentName.text.trim(),
      'studentNumber': studentNumber.text.trim(),
      'rollNumber': rollNumber.text.trim(),
      'guardian1': guardian1.text.trim(),
      'guardian2': guardian2.text.trim(),
    });

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => FifthPage(),
      ),
    );
  }

  Widget field(String hint, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.grey.shade300,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ClipOval(
                child: Image.asset(
                  'assets/srm.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Student Details',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              field('Student Name', studentName),
              field('Student Number', studentNumber),
              field('Student Roll Number', rollNumber),
              field('Guardian 1 Number', guardian1),
              field('Guardian 2 Number', guardian2),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B3D2E)),
                  onPressed: save,
                  child: const Text('Next'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
