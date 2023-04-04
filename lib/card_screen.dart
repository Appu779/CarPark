import 'package:flutter/material.dart';

class CardPage extends StatefulWidget {
  CardPage({super.key});

  @override
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
  List<Widget> cards = [];
  int _counter = 0;
  int _lastCounter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
      _lastCounter = _counter;
    });
  }

  void addCard() {
    _incrementCounter();
    setState(() {
      cards.add(
        Dismissible(
          key: ValueKey(_counter),
          onDismissed: (direction) {
            setState(() {
              _counter = _lastCounter;
              cards.removeLast();
              if (cards.isEmpty) {
                _counter = 0;
              }
            });
          },
          child: Card(
              child: SingleChildScrollView(
            child: Container(
              height: 150,
              color: Colors.yellow,
              margin: EdgeInsets.all(8),
              child: Center(
                child: Text(
                  "Car $_counter",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          )),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Car Details"),
        actions: [IconButton(onPressed: addCard, icon: Icon(Icons.add))],
      ),
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: cards,
        ),
      ),
    );
  }
}
