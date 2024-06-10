import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

FirebaseDatabase database = FirebaseDatabase.instance;
final storage = FirebaseStorage.instance;
final db = FirebaseFirestore.instance;

void homePop(BuildContext context, DateTime selectedDate) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: ImageSelectionWidget(selectedDate: selectedDate),
        ),
      );
    },
  );
}

//Cloth, ClothList 클래스 - hys
class Cloth {
  String? main_category;
  String? sub_category;
  String? color;
  String? css_color;

  Cloth({
    this.main_category,
    this.sub_category,
    this.color,
    this.css_color,
  });

  factory Cloth.fromJson(Map<String, dynamic> json) => Cloth(
    main_category: json["main_category"],
    sub_category: json["sub_category"],
    color: json["color"],
    css_color: json["css_color"],
  );

  Map<String, dynamic> toJson() => {
    "main_category": main_category,
    "sub_category": sub_category,
    "color": color,
    "css_color": css_color,
  };
}

class ClothList {
  final List<Cloth>? clothes;

  ClothList({this.clothes});

  factory ClothList.fromJson(String jsonString) {
    Map<String, dynamic> decodedJson = json.decode(jsonString);
    List<dynamic> listFromJson = decodedJson["Created data"];
    List<Cloth> clothes = listFromJson.map((cloth) => Cloth.fromJson(cloth)).toList();
    return ClothList(clothes: clothes);
  }

  String toJson() {
    List<Map<String, dynamic>> listToJson = clothes!.map((cloth) => cloth.toJson()).toList();
    return json.encode(listToJson);
  }
}


class ImageSelectionWidget extends StatefulWidget {
  final DateTime selectedDate;
  const ImageSelectionWidget({super.key, required this.selectedDate});

  @override
  _ImageSelectionWidgetState createState() => _ImageSelectionWidgetState();
}

class _ImageSelectionWidgetState extends State<ImageSelectionWidget> {
  XFile? _image;
  final TextEditingController _textController = TextEditingController();

  String? _savedText;
  bool _isEditing = true;
  late DateTime _selectedDate;

