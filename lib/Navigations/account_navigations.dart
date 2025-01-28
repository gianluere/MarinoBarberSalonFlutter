import 'package:flutter/material.dart';
import 'package:marino_barber_salon_flutter/Account/account.dart';

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
            if (settings.name == "/detailsUpdates") {
              return Account();
            }
            return Account();
          },
        );
      },
    );
  }
}