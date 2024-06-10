import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:looook/logins/size.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

FirebaseDatabase database = FirebaseDatabase.instance;

class Mypage extends StatefulWidget {
  @override
  _MypageState createState() => _MypageState();
}

class _MypageState extends State<Mypage> {
  final user = FirebaseAuth.instance.currentUser;
  File? _image;
  String? _imageUrl;
  bool _isLoading = false;
  final String _defaultProfileImage = 'profile/before_profile.png';

  @override
  void initState() {
    super.initState();
    if (user != null) {
      _loadProfileImage();
    }
  }

  Future<void> _loadProfileImage() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('profile_per_user')
          .doc(user!.uid)
          .get();
      if (doc.exists && doc.data() != null) {
        setState(() {
          _imageUrl = doc.data()!['imagelink'] as String?;
        });
      } else {
        setState(() {
          _imageUrl = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('프로필 이미지를 불러오는데 실패했습니다.'),
        ),
      );
    }
  }

  Future<void> getImage() async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await uploadImage();
    }
  }

  Future<void> uploadImage() async {
    if (_image == null || user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Firebase Storage에 이미지 업로드
      final storageRef =
          FirebaseStorage.instance.ref().child('profile/${user!.uid}.jpg');
      await storageRef.putFile(_image!);

      // 업로드된 이미지의 URL 가져오기
      final imageUrl = await storageRef.getDownloadURL();

      // Firestore에 이미지 URL 저장
      await FirebaseFirestore.instance
          .collection('profile_per_user')
          .doc(user!.uid)
          .set({'imagelink': imageUrl}, SetOptions(merge: true));

      setState(() {
        _imageUrl = imageUrl;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('이미지 업로드에 실패했습니다.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = user?.email ?? 'Guest';
    String userName = userEmail.split('@').first;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: ListView(
          children: [
            const SizedBox(height: medium_gap),
            Row(
              children: [
                const SizedBox(width: medium_gap),
                const Text(
                  'Profile',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                    height: 0.05,
                  ),
                ),
                const Spacer(),
                AuthButton(),
              ],
            ),
            const SizedBox(height: medium_gap),
            GestureDetector(
              onTap: () {
                if (user != null) {
                  getImage();
                }
              },
              child: Center(
                child: Stack(
                  children: [
                    ClipOval(
                      child: _isLoading
                          ? CircularProgressIndicator()
                          : _image == null
                              ? FutureBuilder<String>(
                                  future: _getProfileImageUrl(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    } else if (snapshot.hasError) {
                                      return Image.asset(
                                        'imgs/before_profile.png',
                                        width: 171,
                                        height: 171,
                                        fit: BoxFit.cover,
                                      );
                                    } else {
                                      return Image.network(
                                        snapshot.data!,
                                        width: 171,
                                        height: 171,
                                        fit: BoxFit.cover,
                                      );
                                    }
                                  },
                                )
                              : Image.file(
                                  _image!,
                                  width: 171,
                                  height: 171,
                                  fit: BoxFit.cover,
                                ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: medium_gap),
            Text(
              userName,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 23,
                fontWeight: FontWeight.w700,
                height: 0.05,
              ),
            ),
            const SizedBox(height: large_gap),
            Container(
              height: 1.0,
              color: Colors.black,
            ),
            const SizedBox(height: medium_gap),
            SettingsOption(
              icon: Icons.settings,
              text: '설정',
              onTap: () {
                Navigator.pushNamed(context, "/settings");
              },
            ),
            const SizedBox(height: medium_gap),
            Container(
              height: 1.0,
              color: Colors.black,
            ),
            const SizedBox(height: medium_gap),
            SettingsOption(
              icon: Icons.add_alert,
              text: '알림 설정',
              onTap: () {
                Navigator.pushNamed(context, "/notice");
              },
            ),
            const SizedBox(height: medium_gap),
            Container(
              height: 1.0,
              color: Colors.black,
            ),
            const SizedBox(height: medium_gap),
          ],
        ),
      ),
    );
  }

  Future<String> _getProfileImageUrl() async {
    if (_imageUrl != null) {
      return _imageUrl!;
    } else {
      // 기본 프로필 이미지 URL 가져오기
      final defaultRef =
          FirebaseStorage.instance.ref().child(_defaultProfileImage);
      return await defaultRef.getDownloadURL();
    }
  }
}

class SettingsOption extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const SettingsOption({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const SizedBox(width: medium_gap),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onTap,
            icon: Icon(
              icon,
              color: Colors.black,
              size: 30,
            ),
            label: Text(
              text,
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
              ),
            ),
            style: ButtonStyle(
              overlayColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.pressed)) {
                    return Colors.transparent;
                  }
                  return Colors.transparent;
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AuthButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return user == null
        ? TextButton(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF707070),
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.01,
              ),
            ),
            onPressed: () {
              Navigator.pushNamed(context, "/login");
            },
            child: const Text("로그인"),
          )
        : TextButton(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF707070),
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.01,
              ),
            ),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushNamed(context, "/login");
            },
            child: const Text("로그아웃"),
          );
  }
}
