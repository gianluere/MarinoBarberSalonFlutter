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
    /*
    final Map<String, String> titoliRotte = {
      '/': '',
      '/home': 'Home',
      '/account': 'Account',
      '/shop': 'Shop',
      '/seleziona_servizio': 'Seleziona Servizio',
    };

    final Map<String, bool> iconaRotte = {
      '/': false,
      '/home': false,
      '/account': false,
      '/shop': false,
      '/seleziona_servizio': true,
    };

     */

    // Ottieni il nome della rotta corrente
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '';

    print("Current route: $currentRoute");

    // Ottieni il titolo per la rotta corrente, con un valore di default
    //final appBarTitle = titoliRotte[currentRoute] ?? 'App';
    //print("TITOLO: $appBarTitle");

    //final appBarIcon = iconaRotte[currentRoute] ?? false;
    //print("Icona: $appBarIcon");


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
            color: myGold, // Colore della linea
            height: 2.0,   // Spessore della linea
            )
        )
    );

  }

}