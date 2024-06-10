import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:looook/src/prestyle.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Recommend extends StatefulWidget {
  const Recommend({Key? key}) : super(key: key);

  @override
  State<Recommend> createState() => _RecommendState();
}

class _RecommendState extends State<Recommend> {
  late final FirebaseAuth _auth;
  User? user;

  // 상태 관리를 위한 변수들
  int _indexTop = 0;
  int _indexOuter = 0;
  int _indexBottom = 0;
  int _indexShoes = 0;

  @override
  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;
    user = _auth.currentUser;
    if (user == null) {
      // 로그인 안되어 있으면 로그인 먼저 진행하도록 함.
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그인 먼저 진행해주세요'),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      physics: const ScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: (210 / 380),
      padding: const EdgeInsets.all(15),
      crossAxisSpacing: 40,
      mainAxisSpacing: 20,
      children: <Widget>[
        _buildCategoryWidget('상의', _indexTop, (newIndex) {
          setState(() {
            _indexTop = newIndex;
          });
        }),
        _buildCategoryWidget('아우터', _indexOuter, (newIndex) {
          setState(() {
            _indexOuter = newIndex;
          });
        }),
        _buildCategoryWidget('하의', _indexBottom, (newIndex) {
          setState(() {
            _indexBottom = newIndex;
          });
        }),
        _buildCategoryWidget('신발', _indexShoes, (newIndex) {
          setState(() {
            _indexShoes = newIndex;
          });
        }),
      ],
    );
  }

  Widget _buildCategoryWidget(
      String category, int currentIndex, ValueChanged<int> onRefresh) {
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
          return CircularProgressIndicator();
        }

        List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return Center(child: Text('No data available'));
        }

        var randomIndex = currentIndex < docs.length ? currentIndex : 0;

        String name = docs[randomIndex].id; // 문서의 이름
        String imageUrl = docs[randomIndex].get('imagelink'); // 이미지 링크

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
              const SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.01,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          name,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF656565),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.02,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 31,
                    height: 30,
                    child: IconButton(
                      onPressed: () {
                        var newIndex = Random().nextInt(docs.length);
                        onRefresh(newIndex);
                      },
                      icon: const Icon(Icons.autorenew),
                      iconSize: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
