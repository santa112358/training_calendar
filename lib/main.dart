import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'menu.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'トレーニングカレンダー'),
    );
  }
}

class Event {
  final String title;

  Event({this.title});

  String toString() => this.title;
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<DateTime, List<Event>> selectedEvents = {};
  CalendarFormat format = CalendarFormat.month;
  DateTime now = DateTime.now();
  DateTime selectedDay;
  DateTime focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    selectedEvents = {};

    /// TableCalendarは日時までしかselectedDayに代入しない。
    /// DateTime.now()だと秒数まで代入してしまって、TableCalendarの想定する
    /// 日時とずれが生じて表示されなくなってしまう。
    selectedDay = DateTime.utc(now.year, now.month, now.day);
  }

  List<Event> _getEventsFromDay(DateTime date) {
    return selectedEvents[date] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: focusedDay,
            firstDay: DateTime(2020),
            lastDay: DateTime(2022),
            calendarFormat: format,
            onFormatChanged: (CalendarFormat _format) {
              setState(() {
                format = _format;
              });
            },
            onDaySelected: (DateTime selectDay, DateTime focusDay) {
              setState(() {
                selectedDay = selectDay;
                focusedDay = focusDay;
              });
            },
            selectedDayPredicate: (DateTime date) {
              return isSameDay(selectedDay, date);
            },
            eventLoader: _getEventsFromDay,
            rowHeight: 48,
            headerStyle: HeaderStyle(
                formatButtonShowsNext: false,
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonTextStyle: TextStyle(color: Colors.black)),
            calendarStyle: CalendarStyle(
                isTodayHighlighted: true,
                defaultDecoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                weekendDecoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: TextStyle(color: Colors.white),
                todayTextStyle: TextStyle(color: Colors.black),
                todayDecoration: BoxDecoration(
                  color: Colors.yellow,
                  shape: BoxShape.circle,
                )),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _getEventsFromDay(selectedDay).length,
              itemBuilder: (context, index) {
                return Card(
                  child: Container(
                    child: Text(_getEventsFromDay(selectedDay)[index].title),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) {
              return MenuPage(
                onSaved: (data) {
                  setState(() {
                    /// selectedEventsにselectedDayがあるかを確認
                    if (selectedEvents.containsKey(selectedDay)) {
                      /// あったらselectedDayの値（List<Event>）にdataを追加
                      selectedEvents[selectedDay].add(data);
                    } else {
                      /// なかったらselectedDayとdataをセットで追加。
                      ///　値の型に合わせてリストの形でdataを追加する。
                      selectedEvents.addAll({
                        selectedDay: [data]
                      });
                    }
                  });
                },
              );
            },
          ));
        },
        label: Text('トレーニングを追加'),
      ),
    );
  }
}
