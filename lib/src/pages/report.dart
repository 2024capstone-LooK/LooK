import 'package:flutter/material.dart';
import 'package:looook/src/chat/timeLine.dart';
import 'package:looook/src/chat/otherchat.dart';
import 'package:looook/src/chat/otherchat_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:flutter_markdown/flutter_markdown.dart';


FirebaseDatabase database = FirebaseDatabase.instance;
final db = FirebaseFirestore.instance;

class Report extends StatefulWidget {
  const Report({super.key});

  @override
  _ReportState createState() => _ReportState();
}

class _ReportState extends State<Report> {
  int _lenthValue = 0;
  String thismonth = "";
  String userId = "";
  String userName = "";
  String nowyear = "";
  String nowmonth = "";
  String nowday = "";
  String nowEEEE = "";
  String marker_per_day = '';
  String styles_per_day = '';
  String keywords_per_day = '';
  //아우터
  String _outerName = '';
  String _outerimageLink = '';
  int _outertimes = 0;
  bool _isLoading = true;
  //상의 
  String _topName = '';
  String _topimageLink = '';
  int _toptimes = 0;
  //하의
  String _bottomName = '';
  String _bottomimageLink = '';
  int _bottomtimes = 0;
  //신발
  String _shoesName = '';
  String _shoesimageLink = '';
  int _shoestimes = 0;
  //잡화
  String _accName = '';
  String _accimageLink = '';
  int _acctimes = 0;


  @override
  void initState() {
    super.initState();
    fetchlength();
    _fetchMostWornOuter();
    _fetchMostWornTop();
    _fetchMostWornBottom();
    _fetchMostWornShoes();
    _fetchMostWornAcc();
    _fetchKeyword();
    _fetchMarker();
    _fetchStyles();
  }

  Future<void> fetchlength() async {
   try {
    final user = FirebaseAuth.instance.currentUser;
    final userEmail = user?.email ?? 'Guest';
    userName = userEmail.split('@').first;

    userId = user!.uid;
    thismonth = DateFormat('yyyy.MM', 'ko_KR').format(DateTime.now()).toString();
    nowyear = DateFormat('yyyy', 'ko_KR').format(DateTime.now()).toString();
    nowmonth= DateFormat('MM', 'ko_KR').format(DateTime.now()).toString();
    nowday = DateFormat('dd', 'ko_KR').format(DateTime.now()).toString();
    nowEEEE = DateFormat('EEEE', 'ko_KR').format(DateTime.now()).toString();

    DocumentSnapshot document = await FirebaseFirestore.instance
          .collection("report_per_user")
          .doc(userId)
          .collection("styles")
          .doc(thismonth)
          .get();

     if (document.exists) {
        setState(() {
          _lenthValue = document["lenth"];
        });
        print("Lenth value: $_lenthValue");
      } else {
        print("No such document!");
      }
    } catch (e) {
      print("Error fetching lenth value: $e");
    }
  }

  Future<void> _fetchMostWornOuter() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("closet_per_user")
          .doc(user!.uid)
          .collection("아우터")
          .orderBy("wear_times", descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var document = snapshot.docs.first;
        setState(() {
          _outerName = document.id;
          _outerimageLink = document['imagelink'];
          _outertimes = document['wear_times'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        print("No such document!");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _outerName = "이번 달에는 아우터를 기록하지 않았네요!";
      });
      print("Error fetching most worn outer: $e");
    }
  }

  Future<void> _fetchMostWornTop() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("closet_per_user")
          .doc(user!.uid)
          .collection("상의")
          .orderBy("wear_times", descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var document = snapshot.docs.first;
        setState(() {
          _topName = document.id;
          _topimageLink = document['imagelink'];
          _toptimes = document['wear_times'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        print("No such document!");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _topName = "이번 달에는 상의를 기록하지 않았어요!";
      });
      print("Error fetching most worn top: $e");
    }
  }

  Future<void> _fetchMostWornBottom() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("closet_per_user")
          .doc(user!.uid)
          .collection("하의")
          .orderBy("wear_times", descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var document = snapshot.docs.first;
        setState(() {
          _bottomName = document.id;
          _bottomimageLink = document['imagelink'];
          _bottomtimes = document['wear_times'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        print("No such document!");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _outerName = "이번 달에는 하의를 기록하지 않았어요!";
      });
      print("Error fetching most worn bottom: $e");
    }
  }

  Future<void> _fetchMostWornShoes() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("closet_per_user")
          .doc(user!.uid)
          .collection("신발")
          .orderBy("wear_times", descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var document = snapshot.docs.first;
        setState(() {
          _shoesName = document.id;
          _shoesimageLink = document['imagelink'];
          _shoestimes = document['wear_times'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        print("No such document!");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _outerName = "이번 달에는 신발을 기록하지 않았어요!";
      });
      print("Error fetching most worn shoes: $e");
    }
  }

