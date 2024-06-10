import 'package:flutter/material.dart';
import 'package:looook/logins/find_pw_form.dart';
import 'package:looook/logins/size.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

//비밀번호 다시 설정
FirebaseDatabase database = FirebaseDatabase.instance;

class FindPw extends StatefulWidget {
  @override
  _FindPwState createState() => _FindPwState();
}

class _FindPwState extends State<FindPw> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  String? _foundPw; //db에서 찾은 PW 저장할 변수
  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                const SizedBox(height: xlarge_gap),
                const SizedBox(height: large_gap),
                const Positioned(
                  child: Align(
                      alignment: Alignment.center,
                      child: Text('Find PW',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            height: 0,
                            letterSpacing: 0.40,
                          ))),
                ),
                const SizedBox(height: large_gap),
                PwForm(),
                const SizedBox(height: medium_gap),
                if (_foundPw != null) // ID가 찾아지면
                  Positioned(
                    top: MediaQuery.of(context).size.height / 2 -
                        20, // 화면 중앙에 위치시키기 위해 조정
                    left: MediaQuery.of(context).size.width / 2 - 20,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(_foundPw!,
                          style: TextStyle(
                            fontSize: 14,
                          )),
                    ),
                  ),
                Stack(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Image.asset(
                        'imgs/find_bubble.png',
                        width: 324,
                        height: 293,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
