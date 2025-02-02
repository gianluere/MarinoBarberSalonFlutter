import 'package:flutter/material.dart';
import 'package:marino_barber_salon_flutter/Account/account.dart';
import 'package:marino_barber_salon_flutter/Account/aggiungi_recensione.dart';
import 'package:marino_barber_salon_flutter/Account/dati_personali.dart';
import 'package:marino_barber_salon_flutter/Account/recensioni.dart';

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
      observers: [accountRouteObserver],
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
          settings: settings,
          builder: (BuildContext context) {
            if (settings.name == "/dati_personali") {
              return DatiPersonali();
            } else if (settings.name == "/prenotazioni"){
              return Prenotazioni();
            } else if (settings.name == '/recensioni'){
              return Recensioni();
            } else if (settings.name == '/inserisci_recensione'){
              return InserisciRecensione();
            }
            return AccountScreen();
          },
        );
      },
    );
  }
}


class AccountRouteObserver extends NavigatorObserver {
  //String? currentRoute;
  final ValueNotifier<String?> currentRoute = ValueNotifier<String?>(null);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    currentRoute.value = route.settings.name;
    debugPrint("Account Navigator Pushed: ${route.settings.name}");
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    currentRoute.value = previousRoute?.settings.name;
    debugPrint("Account Navigator Popped to: ${previousRoute?.settings.name}");
  }
}

final AccountRouteObserver accountRouteObserver = AccountRouteObserver();