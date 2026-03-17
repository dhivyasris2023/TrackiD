import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'fifth.dart';

class ThirdPage extends StatefulWidget {
  final String parentName;
  final String parentEmail;

  const ThirdPage({
    super.key,
    required this.parentName,
    required this.parentEmail,
  });

  @override
  State<ThirdPage> createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ThirdPage> {
  final studentCtrl = TextEditingController();
  final rollCtrl = TextEditingController();
  final numCtrl = TextEditingController();
  final g1Ctrl = TextEditingController();
  final g2Ctrl = TextEditingController();

  Future<void> saveStudent() async {
    if ([studentCtrl, rollCtrl, numCtrl, g1Ctrl, g2Ctrl]
        .any((c) => c.text.isEmpty)) {
      msg("Fill all fields");
      return;
    }

    final existing = await FirebaseFirestore.instance
        .collection('students')
        .where('rollNumber', isEqualTo: rollCtrl.text.trim())
        .get();

    if (existing.docs.isNotEmpty) {
      msg("Student with this roll number already exists");
      return;
    }

    await FirebaseFirestore.instance.collection('students').add({
      'parentName': widget.parentName,
      'email': widget.parentEmail,
      'studentName': studentCtrl.text.trim(),
      'rollNumber': rollCtrl.text.trim(),
      'studentNumber': numCtrl.text.trim(),
      'guardian1': g1Ctrl.text.trim(),
      'guardian2': g2Ctrl.text.trim(),
    });

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const FifthPage()),
    );
  }

  void msg(String t) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(t)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ✅ CLEAN CIRCULAR LOGO (IMAGE ONLY CHANGED)
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(45),
                  child: Image.asset(
                    'assets/srm.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              TextField(
                controller: studentCtrl,
                decoration:
                    const InputDecoration(labelText: "Student Name"),
              ),
              TextField(
                controller: rollCtrl,
                decoration:
                    const InputDecoration(labelText: "Roll Number"),
              ),
              TextField(
                controller: numCtrl,
                decoration:
                    const InputDecoration(labelText: "Student Number"),
              ),
              TextField(
                controller: g1Ctrl,
                decoration:
                    const InputDecoration(labelText: "Guardian 1"),
              ),
              TextField(
                controller: g2Ctrl,
                decoration:
                    const InputDecoration(labelText: "Guardian 2"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: saveStudent,
                child: const Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
