import 'package:flutter/material.dart';
import 'package:looook/logins/textformfield.dart';
import 'package:looook/logins/size.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

FirebaseDatabase database = FirebaseDatabase.instance;

class PwForm extends StatelessWidget {
  final _formKey = GlobalKey<FormState>(); // 1. 글로벌 key
  final TextEditingController _emailController = TextEditingController();
  void _resetPassword(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(
          email: _emailController.text.trim(),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('비밀번호 재설정 이메일이 전송되었습니다.'),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('비밀번호 재설정 이메일 전송에 실패했습니다. ${e.toString()}'),
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
          CustomTextFormField("email", controller: _emailController),
          const SizedBox(height: medium_gap),
          TextButton(
            onPressed: () => _resetPassword(context),
            child: Text('비밀번호 재설정 이메일 전송'),
            style: TextButton.styleFrom(
                foregroundColor: Color(0x7FBEBEBE),
                textStyle: const TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.normal,
                )),
          ),
        ],
      ),
    );
  }
}
