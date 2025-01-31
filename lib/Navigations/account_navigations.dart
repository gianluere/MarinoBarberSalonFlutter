import 'package:flutter/material.dart';
import 'package:marino_barber_salon_flutter/Account/account.dart';
import 'package:marino_barber_salon_flutter/Account/dati_personali.dart';

import '../Account/prenotazioni.dart';

class AccountNavigator extends StatefulWidget {
  const AccountNavigator({super.key});

  @override
  AccountNavigatorState createState() => AccountNavigatorState();
}

GlobalKey<NavigatorState> accountNavigatorKey = GlobalKey<NavigatorState>();

class AccountNavigatorState extends State<AccountNavigator> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: accountNavigatorKey,
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
          settings: settings,
          builder: (BuildContext context) {
            if (settings.name == "/dati_personali") {
              return DatiPersonali();
            } else if (settings.name == "/prenotazioni"){
              return Prenotazioni();
            }
            return AccountScreen();
          },
        );
      },
    );
  }
}