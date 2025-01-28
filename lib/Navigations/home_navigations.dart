import 'package:flutter/material.dart';
import 'package:marino_barber_salon_flutter/Home/home2.dart';
import 'package:marino_barber_salon_flutter/Home/riepilogo.dart';
import 'package:marino_barber_salon_flutter/Home/seleziona_giorno.dart';
import 'package:marino_barber_salon_flutter/Home/seleziona_servizio.dart';

import '../Home/home.dart';

class HomeNavigator extends StatefulWidget {
  const HomeNavigator({super.key});

  @override
  HomeNavigatorState createState() => HomeNavigatorState();
}

GlobalKey<NavigatorState> homeNavigatorKey = GlobalKey<NavigatorState>();

class HomeNavigatorState extends State<HomeNavigator> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: homeNavigatorKey,
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
            settings: settings,
            builder: (BuildContext context) {
              if (settings.name == "/seleziona_servizio") {
                return SelezionaServizioPage();
              }else if (settings.name == "/seleziona_giorno"){
                return SelezionaGiorno();
              }else if (settings.name == '/riepilogo'){
                return Riepilogo();
              }
              return Home();
            });
      },
    );
  }
}