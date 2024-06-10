import 'package:flutter/material.dart';
import 'package:looook/logins/login_form.dart';
import 'package:looook/logins/size.dart';
import 'package:firebase_database/firebase_database.dart';

FirebaseDatabase database = FirebaseDatabase.instance;

class Login extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  Login({super.key});
  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                const SizedBox(height: medium_gap),
                const SizedBox(height: small_gap),
                Stack(children: [
                  Image.asset(
                    'imgs/login_bubble.png',
                    width: 383,
                    height: 291,
                  ),
                  const Positioned(
                    left: 145,
                    top: 110,
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                        height: 0,
                        letterSpacing: 0.40,
                      ),
                    ),
                  ),
                ]),
                LoginForm(),
                const SizedBox(height: medium_gap),
                const SizedBox(height: small_gap),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Positioned(
                    child: TextButton(
                      style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF707070),
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.01,
                          )),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.pushNamed(context, "/find_pw");
                        }
                      },
                      child: const Text("비밀번호 찾기"),
                    ),
                  ),
                  const SizedBox(width: large_gap),
                  const Positioned(
                    child: SizedBox(
                      child: Text(
                        '|',
                        style: TextStyle(
                          color: Color(0xFF707070),
                          fontSize: 13,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          height: 0,
                          letterSpacing: 0.01,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: large_gap),
                  Positioned(
                    child: TextButton(
                      style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF707070),
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.01,
                          )),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.pushNamed(context, "/create_account");
                        }
                      },
                      child: const Text("회원가입 하러가기"),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ));
  }
}
