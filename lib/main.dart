import 'package:flutter/material.dart';
import './tabs/HomePage.dart';
import './tabs/ChartPage.dart';
import './tabs/HistoryPage.dart';

import './pages/target/create.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: Root(),
    );
  }
}

class Root extends StatefulWidget {
  @override
  _RootState createState() => _RootState();
}

class _RootState extends State<Root> {
  int index = 0;
  List<Widget> tabs = [];
  Widget page = null;

  @override
  Widget build(BuildContext context) {
    tabs.add(HomePage());
    tabs.add(ChartPage());
    tabs.add(HistoryPage());

    Widget fab = FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () {
        setState(() {
          page = new TargetCreate();
        });
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("My Target"),
      ),
      floatingActionButton: (index < 1) ? fab : null,
      body: (page == null) ? tabs[index] : page,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) {
          setState(() {
            index = i;
            page = null;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), title: Text("HOME")),
          BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart), title: Text("CHARTS")),
          BottomNavigationBarItem(
              icon: Icon(Icons.history), title: Text("HISTORY"))
        ],
      ),
    );
  }
}
