import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

FirebaseDatabase database = FirebaseDatabase.instance;

Future<void> prestyle_pop(
    BuildContext context, String clothingName, String category) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('로그인 먼저 진행해주세요'),
      ),
    );
    return;
  }

  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection("closet_per_user")
      .doc(user.uid)
      .collection(category)
      .get();

  List<String> urls = [];
  List<String> dates = [];

  // 색상 목록
  List<String> knownColors = [
    '블랙',
    '검정',
    '화이트',
    '레드',
    '블루',
    '그린',
    '옐로',
    '퍼플',
    '핑크',
    '브라운',
    '그레이',
    '오렌지',
    '베이지',
    '네이비',
    '갈색',
    '연두색',
    '노란색',
    '챠콜',
    '크림색',
    '짙은 청색',
    '딥 블루',
    '다크 그린',
    '실버',
    '골드',
    '다크 블루',
    '라이트 블루',
    '앨리스블루',
    '앤티크화이트',
    '아쿠아',
    '아쿠아마린',
    '애저',
    '비스크',
    '블랜치드아몬드',
    '블루바이올렛',
    '벌리우드',
    '캐딧블루',
    '샤르트뢰즈',
    '초콜릿',
    '코랄',
    '콘플라워블루',
    '콘실크',
    '크림슨',
    '시안',
    '다크 시안',
    '다크 골든로드',
    '다크 카키',
    '다크 마젠타',
    '다크 올리브그린',
    '다크 오렌지',
    '다크 오키드',
    '다크 레드',
    '다크 살몬',
    '다크 시그린',
    '다크 슬레이트블루',
    '다크 슬레이트그레이',
    '다크 터쿼이즈',
    '다크 바이올렛',
    '딥 핑크',
    '딥스카이블루',
    '딤그레이',
    '도저블루',
    '파이어브릭',
    '플로럴화이트',
    '포레스트그린',
    '퓨시아',
    '게인스보로',
    '고스트화이트'
  ];

  // 색상과 이름 분리
  String targetColor = '';
  String targetName = clothingName;

  for (String color in knownColors) {
    if (clothingName.startsWith(color)) {
      targetColor = color;
      targetName = clothingName.substring(color.length).trim();
      print("원래 옷 이름");
      print(targetColor);
      print(targetName);
      break;
    }
  }

  snapshot.docs.forEach((doc) {
    try {
      String name = doc.id;
      String itemColor = '';

      for (String color in knownColors) {
        if (name.startsWith(color)) {
          itemColor = color;
          //itemName = name.substring(color.length).trim();
          print("DB에서 받아온 이름");
          print(itemColor);
          // print(itemName);
          break;
        }
      }

      // 색상이 같거나 이름이 같은 경우
      if (itemColor == targetColor) {
        urls.add(doc.get('imagelink') ?? '');
        dates.add(doc.get('recent_ware_date') ?? '');
        print("일치하는 색상!");
        print("$targetColor , $itemColor");
      }
    } catch (e) {
      print('Error processing document: ${doc.id}, error: $e');
    }
  });

  if (urls.isEmpty || dates.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('유사한 이름의 항목을 찾을 수 없습니다.'),
      ),
    );
    return;
  }

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 30,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                clothingName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 0.5,
                crossAxisSpacing: 0.5,
                childAspectRatio: (140 / 200),
              ),
              itemCount: urls.length,
              itemBuilder: (context, index) => SizedBox(
                width: 140,
                height: 200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        urls[index],
                        width: 140,
                        height: 180,
                        fit: BoxFit.fill,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    SizedBox(
                      child: Text(
                        dates[index],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF656565),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          height: 0,
                          fontFamily: 'Roboto',
                          letterSpacing: 0.02,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
