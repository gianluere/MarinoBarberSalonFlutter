import 'package:flutter/material.dart';
import 'package:marino_barber_salon_flutter/Account/account.dart';
import 'package:marino_barber_salon_flutter/Shop/Shop.dart';

class ShopNavigator extends StatefulWidget {
  const ShopNavigator({super.key});

  @override
  ShopNavigatorState createState() => ShopNavigatorState();
}

GlobalKey<NavigatorState> shopNavigatorKey = GlobalKey<NavigatorState>();

class ShopNavigatorState extends State<ShopNavigator> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: shopNavigatorKey,
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
          settings: settings,
          builder: (BuildContext context) {
            if (settings.name == "/detailsUpdates") {
              return Shop();
            }
            return Shop();
          },
        );
      },
    );
  }
}