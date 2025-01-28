import 'package:flutter/material.dart';
import 'my_colors.dart';

class MyBottomBar extends StatefulWidget{
  const MyBottomBar({super.key});

  @override
  _MyBottomBarState  createState() => _MyBottomBarState();

}

class _MyBottomBarState extends State<MyBottomBar>{
  int currentPageIndex = 0;
  @override
  Widget build(BuildContext context) {
    return NavigationBar(
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.cut, color: myBordeaux, size: 42,),
            icon: Icon(Icons.content_cut_outlined, color: myWhite, size: 42),
            label: '',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.account_circle_outlined, color: myBordeaux, size: 42),
            icon: Icon(Icons.account_circle_outlined, color: myWhite, size: 42),
            label: '',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.shopping_cart, color: myBordeaux, size: 42),
            icon: Icon(Icons.shopping_cart_outlined, color: myWhite, size: 42),
            label: '',
          )
        ],
      onDestinationSelected: (int index) {
        setState(() {
          currentPageIndex = index;
        });
      },
      selectedIndex: currentPageIndex,
      backgroundColor: myGrey,
      indicatorColor: Colors.transparent
    );
  }
}