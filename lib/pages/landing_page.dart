import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LandingPage extends StatelessWidget {
  final String testEmail = "Johnny@example.com";
  final String testPassword = "testPass123";
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigoAccent[700],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Task Tracker",
              style: TextStyle(
                color: Colors.purple[50],
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 50),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 50),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.indigo, width: 2),
                ),
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                try {
                  UserCredential userCredential = await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                        email: testEmail,
                        password: testPassword,
                      );
                  print("User created: ${userCredential.user?.uid}");
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'email-already-in-use') {
                    print("User already exists.");
                  } else {
                    print("FirebaseAuth error: ${e.code}");
                  }
                }
                Navigator.pushNamed(context, '/tasktracker');
              },
              child: Text(
                "Continue",
                style: TextStyle(color: Colors.indigoAccent[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
