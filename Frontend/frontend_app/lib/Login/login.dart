import 'package:flutter/material.dart';
import 'package:frontend_app/Welcome/welcome.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Company'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Column(
          children: [
            Spacer(),
            Text("Company Detail"),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const WelcomeScreen();
                }));
              },
              child: const Text('Back to Home screen'),
            ),
            Spacer(),
          ],
        ),
      )
    );
  }
}