  Future<void> _fetchMostWornAcc() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("closet_per_user")
          .doc(user!.uid)
          .collection("잡화")
          .orderBy("wear_times", descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var document = snapshot.docs.first;
        setState(() {
          _accName = document.id;
          _accimageLink = document['imagelink'];
          _acctimes = document['wear_times'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        print("No such document!");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _outerName = "이번 달에는 잡화류를 기록하지 않았어요!";
      });
      print("Error fetching most worn acc: $e");
    }
  }

  Future<void> _fetchMarker() async {
    DocumentSnapshot document = await FirebaseFirestore.instance
        .collection("report_per_user")
        .doc(userId)
        .collection("color_marker")
        .doc(thismonth)
        .get();

    if (document.exists) {
      setState(() {
          marker_per_day = document['color_marker'];
        });
      print("kkk Color Marker: $marker_per_day");
    } else {
      print("No color_marker document!");
    }
  }

  Future<void> _fetchStyles() async {
    DocumentSnapshot document = await FirebaseFirestore.instance
        .collection("report_per_user")
        .doc(userId)
        .collection("styles")
        .doc(thismonth)
        .get();

    if (document.exists) {
      setState(() {
          styles_per_day = document['styles'];
        });
      print("styles_per_day : $styles_per_day");
    } else {
      print("No styles document!");
    }
  }

  Future<void> _fetchKeyword() async {
    DocumentSnapshot document = await FirebaseFirestore.instance
      .collection("report_per_user")
      .doc(userId)
      .collection("keywords")
      .doc(thismonth)
      .get();

    if (document.exists) {
      setState(() {
          keywords_per_day  = document['keywords'];
        });
      print("keywords_per_day: $keywords_per_day");
    } else {
      print("No keyword document!");
    }
  }

  // Future<String> FetchStyle() async {
  //   var url = Uri.parse('https://my-chatbot-ubqysly32a-du.a.run.app');
  //   var response = await http.post(
  //     url,
  //     headers: {'Content-Type': 'plain/text'},
  //     body: "https://m.uremind.co.kr/web/product/big/202302/3680bc505056ad936faa4e9af25d4dd8.jpg",
  //   );

  //   if (response.statusCode == 200) {
  //     // 리소스 생성 성공
  //     print('Created data: ${response.body}');
  //     return response.body;
  //   } else {
  //     // 에러 처리
  //     print('Request failed with status: ${response.statusCode}.');
  //     throw Exception('Failed to load data');
  //   }
  // }

  //리포트 생성 들어갈 자리
  Future<String> fetchData() async {

    String userData = "$userName $userId";
   
    var url = Uri.parse('https://my-report-ubqysly32a-du.a.run.app');
    var response = await http.post(
    url,
    headers: {'Content-Type': 'plain/text'},
    body: userData,
    );

    if (response.statusCode == 200) {
      // 리소스 생성 성공
      print('Created data: ${response.body}');
      return response.body;
    } else {
      // 에러 처리
      print('Request failed with status: ${response.statusCode}.');
      return response.body;
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    var userName2 = userName;
    return Padding(
        padding: const EdgeInsets.all(15),
    child: Scaffold(
      body: Container(
        color: Colors.white,
        child: Scaffold(
          body: Column(
            children: [
              Expanded(child: SingleChildScrollView(
                child: Column(
                  children: [
                    Timeline(time: '$nowyear년 $nowmonth월 $nowday일 월요일'),
                    const SizedBox(height: 10),
                    OtherChat(
                      text: "$userName님의 $nowyear년 $nowmonth월 리포트입니다!",
                    ),
                    OtherChat(
                      text: "이번 달에는 LOOK에 $_lenthValue개의 OOTD를 기록했어요!",
                    ),
                    FutureBuilder<String>(
                          future: fetchData(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return const OtherChat(
                                text: "Failed to load data",
                              );
                            } else {
                              return OtherChat(
                                text: snapshot.data!,
                              );
                            }
                          },
                        ),
                    OtherChat(
                      text: "$userName님의 이번 달 최애 아우터는 $_outerName! 총 $_outertimes번 착용하셨네요.",
                    ),
                    OtherChatImage(
                        image: _outerimageLink
                    ),
                    OtherChat(
                      text: "$userName님의 이번 달 최애 상의는 $_topName! 총 $_toptimes번 착용하셨네요.",
                    ),
                    OtherChatImage(
                        image: _topimageLink
                    ),
                    OtherChat(
                      text: "$userName님의 이번 달 최애 하의는 $_bottomName! 총 $_bottomtimes번 착용하셨네요.",
                    ),
                    OtherChatImage(
                        image: _bottomimageLink
                    ),
                    OtherChat(
                      text: "$userName님의 이번 달 최애 신발은 $_shoesName! 총 $_shoestimes번 착용하셨네요.",
                    ),
                    OtherChatImage(
                        image: _shoesimageLink
                    ),
                    OtherChat(
                      text: "$userName님의 이번 달 최애 잡화는 $_accName! 총 $_acctimes번 착용하셨네요.",
                    ),
                    OtherChatImage(
                        image: _accimageLink
                    ),
                  ],
                ),
              ))
            ],
          ),
        ),
      ),
    ),
    );
  }
}