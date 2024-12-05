import 'package:flutter/material.dart';
import 'package:gif_creator/screens/edit_screen.dart';
import 'package:gif_creator/screens/result_screen.dart';
import 'package:gif_creator/screens/select_screen.dart';


class Home extends StatefulWidget {
  const Home({
    super.key,
  });

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  int selectedIndex = 0;

  void setPage(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  final List<Widget> _screens = const [
    SelectScreen(),
    EditScreen(),
    ResultScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GIF Creator'),
        elevation: 2,
      ),
      body: _screens[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: 'Select',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: 'Edit',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.gif_box),
            label: 'Result',
          ),
        ],
      ),
    );
  }
}
