import 'package:flutter/material.dart';
import 'package:looook/logins/find_id_form.dart';
import 'package:looook/logins/size.dart';
import 'package:firebase_database/firebase_database.dart';

// 이거 잠시 보류
FirebaseDatabase database = FirebaseDatabase.instance;

class FindId extends StatefulWidget {
  const FindId({super.key});

  @override
  _FindIdState createState() => _FindIdState();
}

class _FindIdState extends State<FindId> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  String? _foundId; //db에서 찾은 ID 저장할 변수
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
                      child: Text('Find ID',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            height: 0,
                            letterSpacing: 0.40,
                          ))),
                ),
                const SizedBox(height: large_gap),
                IdForm(),
                const SizedBox(height: medium_gap),
                if (_foundId != null) // ID가 찾아지면
                  Positioned(
                    top: MediaQuery.of(context).size.height / 2 -
                        20, // 화면 중앙에 위치시키기 위해 조정
                    left: MediaQuery.of(context).size.width / 2 - 20,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(_foundId!,
                          style: const TextStyle(
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
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 100,
                      child: Center(
                        child: TextButton(
                          style: TextButton.styleFrom(
                              foregroundColor: Colors.indigo,
                              textStyle: const TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              )),
                          onPressed: () async {
                            // 3. 유효성 검사
                            if (_formKey.currentState!.validate()) {
                              // DB 조회 로직 대신 테스트 메시지 저장
                            }
                          },
                          child: const Text("Done"),
                        ),
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
