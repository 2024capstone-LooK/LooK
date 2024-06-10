import 'package:flutter/material.dart';
import 'package:looook/homes/home.dart';
import 'package:looook/src/pages/closet.dart';
import 'package:looook/mypages/mypage.dart';
import 'package:looook/src/pages/recommend.dart';
import 'package:looook/src/pages/report.dart';
import 'package:firebase_database/firebase_database.dart';

FirebaseDatabase database = FirebaseDatabase.instance;

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  var _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title:Padding(
              padding: const EdgeInsets.only(top:20),
              child : Image.asset(
                'imgs/logo.png',
                fit: BoxFit.contain,
              ),
          ),
        ),
        body: _pages[_index],
        bottomNavigationBar:
        Container(
          decoration: const BoxDecoration(
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.grey,
                blurRadius: 5,
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _index,
            onTap: (value) {
              setState(() {
                _index = value;
                print(_index);
              });
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.indigo,
            unselectedItemColor: Colors.grey,

            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'),
              BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'report'),
              BottomNavigationBarItem(icon: Icon(Icons.thumb_up_alt), label: 'recommend'),
              BottomNavigationBarItem(icon: Icon(Icons.dns), label: 'closet'),
              BottomNavigationBarItem(icon: Icon(Icons.account_circle_rounded), label: 'mypages'),
            ],
          ),
        )

    );
  }
}

List _pages = [
  const Home(),
  const Report(),
  const Recommend(),
  Closet(),
  Mypage(),
];