  List<String> _selectedStates = [];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    _loadData();
  }

  Future<void> _loadData() async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final user = _firebaseAuth.currentUser;

    if (user != null) {
      final doc = await db
          .collection("calendar_per_user")
          .doc(user.uid)
          .collection("date_cloth")
          .doc(DateFormat('yyyy.MM.dd.EEEE', 'ko_KR').format(_selectedDate))
          .get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          setState(() {
            _savedText = data['text'];
            _textController.text = _savedText!;
            _isEditing = false;
            _selectedStates = List<String>.from(data['keywords']);
            _loadImage(data['imagelink']);
          });
        }
      } else {
        //선택된 날짜에 아무 데이터도 없는 경우 걍 초기화
        setState(() {
          _savedText = null;
          _textController.clear();
          _isEditing = true;
          _selectedStates = [];
          _image = null;
        });
      }
    }
  }

  Future<void> _loadImage(String url) async {
    final ref = FirebaseStorage.instance.refFromURL(url);
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/${ref.name}');
    await ref.writeToFile(file);
    setState(() {
      _image = XFile(file.path);
    });
  }

  void _pickImageAndUpdate() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  void _showImageDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min, // 내용물 크기에 맞게 조절
          children: [
            Image.file(File(_image!.path)),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickImageAndUpdate();
              },
              child: const Text(
                '재선택',
                style: TextStyle(color: Colors.indigo),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveText() {
    setState(() {
      _savedText = _textController.text;
      _textController.clear();
      _isEditing = false;
    });

    _updateText(_savedText!);
  }

  void _updateText(String text) async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await db
          .collection("calendar_per_user")
          .doc(user.uid)
          .collection("date_cloth")
          .doc(DateFormat('yyyy.MM.dd.EEEE', 'ko_KR')
              .format(widget.selectedDate))
          .update({
        "text": text,
      });
    }
  }

  void _editText() {
    setState(() {
      _isEditing = true;
      _textController.text = _savedText!;
      _savedText = null;
    });
  }

  void _showStateDialog() {
    final List<String> tempSelectedStates =
        List.from(_selectedStates); // dialog 내부에서만 사용할 임시 리스트

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // StatefulBuilder를 사용하여 다이얼로그 내부의 상태를 변경할 수 있도록 함
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text(
                "👀 오늘의 LOOK은",
                style: TextStyle(fontSize: 20),
              ),
              backgroundColor: Colors.white,
              content: SizedBox(
                height: 450,
                width: 150,
                child: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      for (var state in [
                        '😀 편해요',
                        '😥 불편해요',
                        '👍 색조합 good',
                        '😑 색조합 soso',
                        '👎 색조합 bad ',
                        '🧥 깔끔해요',
                        '✨ 화려해요',
                        '💄 꾸꾸꾸',
                        '👚 꾸안꾸',
                        '🚶‍ 집앞룩',
                        '❤️ 데이트룩',
                        '👟 운동룩',
                        '✨ 파티룩',
                        '🕶️ 힙룩'
                      ])
                        CheckboxListTile(
                          title: Text(state),
                          activeColor: Colors.indigo,
                          value: tempSelectedStates.contains(state),
                          onChanged: (bool? value) {
                            // 선택 해제하는 경우는 제한 없이
                            if (value == false) {
                              tempSelectedStates.remove(state);
                            } else {
                              // 이미 4개가 선택된 상태에서는 추가 선택 불가
                              if (tempSelectedStates.length < 4) {
                                tempSelectedStates.add(state);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("최대 4개까지만 선택할 수 있습니다."),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            }
                            setState(() {
                              _selectedStates = List.from(tempSelectedStates);
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text(
                    "취소",
                    style: TextStyle(color: Colors.indigo),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text(
                    "제출",
                    style: TextStyle(color: Colors.indigo),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _updateSelectedStates(_selectedStates); // 선택된 상태들을 업데이트
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _updateSelectedStates(List<String> selectedStates) async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await db
          .collection("calendar_per_user")
          .doc(user.uid)
          .collection("date_cloth")
          .doc(DateFormat('yyyy.MM.dd.EEEE', 'ko_KR')
              .format(widget.selectedDate))
          .update({
        "keywords": selectedStates,
      });
    }
  }

  //0529 hys
  void SaveAll(var photo, var text, List<String> keywords) async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      print(user.uid);
    } else {
      // _firebaseAuth.signInAnonymously();
      try {
        final credential = await _firebaseAuth.signInWithEmailAndPassword(
            email: "yobi0810@naver.com", password: "asdf1234");
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          print('No user found for that email.');
        } else if (e.code == 'wrong-password') {
          print('Wrong password provided for that user.');
        }
      }
    }

    print("upload start...\n");

    //Upload image to Firebase Storage - hys 0525
    File file = File(photo.path);
    if (!file.existsSync()) {
      print("File does not exist");
      return;
    }

    String fileName = DateFormat('yyyy.MM.dd', 'ko_KR').format(_selectedDate).toString()+user!.uid;
    final storageRef =
        FirebaseStorage.instance.ref().child("test/$fileName.jpg");
    try {
      await storageRef.putFile(file);
      String downloadURL = await storageRef.getDownloadURL();
      print("Upload successful, download URL: $downloadURL");

      print("GPT 가동!");
      var url = Uri.parse('https://my-chatbot-ubqysly32a-du.a.run.app');
      var response = await http.post(
        url,
        headers: {'Content-Type': 'plain/text'},
        body: "$downloadURL",
      );

      if (response.statusCode == 200) {
        // 리소스 생성 성공
        print('Created data');
        print(response.body);
      } else {
        // 에러 처리
        print('Request failed with status: ${response.statusCode}.');
        throw Exception('Failed to load data');
      }

      // ClothList 객체로 변환
      final _clothList = ClothList.fromJson(response.body);

      // JSON 형식의 문자열로 변환
      String transformedJsonString = _clothList.toJson();

      // JSON 문자열을 다시 디코딩하여 리스트로 변환
      List<dynamic> decodedJsonList = json.decode(transformedJsonString);

      //저장
      await db
          .collection("calendar_per_user")
          .doc(user!.uid).collection("date_cloth")
          .doc(DateFormat('yyyy.MM.dd.EEEE', 'ko_KR').format(_selectedDate).toString())
          .set({
        "uid": user!.uid,
        "date": DateFormat('yyyy.MM.dd.EEEE', 'ko_KR').format(_selectedDate).toString(),
        "imagelink" : downloadURL,
        "text" : text,
        "keywords" : keywords,
        "gpt_analyze" : response.body,
        "main_color" : decodedJsonList[6]["css_color"].toString(),
        "style" : decodedJsonList[7]["sub_category"].toString(),
      });

      //아우터 저장
      if(decodedJsonList[0]["sub_category"] != null){
        try {
          String documentId = decodedJsonList[0]["color"].toString() + " " + decodedJsonList[0]["sub_category"].toString();
          DocumentReference docRef = FirebaseFirestore.instance
              .collection("closet_per_user")
              .doc(user!.uid)
              .collection("아우터")
              .doc(documentId);

          await docRef.update({
            "wear_times": FieldValue.increment(1),
            "recent_ware_date": DateFormat('yyyy.MM.dd.EEEE', 'ko_KR').format(
                _selectedDate).toString(),
          });
        }
        catch(e) {
          await db
              .collection("closet_per_user")
              .doc(user!.uid).collection("아우터")
              .doc(decodedJsonList[0]["color"].toString() + " " + decodedJsonList[0]["sub_category"].toString())
              .set({
            "uid": user!.uid,
            "recent_ware_date": DateFormat('yyyy.MM.dd.EEEE', 'ko_KR').format(
                _selectedDate).toString(),
            "imagelink": downloadURL,
            "wear_times": 1,
            "css_color" : decodedJsonList[0]["css_color"].toString()
          });
        }
      }

      //상의 저장
      if(decodedJsonList[1]["sub_category"] != null){
        try {
          String documentId = decodedJsonList[1]["color"].toString() + " " + decodedJsonList[1]["sub_category"].toString();
          DocumentReference docRef = FirebaseFirestore.instance
              .collection("closet_per_user")
              .doc(user!.uid)
              .collection("상의")
              .doc(documentId);

          await docRef.update({
            "wear_times": FieldValue.increment(1),
            "recent_ware_date": DateFormat('yyyy.MM.dd.EEEE', 'ko_KR').format(
                _selectedDate).toString(),
          });
        }
        catch(e) {
          await db
              .collection("closet_per_user")
              .doc(user!.uid).collection("상의")
              .doc(decodedJsonList[1]["color"].toString() + " " + decodedJsonList[1]["sub_category"].toString())
              .set({
            "uid": user!.uid,
            "recent_ware_date": DateFormat('yyyy.MM.dd.EEEE', 'ko_KR').format(
                _selectedDate).toString(),
            "imagelink": downloadURL,
            "wear_times": 1,
            "css_color" : decodedJsonList[1]["css_color"].toString()
          });
        }
      }

      //하의 저장
      if(decodedJsonList[2]["sub_category"] != null){
        try {
          String documentId = decodedJsonList[2]["color"].toString() + " " + decodedJsonList[2]["sub_category"].toString();
          DocumentReference docRef = FirebaseFirestore.instance
              .collection("closet_per_user")
              .doc(user!.uid)
              .collection("하의")
              .doc(documentId);

          await docRef.update({
            "wear_times": FieldValue.increment(1),
            "recent_ware_date": DateFormat('yyyy.MM.dd.EEEE', 'ko_KR').format(
                _selectedDate).toString(),
          });
        }
        catch(e) {
          await db
              .collection("closet_per_user")
              .doc(user!.uid).collection("하의")
              .doc(decodedJsonList[2]["color"].toString() + " " +
              decodedJsonList[2]["sub_category"].toString())
              .set({
            "uid": user!.uid,
            "recent_ware_date": DateFormat('yyyy.MM.dd.EEEE', 'ko_KR').format(
                _selectedDate).toString(),
            "imagelink": downloadURL,
            "wear_times": 1,
            "css_color" : decodedJsonList[2]["css_color"].toString()
          });
        }
      }

      //신발 저장
      if(decodedJsonList[3]["sub_category"] != null){
        try {
          String documentId = decodedJsonList[3]["color"].toString() + " " + decodedJsonList[3]["sub_category"].toString();
          DocumentReference docRef = FirebaseFirestore.instance
              .collection("closet_per_user")
              .doc(user!.uid)
              .collection("신발")
              .doc(documentId);

          await docRef.update({
            "wear_times": FieldValue.increment(1),
            "recent_ware_date": DateFormat('yyyy.MM.dd.EEEE', 'ko_KR').format(
                _selectedDate).toString(),
          });
        }
        catch(e) {
          await db
              .collection("closet_per_user")
              .doc(user!.uid).collection("신발")
              .doc(decodedJsonList[3]["color"].toString() + " " +
              decodedJsonList[3]["sub_category"].toString())
              .set({
            "uid": user!.uid,
            "recent_ware_date": DateFormat('yyyy.MM.dd.EEEE', 'ko_KR').format(
                _selectedDate).toString(),
            "imagelink": downloadURL,
            "wear_times": 1,
            "css_color" : decodedJsonList[3]["css_color"].toString()
          });
        }
      }

      //가방 저장
      if(decodedJsonList[4]["sub_category"] != null){
        try {
          String documentId = decodedJsonList[4]["color"].toString() + " " + decodedJsonList[4]["sub_category"].toString();
          DocumentReference docRef = FirebaseFirestore.instance
              .collection("closet_per_user")
              .doc(user!.uid)
              .collection("잡화")
              .doc(documentId);

          await docRef.update({
            "wear_times": FieldValue.increment(1),
            "recent_ware_date": DateFormat('yyyy.MM.dd.EEEE', 'ko_KR').format(
                _selectedDate).toString(),
          });
        }
        catch(e) {
          await db
              .collection("closet_per_user")
              .doc(user!.uid).collection("잡화")
              .doc(decodedJsonList[4]["color"].toString() + " " +
              decodedJsonList[4]["sub_category"].toString())
              .set({
            "uid": user!.uid,
            "recent_ware_date": DateFormat('yyyy.MM.dd.EEEE', 'ko_KR').format(
                _selectedDate).toString(),
            "imagelink": downloadURL,
            "wear_times": 1,
            "css_color" : decodedJsonList[4]["css_color"].toString()
          });
        }
      }
      
      //모자 저장
      if(decodedJsonList[5]["sub_category"] != null){
        try {
          String documentId = decodedJsonList[5]["color"].toString() + " " + decodedJsonList[5]["sub_category"].toString();
          DocumentReference docRef = FirebaseFirestore.instance
              .collection("closet_per_user")
              .doc(user!.uid)
              .collection("잡화")
              .doc(documentId);

          await docRef.update({
            "wear_times": FieldValue.increment(1),
            "recent_ware_date": DateFormat('yyyy.MM.dd.EEEE', 'ko_KR').format(
                _selectedDate).toString(),
          });
        }
        catch(e) {
          await db
              .collection("closet_per_user")
              .doc(user!.uid).collection("잡화")
              .doc(decodedJsonList[5]["color"].toString() + " " +
              decodedJsonList[5]["sub_category"].toString())
              .set({
            "uid": user!.uid,
            "recent_ware_date": DateFormat('yyyy.MM.dd.EEEE', 'ko_KR').format(
                _selectedDate).toString(),
            "imagelink": downloadURL,
            "wear_times": 1,
            "css_color" : decodedJsonList[5]["css_color"].toString()
          });
        }
      }

    } on firebase_core.FirebaseException catch (e) {
      print("Failed to upload image: $e");
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _loadData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate =
        DateFormat('yyyy.MM.dd.EEEE', 'ko_KR').format(_selectedDate);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ListView(children: [
          const SizedBox(height: 10),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () => _selectDate(context),
              ),
              const SizedBox(width: 20),
              Text(
                formattedDate,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                style: TextButton.styleFrom(
                    foregroundColor: Colors.indigo,
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.01,
                    )),
                onPressed: () {
                  var photo = _image;
                  var text = _savedText;
                  var keywords = _selectedStates;

                  SaveAll(photo, text, keywords);

                  Navigator.pop(context);
                },
                child: const Text("완료"),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_image == null)
            FloatingActionButton(
              onPressed: _pickImageAndUpdate,
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.black,
              elevation: 0,
              child: const Icon(
                Icons.image,
                size: 25,
              ),
            ),
          if (_image != null) ...[
            GestureDetector(
              onTap: _showImageDialog,
              child: Center(
                child: Image.file(File(_image!.path)),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                IconButton(
                  onPressed: _showStateDialog,
                  icon: const Icon(Icons.list),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                        childAspectRatio: 3.0,
                      ),
                      itemCount: _selectedStates.length,
                      itemBuilder: (context, index) {
                        return Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            _selectedStates[index],
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 10),
                  if (_isEditing) ...[
                    TextField(
                      cursorColor: Colors.indigo,
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: '오늘의 FEEL은 ?',
                        hintStyle: const TextStyle(
                            color: Color(0xFF9D9D9D), fontSize: 15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.black, width: 2.0),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFD3D3D3),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                          foregroundColor: Colors.indigo,
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.01,
                          )),
                      onPressed: _saveText,
                      child: const Text("저장"),
                    ),
                  ],
                  if (_savedText != null) ...[
                    Container(
                      width: 350,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _savedText!,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                          foregroundColor: Colors.indigo,
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.01,
                          )),
                      onPressed: _editText,
                      child: const Text("수정"),
                    ),
                  ] else if (_isEditing == false) ...[
                    TextField(
                      controller: _textController,
                      cursorColor: Colors.indigo,
                      decoration: InputDecoration(
                        hintText: '오늘의 FEEL은 ?',
                        hintStyle: const TextStyle(
                            color: Color(0xFF9D9D9D), fontSize: 15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.black, width: 2.0),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFD3D3D3),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                          foregroundColor: Colors.indigo,
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.01,
                          )),
                      onPressed: _saveText,
                      child: const Text("저장"),
                    ),
                  ]
                ],
              ),
            ),
          ],
        ]),
      ),
    );
  }
}
