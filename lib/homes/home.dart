import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:looook/homes/home_pop.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

final db = FirebaseFirestore.instance;
FirebaseDatabase database = FirebaseDatabase.instance;

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

final Set<DateTime> _markedDates = {};

class _HomeState extends State<Home> {
  Map<DateTime, String> _dateColors = {};

  DateTime selectedDate = DateTime.utc(
    DateTime.now().year,    DateTime.now().month,
    DateTime.now().day,
  );

  DateTime focusedDate = DateTime.utc(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  Color markerColor = Colors.indigo;

  Future<void> _fetchColors() async {
    try {
      final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
      User? user = _firebaseAuth.currentUser;

      if (user == null) {
        await _firebaseAuth.signInWithEmailAndPassword(
            email: "yobi0810@naver.com", password: "asdf1234");
        user = _firebaseAuth.currentUser;
      }

      String userId = user!.uid;
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("calendar_per_user")
          .doc(userId)
          .collection("date_cloth")
          .get();

      Map<DateTime, String> fetchedColors = {};
      snapshot.docs.forEach((doc) {
        //print(doc.id);
        var data = doc.data() as Map<String, dynamic>;
        DateTime date = DateFormat('yyyy.MM.dd.EEEE', 'ko_KR').parse(doc.id);
        DateTime dateOnly = DateTime(date.year, date.month, date.day);
        fetchedColors[dateOnly] = data['main_color'];
      });

      Map<DateTime, String> fetchedStyles = {};
      snapshot.docs.forEach((doc) {
        //print(doc.id);
        var data = doc.data() as Map<String, dynamic>;
        DateTime date = DateFormat('yyyy.MM.dd.EEEE', 'ko_KR').parse(doc.id);
        DateTime dateOnly = DateTime(date.year, date.month, date.day);
        fetchedStyles[dateOnly] = data['style'];
      });

      Map<DateTime, String> fetchedKeywords = {};
      snapshot.docs.forEach((doc) {
        //print(doc.id);
        var data = doc.data() as Map<String, dynamic>;
        DateTime date = DateFormat('yyyy.MM.dd.EEEE', 'ko_KR').parse(doc.id);
        DateTime dateOnly = DateTime(date.year, date.month, date.day);
        fetchedKeywords[dateOnly] = data['keywords'].toString();
      });

      //print(fetchedColors);
      String thismonth = DateFormat('yyyy.MM', 'ko_KR').format(DateTime.now()).toString();

      try {
        DocumentReference docRef = FirebaseFirestore.instance
            .collection("report_per_user")
            .doc(user!.uid).collection("styles")
            .doc(thismonth);

        await docRef.update({
          "color_marker": fetchedStyles.toString(),
          "lenth" : fetchedStyles.length
        });
      }
      catch(e) {
        await db
            .collection("report_per_user")
            .doc(user!.uid).collection("styles")
            .doc(thismonth)
            .set({
              "uid": user!.uid,
              "month": thismonth,
              "styles": fetchedStyles.toString(),
              "lenth" : fetchedStyles.length
        });
      }

      try {
        DocumentReference docRef = FirebaseFirestore.instance
            .collection("report_per_user")
            .doc(user!.uid).collection("color_marker")
            .doc(thismonth);

        await docRef.update({
          "color_marker": fetchedColors.toString(),
          "lenth" : fetchedColors.length
        });
      }
      catch(e) {
        await db
            .collection("report_per_user")
            .doc(user!.uid).collection("color_marker")
            .doc(thismonth)
            .set({
              "uid": user!.uid,
              "month": thismonth,
              "color_marker": fetchedColors.toString(),
              "lenth" : fetchedColors.length
        });
      }

      try {
        DocumentReference docRef = FirebaseFirestore.instance
            .collection("report_per_user")
            .doc(user!.uid).collection("keywords")
            .doc(thismonth);

        await docRef.update({
          "keywords": fetchedKeywords.toString(),
          "lenth" : fetchedKeywords.length
        });
      }
      catch(e) {
        await db
            .collection("report_per_user")
            .doc(user!.uid).collection("keywords")
            .doc(thismonth)
            .set({
              "uid": user!.uid,
              "month": thismonth,
              "keywords": fetchedKeywords.toString(),
              "lenth" : fetchedKeywords.length
        });
      }

      setState(() {
        _dateColors = fetchedColors;
      });
    } catch (e) {
      print("Error fetching colors: $e");
    }

  }


  @override
  void initState() {
    super.initState();
    _fetchColors();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: TableCalendar(
          locale: 'ko_KR',
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2033, 12, 31),
          focusedDay: focusedDate,
          daysOfWeekHeight: 45,
          rowHeight: 80,
          onDaySelected: (selectedDay, focusedDay) {
            return onDaySelected(selectedDay, focusedDay);
          },
          onPageChanged: (focusedDay) {
            setState(() {
              focusedDate = focusedDay;
            });
          },
          selectedDayPredicate: (date) {
            return isSameDay(selectedDate, date);
          },
          calendarStyle: const CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Colors.indigo,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
              border: Border.fromBorderSide(
                BorderSide(color: Colors.indigo, width: 2),
              ),
            ),
            selectedTextStyle: TextStyle(
              color: Colors.black,
            ),
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 22.0,
            ),
          ),
          calendarBuilders: CalendarBuilders(
            todayBuilder: (context, date, _) {
              return Container(
                margin: const EdgeInsets.all(4.0),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.indigo,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  date.day.toString(),
                  style: const TextStyle(color: Colors.white),
                ),
              );
            },
            defaultBuilder: (context, date, _) {
              return Container(
                margin: const EdgeInsets.all(4.0),
                alignment: Alignment.center,
                child: Text(
                  date.day.toString(),
                  style: const TextStyle(),
                ),
              );
            },
            outsideBuilder: (context, date, _) {
              return Container(
                margin: const EdgeInsets.all(4.0),
                alignment: Alignment.center,
                child: Text(
                  date.day.toString(),
                  style: const TextStyle(color: Colors.grey),
                ),
              );
            },
            selectedBuilder: (context, date, _) {
              if (isSameDay(date, DateTime.now())) {
                return Container(
                  margin: const EdgeInsets.all(4.0),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Colors.indigo,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    date.day.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              } else {
                return Container(
                  margin: const EdgeInsets.all(4.0),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.fromBorderSide(
                      BorderSide(color: Colors.indigo, width: 2),
                    ),
                  ),
                  child: Text(
                    date.day.toString(),
                    style: const TextStyle(color: Colors.indigo),
                  ),
                );
              }
            },

            //marker관련해서 이부분 건드리시면 되는데 모르시겟으면 연락주거나 제가 하겟음다
            markerBuilder: (context, date, events) {
              DateTime dateOnly = DateTime(date.year, date.month, date.day);
              if (_dateColors.containsKey(dateOnly)) {
                String mainColor = _dateColors[dateOnly]!;
                Color parsedColor = Color(int.parse(mainColor.replaceFirst('#', '0xff')));

                BoxBorder? border;
                if (mainColor.toUpperCase() == "#FFFFFF") {
                  border = Border.all(color: Colors.grey, width: 0.3); // 회색 테두리 설정
                }

                return Positioned(
                  bottom: 1,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: parsedColor,
                      border: border,
                    ),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ),
      ),
    );
  }

  void onDaySelected(DateTime selectedDate, DateTime focusedDate) {
    setState(() {
      this.selectedDate = selectedDate;
      this.focusedDate = focusedDate;
    });
    homePop(context, selectedDate);
  }
}
