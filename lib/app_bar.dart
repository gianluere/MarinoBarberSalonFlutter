import 'package:flutter/material.dart';
import 'my_colors.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget{
  final String title;
  final bool icon;

  const MyAppBar(this.title, this.icon, {super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {


    //rotta corrente
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '';

    print("Current route: $currentRoute");


    return AppBar(
          title: Text(title, style: TextStyle(color: myWhite, fontWeight: FontWeight.bold)),
          centerTitle: true,
          leading: icon
              ? IconButton(onPressed: () => {Navigator.pop(context)}, icon : Icon(Icons.arrow_back, color: myWhite))
              :  null,
          backgroundColor: myGrey,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(2.0), // Altezza della linea
            child: Container(
              color: myGold,
              height: 2.0
            )
        )
    );

  }

}