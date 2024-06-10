import 'package:flutter/material.dart';
import 'package:looook/src/prestyle.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

FirebaseDatabase database = FirebaseDatabase.instance;

class Closet extends StatefulWidget {
  const Closet({Key? key}) : super(key: key);

  @override
  _ClosetState createState() => _ClosetState();
}

class _ClosetState extends State<Closet> {
  final List<String> choices = ['상의', '하의', '아우터', '신발', '잡화'];
  late final FirebaseAuth _auth;
  User? user;

  @override
  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;
    user = _auth.currentUser;
    if (user == null) {
      // 로그인 안되어 있으면 로그인 먼저 진행하도록 함.
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('로그인 먼저 진행해주세요'),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: choices.length,
      child: Scaffold(
        appBar: TabBar(
          labelColor: Colors.indigo,
          indicatorColor: Colors.indigo,
          overlayColor: MaterialStateProperty.all(Colors.indigo.shade50),
          tabs: choices.map((String choice) {
            return Tab(text: choice);
          }).toList(),
        ),
        body: TabBarView(
          children: choices.map((String choice) {
            return _buildTab(choice);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTab(String category) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("closet_per_user")
          .doc(user!.uid)
          .collection(category)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

        return GridView.count(
          crossAxisCount: 2,
          childAspectRatio: (170 / 270),
          padding: const EdgeInsets.all(15),
          crossAxisSpacing: 30,
          mainAxisSpacing: 30,
          children: List.generate(docs.length, (index) {
            String name = docs[index].id; // 문서의 이름
            String imageUrl = docs[index].get('imagelink'); // 이미지 링크

            return SizedBox(
              width: 170,
              height: 240,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        prestyle_pop(context, name, category);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          imageUrl,
                          width: 170,
                          height: 230,
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      _editName(context, category, name);
                    },
                    child: Text(
                      name, // 문서의 이름
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        color: Color(0xFF656565),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 0,
                        letterSpacing: 0.02,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  Future<void> _editName(
      BuildContext context, String category, String currentName) async {
    TextEditingController _nameController =
        TextEditingController(text: currentName);

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // 사용자가 dialog 바깥을 터치하여 닫을 수 없도록 함
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            '의상 이름 수정하기',
            style: TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: _nameController,
            decoration:
                const InputDecoration(hintText: "양식: [색상] [옷 종류] ex) 블루 셔츠"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('저장'),
              onPressed: () async {
                String newName = _nameController.text;
                if (newName.isNotEmpty) {
                  Navigator.of(context).pop();
                  await _updateName(category, currentName, newName);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateName(
      String category, String docId, String newName) async {
    DocumentReference docRef = FirebaseFirestore.instance
        .collection("closet_per_user")
        .doc(user!.uid)
        .collection(category)
        .doc(docId);

    DocumentSnapshot doc = await docRef.get();
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    await docRef.delete();

    await FirebaseFirestore.instance
        .collection("closet_per_user")
        .doc(user!.uid)
        .collection(category)
        .doc(newName)
        .set(data);
  }
}
