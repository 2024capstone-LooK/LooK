import 'package:flutter/material.dart';
import 'package:looook/logins/textformfield.dart';
import 'package:looook/logins/size.dart';
import 'package:firebase_database/firebase_database.dart';

FirebaseDatabase database = FirebaseDatabase.instance;

class IdForm extends StatelessWidget {
  final _formKey = GlobalKey<FormState>(); // 1. 글로벌 key
  final TextEditingController _emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextFormField(
            "Email",
            controller: _emailController,
          ),
        ],
      ),
    );
  }
}
