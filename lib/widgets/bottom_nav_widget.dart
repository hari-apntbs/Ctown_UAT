import 'package:flutter/material.dart';

class MyBottomNavigationBar extends StatelessWidget {
  String? selectedIcon = "";
  MyBottomNavigationBar({this.selectedIcon});
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedItemColor: const Color(0xffda0c15),
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: const TextStyle(
        color: Color(0xffda0c15)
      ),
      unselectedLabelStyle: const TextStyle(
        color: Colors.grey
      ),
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Image.asset("assets/icons/tabs/tab-home.png", width: 20, height: 20,),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Image.asset("assets/icons/tabs/tab-category.png", width: 20, height: 20,),
          label: 'Business',
        ),
        BottomNavigationBarItem(
          icon: Image.asset("assets/icons/tabs/discount.png", width: 20, height: 20,),
          label: 'School',
        ),
        BottomNavigationBarItem(
          icon: Image.asset("assets/icons/tabs/cart.png", width: 20, height: 20,),
          label: 'School',
        ),
        BottomNavigationBarItem(
          icon: Image.asset("assets/icons/tabs/more.png", width: 20, height: 20,),
          label: 'School',
        ),
      ],
    );
  }
}