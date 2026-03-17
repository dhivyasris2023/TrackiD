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
  late Future<Map<String, dynamic>> studentFuture;
  DateTime selectedDate = DateTime.now();

  int scanCount = 0;

  String morningEntry = "--";
  String morningExit = "--";
  String eveningEntry = "--";
  String eveningExit = "--";

  @override
  void initState() {
    super.initState();
    studentFuture = fetchStudent();
    listenForScan(); // START LISTENING TO RFID SCANS
  }

  Future<Map<String, dynamic>> fetchStudent() async {
    final email = FirebaseAuth.instance.currentUser!.email!;
    final snap = await FirebaseFirestore.instance
        .collection('students')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) {
      throw Exception("Student record not found");
    }

    return snap.docs.first.data();
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

  // LISTEN TO FIREBASE SCANS
  void listenForScan() {
    FirebaseFirestore.instance
        .collection('scans')
        .doc('latest')
        .snapshots()
        .listen((snapshot) {

      if (!snapshot.exists) return;

      setState(() {

        scanCount++;

        String timeNow = TimeOfDay.now().format(context);

        if (scanCount == 1) {
          morningEntry = timeNow;
        } else if (scanCount == 2) {
          morningExit = timeNow;
        } else if (scanCount == 3) {
          eveningEntry = timeNow;
        } else if (scanCount == 4) {
          eveningExit = timeNow;
        }

      });

    });
  }

  @override
  Widget build(BuildContext context) {
    final timeNow = TimeOfDay.now().format(context);
    final dateNow =
        "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/srm.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text("TRACKiD"),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2023),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setState(() => selectedDate = picked);
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: studentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final data = snapshot.data!;
          final parentName = data['parentName'] ?? '—';
          final studentName = data['studentName'] ?? '—';
          final rollNumber = data['rollNumber'] ?? '—';

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Showing log of $studentName",
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text("Roll Number: $rollNumber"),
                        Text("Date: $dateNow"),
                        Text("Time: $timeNow"),
                      ],
                    ),
                    PopupMenuButton<int>(
                      icon: const Icon(Icons.person),
                      itemBuilder: (_) => <PopupMenuEntry<int>>[
                        PopupMenuItem<int>(
                          enabled: false,
                          child: Text("Parent: $parentName"),
                        ),
                        PopupMenuItem<int>(
                          enabled: false,
                          child: Text("Student: $studentName"),
                        ),
                        PopupMenuItem<int>(
                          enabled: false,
                          child: Text("Roll No: $rollNumber"),
                        ),
                        const PopupMenuDivider(),
                        PopupMenuItem<int>(
                          value: 1,
                          child: const Text("Logout"),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 1) logout();
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                _logCard(
                  title: " Morning Reporting Time:",
                  entry: morningEntry,
                  exit: morningExit,
                ),

                _logCard(
                  title: "Evening Reporting Time:",
                  entry: eveningEntry,
                  exit: eveningExit,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _logCard({
    required String title,
    required String entry,
    required String exit,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text("Entry Time: $entry"),
            Text("Exit Time: $exit"),
          ],
        ),
      ),
    );
  }
}
