import 'package:flutter/material.dart';
import 'package:looook/logins/textformfield.dart';
import 'package:looook/logins/size.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class LoginForm extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextFormField("Email", controller: _emailController),
          const SizedBox(height: medium_gap),
          CustomTextFormField("Password", controller: _passwordController),
          const SizedBox(height: medium_gap),
          TextButton(
            style: TextButton.styleFrom(
                foregroundColor: Colors.indigo,
                textStyle: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                )),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  UserCredential userCredential =
                      await _auth.signInWithEmailAndPassword(
                    email: _emailController.text.trim(),
                    password: _passwordController.text.trim(),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('로그인 성공!'),
                    ),
                  );
                  Navigator.pushNamed(context, "/");
                } on FirebaseAuthException catch (e) {
                  String errorMessage;
                  if (e.code == 'user-not-found') {
                    errorMessage = '회원가입되어있지 않습니다. 회원가입 먼저 진행해주세요. ';
                  } else if (e.code == 'wrong-password') {
                    errorMessage = '비밀번호가 일치하지 않습니다.';
                  } else {
                    errorMessage = '로그인 실패. 다시 로그인 해주세요.';
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(errorMessage)),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              }
            },
            child: const Text("Login"),
          ),
        ],
      ),
    );
  }
}
