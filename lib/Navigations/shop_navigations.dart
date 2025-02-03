import 'package:flutter/material.dart';
import 'package:marino_barber_salon_flutter/Shop/seleziona_shop.dart';

import '../Shop/shop.dart';

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
            if (settings.name == "/shop") {
              return ShopScreen();
            }
            return SelezionaShop();
          },
        );
      },
    );
  }
}