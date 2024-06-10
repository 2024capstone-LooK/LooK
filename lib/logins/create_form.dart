import 'package:flutter/material.dart';
import 'package:looook/logins/textformfield.dart';
import 'package:looook/logins/size.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class CreateForm extends StatefulWidget {
  @override
  _CreateFormState createState() => _CreateFormState();
}

class _CreateFormState extends State<CreateForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isEmailChecked = false;

  Future<void> _checkEmailAvailability() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      try {
        List<String> signInMethods =
            await _auth.fetchSignInMethodsForEmail(email);
        setState(() {
          _isEmailChecked = signInMethods.isEmpty; // 중복되지 않은 경우 true로 설정
        });
        // print(_isEmailChecked);
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content:
        //         Text(_isEmailChecked ? '사용 가능한 이메일입니다.' : '이미 등록된 이메일입니다.'),
        //   ),
        // );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'invalid-email') {
          print('올바른 이메일 형식이 아닙니다.');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('올바른 이메일 형식이 아닙니다.'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('이메일 확인 중 오류가 발생했습니다: ${e.toString()}'),
            ),
          );
        }
      }
    }
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      if (!_isEmailChecked) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('이메일 양식을 확인 해주세요.'),
          ),
        );
        return;
      }
      try {
        final credential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        print("User ${credential.user!.uid} created successfully!");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('회원가입 성공! 로그인을 진행해주세요. '),
          ),
        );
        Navigator.pushNamed(context, "/login");
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          print('비밀번호는 6자리 이상이어야 합니다.');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('비밀번호는 6자리 이상이어야 합니다.'),
            ),
          );
        } else if (e.code == 'email-already-in-use') {
          print('해당 이메일로 된 계정이 이미 존재합니다.');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('해당 이메일로 된 계정이 이미 존재합니다.'),
            ),
          );
        }
      } catch (e) {
        print('사용자 생성 중 오류 발생: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('사용자 생성 중 오류 발생: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextFormField("Email", controller: _emailController),
          TextButton(
            onPressed: _checkEmailAvailability,
            child: const Text('이메일 양식 확인'),
            style: TextButton.styleFrom(
              foregroundColor: Color(0x7FBEBEBE),
              textStyle: const TextStyle(
                fontSize: 13.0,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(height: medium_gap),
          CustomTextFormField("Password", controller: _passwordController),
          const SizedBox(height: medium_gap),
          TextButton(
            onPressed: _registerUser,
            child: const Text("완료"),
            style: TextButton.styleFrom(
              foregroundColor: Colors.indigo,
              textStyle: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
