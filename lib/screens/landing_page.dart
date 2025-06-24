import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  bool isLoggingIn = true;
  final String testEmail = "Johnny@example.com";

  final String testPassword = "testPass123";

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

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
                  prefixIcon: Icon(
                    Icons.email,
                    color: Colors.indigoAccent[700],
                  ),
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
                obscureText: true,
                style: TextStyle(
                  color: Colors.indigoAccent[700],
                  fontWeight: FontWeight.bold,
                ),
                controller: passwordController,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.password,
                    color: Colors.indigoAccent[700],
                  ),
                  suffixIcon: Icon(
                    Icons.visibility,
                    color: Colors.indigoAccent[700],
                  ),
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
            if (!isLoggingIn)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 25,
                ),
                child: TextField(
                  obscureText: true,
                  style: TextStyle(
                    color: Colors.indigoAccent[700],
                    fontWeight: FontWeight.bold,
                  ),
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.password,
                      color: Colors.indigoAccent[700],
                    ),
                    suffixIcon: Icon(
                      Icons.visibility,
                      color: Colors.indigoAccent[700],
                    ),
                    hintText: "Confim Password",
                    labelStyle: TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.purple[50],
                    border: OutlineInputBorder(
                      borderSide: BorderSide(width: 2.0, color: Colors.white),
                    ),
                  ),
                ),
              ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLoggingIn
                        ? "Don't have an account?"
                        : "Already have an account?",
                    style: TextStyle(color: Colors.black),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isLoggingIn = !isLoggingIn;
                      });
                      emailController.clear();
                      passwordController.clear();
                      confirmPasswordController.clear();
                    },
                    child: Text(
                      isLoggingIn ? "Sign up here" : "Log in here",
                      style: TextStyle(
                        color: Colors.purple[50],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
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
                  if (isLoggingIn) {
                    // Login flow
                    UserCredential userCredential = await FirebaseAuth.instance
                        .signInWithEmailAndPassword(
                          email: emailController.text,
                          password: passwordController.text,
                        );
                    print("Logged in: ${userCredential.user?.uid}");
                  } else {
                    // Signup flow
                    if (passwordController.text !=
                        confirmPasswordController.text.trim()) {
                      print("Passwords do not match.");
                      return;
                    }

                    UserCredential userCredential = await FirebaseAuth.instance
                        .createUserWithEmailAndPassword(
                          email: emailController.text,
                          password: passwordController.text,
                        );
                    print("User created: ${userCredential.user?.uid}");
                  }

                  // Navigate to TaskTracker if login/signup succeeds
                  context.go('/tasktracker');
                } on FirebaseAuthException catch (e) {
                  print("FirebaseAuth error: ${e.code}");
                }
              },
              child: Text(
                isLoggingIn ? "Log in" : "Sign up",
                style: TextStyle(color: Colors.indigoAccent[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
