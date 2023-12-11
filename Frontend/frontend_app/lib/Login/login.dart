import 'package:flutter/material.dart';
import 'package:frontend_app/Welcome/welcome.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key, required this.title}) : super(key: key);
  final String title;

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
            Text("Username:"),
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: 8, 
                vertical: 16
              ),
              width: 400,
              height: 80,
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Type Username here',
                ),
              )
            ),
            Text("Password"),
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: 8, 
                vertical: 16
              ),
              width: 400,
              height: 80,
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Type Password here',
                ),
              )
            ),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const WelcomeScreen(title: 'Welcome Screen');
                }));
            },
              child: const Text('Next'),
            ),
            Spacer(),
          ],
        ),
      )
    );
  }
}
