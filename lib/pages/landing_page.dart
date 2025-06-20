import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final String testEmail = "Johnny@example.com";

  final String testPassword = "testPass123";

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

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
            SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 25),
              child: TextField(
                style: TextStyle(
                  color: Colors.indigoAccent[700],
                  fontWeight: FontWeight.bold,
                ),
                controller: emailController,
                decoration: InputDecoration(
                  hintText: "Email",
                  labelStyle: TextStyle(color: Colors.black),
                  filled: true,
                  fillColor: Colors.purple[50],
                  border: OutlineInputBorder(
                    borderSide: BorderSide(width: 2.0, color: Colors.white),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 25),
              child: TextField(
                style: TextStyle(
                  color: Colors.indigoAccent[700],
                  fontWeight: FontWeight.bold,
                ),
                controller: passwordController,
                decoration: InputDecoration(
                  hintText: "Password",
                  labelStyle: TextStyle(color: Colors.black),
                  filled: true,
                  fillColor: Colors.purple[50],
                  border: OutlineInputBorder(
                    borderSide: BorderSide(width: 2.0, color: Colors.white),
                  ),
                ),
              ),
            ),
            SizedBox(height: 25),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(150, 50),
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
                        email: emailController.text,
                        password: passwordController.text,
                      );
                  print("User created: ${userCredential.user?.uid}");
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'email-already-in-use') {
                    print("User already exists.");
                  } else {
                    print("FirebaseAuth error: ${e.code}");
                  }
                }
              },
              child: Text(
                "Sign Up",
                style: TextStyle(color: Colors.indigoAccent[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
