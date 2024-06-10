import 'package:flutter/material.dart';
import 'package:looook/logins/create_form.dart';
import 'package:looook/logins/size.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

FirebaseDatabase database = FirebaseDatabase.instance;

class CreateAccount extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  // CreateAccount({super.key});
  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                const SizedBox(height: small_gap),
                Center(
                  // 화면의 중앙에 배치
                  child: Stack(
                    alignment: Alignment.center, // Stack 내의 모든 자식들을 중앙에 배치
                    children: [
                      Image.asset(
                        'imgs/login_bubble.png',
                        width: 383,
                        height: 291,
                      ),
                      const Text(
                        'Create Account',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.40,
                        ),
                      ),
                    ],
                  ),
                ),
                CreateForm(),
              ],
            ),
          ),
        ));
  }
}
