import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'fourth.dart';

class FifthPage extends StatefulWidget {
  const FifthPage({super.key});

  @override
  State<FifthPage> createState() => _FifthPageState();
}

class _FifthPageState extends State<FifthPage> {
  DateTime now = DateTime.now();
  DateTime selectedDate = DateTime.now();
  Timer? timer;

  String parentName = '';
  String studentName = '';
  String rollNumber = '';

  @override
  void initState() {
    super.initState();
    loadData();

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => now = DateTime.now());
    });
  }

  Future<void> loadData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection('students')
        .doc(uid)
        .get();

    setState(() {
      parentName = doc['parentName'];
      studentName = doc['studentName'];
      rollNumber = doc['rollNumber'];
    });
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Widget logBox(String title, String entry, String exit) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Entry Time:\n$entry'),
          const SizedBox(height: 6),
          Text('Exit Time:\n$exit'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            ClipOval(
              child: Image.asset(
                'assets/srm.png',
                width: 36,
                height: 36,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'TRACKiD',
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.black),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setState(() => selectedDate = picked);
              }
            },
          ),
          PopupMenuButton(
            icon: const Icon(Icons.person, color: Colors.black),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Parent: $parentName'),
              ),
              PopupMenuItem(
                child: Text('Roll No: $rollNumber'),
              ),
              PopupMenuItem(
                onTap: logout,
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
            ),
            const SizedBox(height: 4),
            Text(
              now.toLocal().toString().split('.')[0],
            ),
            const SizedBox(height: 14),
            Text(
              'Showing log of $studentName',
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            logBox(
              'Results of morning:',
              'Your ward has entered the bus at 8:00 AM',
              'Your ward has exited the bus at 8:35 AM',
            ),
            logBox(
              'Results of evening:',
              'Your ward has entered the bus at 4:03 PM',
              'Your ward has exited the bus at 5:20 PM',
            ),
          ],
        ),
      ),
    );
  }
}
