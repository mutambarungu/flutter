import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.blue.shade900],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height:20),

                  TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 1000),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, double value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, (1 - value) * -30),
                          child: child,
                        ),
                      );
                    },
                    child: Image.asset(
                      'assets/images/logoexpense1.png',
                      height: 250,
                      width: 250,
                    ),
                  ),

                  const SizedBox(height: 5),

                  // Welcome Text
                  const Text(
                    "BLAISE Expense Tracker App",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Description Text
                  const Text(
                    "This is a mobile application built with Flutter that helps you"
                    " to manage the finances by tracking your income and expenses.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, color: Colors.white70),
                  ),

                  const SizedBox(height: 30),

                  // Gift From Text
                  const Text(
                    "Developed by Blaise",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),

                  const SizedBox(height: 140),

                  // Animated Buttons
                  _buildAnimatedButton(
                    text: "Login",
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()));
                    },
                  ),
                  const SizedBox(height: 15),
                  _buildAnimatedButton(
                    text: "Sign Up",
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignupScreen()));
                    },
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedButton(
      {required String text, required VoidCallback onTap}) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 800),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: value,
            child: child,
          ),
        );
      },
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
          elevation: 5,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: onTap,
        child: Text(text,
            style: const TextStyle(
                color: Colors.blue, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
