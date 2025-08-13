import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 6), () {
      Navigator.pushReplacementNamed(context, "/home");
    });
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Note icon with a creative design
            Stack(
              alignment: Alignment.topCenter,
              children: [
                Icon(
                  Icons.note_alt_rounded,
                  size: 100,
                  color: Colors.blue.shade400,
                ),
                Positioned(
                  top: 0,
                  child: Icon(
                    Icons.emoji_emotions,
                    size: 40,
                    color: Colors.orange.shade300,
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 0,
                  child: Transform.rotate(
                    angle: -0.3,
                    child: Icon(
                      Icons.emoji_objects,
                      size: 30,
                      color: Colors.yellow.shade700,
                    ), // lightbulb as a "hat"
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Text(
              "RongekaNotes",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Organize and manage your notes efficiently!",
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
