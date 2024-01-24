import 'package:flutter/material.dart';
import 'package:frontend_app/login/login.dart';


class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Column(
          children: [
            Spacer(),
            Container(
              margin: const EdgeInsets.all(10),
              width: 300,
              height: 300,
              color: Colors.blueAccent,
              padding: const EdgeInsets.all(10),
              child: LoginForm(),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}


class LoginForm extends StatefulWidget{
  const LoginForm({super.key});

  @override
  _LoginFormState createState() {
    return _LoginFormState();
  }
} 

class _LoginFormState extends State<LoginForm> {
  final _formkey = GlobalKey<FormState>();
  final controllerUser = TextEditingController();
  final controllerPass = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formkey,
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Text('Username'),
          SizedBox(
            height: 10,
          ),
          TextFormField(
            decoration: InputDecoration(
              labelText: "Enter Username",
              border: OutlineInputBorder(

              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty){
                return "Please enter some text.";
              }
              return null;
            },
          ),
          SizedBox(
            height: 10,
          ),
          Text('Password'),
          SizedBox(
            height: 10,
          ),
          TextFormField(
            decoration: InputDecoration(
              labelText: "Enter Password",
              border: OutlineInputBorder(

              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty){
                return "Please enter some text.";
              }
              return null;
            },
          ),
          SizedBox(
            height: 10,
          ),
          ElevatedButton(
            onPressed: () {
              if (_formkey.currentState!.validate()){
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              }
            },
            child: const Text('Login'),
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  

}
