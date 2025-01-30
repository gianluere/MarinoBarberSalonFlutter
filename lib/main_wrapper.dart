import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marino_barber_salon_flutter/Home/notifiche_view_model.dart';
import 'package:marino_barber_salon_flutter/Navigations/account_navigations.dart';
import 'package:marino_barber_salon_flutter/Navigations/shop_navigations.dart';
import 'package:provider/provider.dart';
import 'my_colors.dart';
import 'package:marino_barber_salon_flutter/Navigations/home_navigations.dart';
import 'package:badges/badges.dart' as badges;

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  MainWrapperState createState() => MainWrapperState();
}

class MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    homeNavigatorKey,
    accountNavigatorKey,
    shopNavigatorKey
  ];

  Future<bool> _systemBackButtonPressed() async {
    if (_navigatorKeys[_selectedIndex].currentState?.canPop() == true) {
      _navigatorKeys[_selectedIndex]
          .currentState
          ?.pop(_navigatorKeys[_selectedIndex].currentContext);
      return false;
    } else {
      SystemChannels.platform.invokeMethod<void>('SystemNavigator.pop');
      return true; // Indicate that the back action is handled
    }
  }

  @override
  Widget build(BuildContext context) {

    final notificheViewModel = Provider.of<NotificheViewModel>(context);


    return WillPopScope(
      onWillPop: _systemBackButtonPressed,
      child: Scaffold(
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min, // Assicurati che la colonna prenda solo lo spazio necessario
          children: [
            Container(
              height: 2.0, // Spessore della linea
              color: myWhite, // Colore della linea
            ),
            NavigationBar(
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              selectedIndex: _selectedIndex,
              destinations: [
                NavigationDestination(
                  selectedIcon: Icon(Icons.cut, color: myBordeaux, size: 42),
                  icon: Icon(Icons.content_cut_outlined, color: myWhite, size: 42),
                  label: '',
                ),
                NavigationDestination(
                  selectedIcon: badges.Badge(
                    badgeContent: Text(
                      '${notificheViewModel.notifichePrenotazioni}',  // Mostra il numero di notifiche
                      style: TextStyle(color: myGold, fontSize: 12),
                    ),
                    showBadge: notificheViewModel.notifichePrenotazioni > 0,  // Mostra solo se notifiche > 0
                    badgeStyle: badges.BadgeStyle(
                      badgeColor: myBordeaux, // Sfondo del badge
                      padding: EdgeInsets.all(6),
                    ),
                    position: badges.BadgePosition.topEnd(top: -3, end: -3), // Posizione sopra l'icona
                    child: Icon(Icons.account_circle_outlined, color: myBordeaux, size: 42),
                  ),
                  icon: badges.Badge(
                    badgeContent: Text(
                      '${notificheViewModel.notifichePrenotazioni}',
                      style: TextStyle(color: myGold, fontSize: 12),
                    ),
                    showBadge: notificheViewModel.notifichePrenotazioni > 0,
                    badgeStyle: badges.BadgeStyle(
                      badgeColor: myBordeaux,
                      padding: EdgeInsets.all(6),
                    ),
                    position: badges.BadgePosition.topEnd(top: -3, end: -3),
                    child: Icon(Icons.account_circle_outlined, color: myWhite, size: 42),
                  ),
                  label: '',
                ),
                NavigationDestination(
                  selectedIcon: Icon(Icons.shopping_cart, color: myBordeaux, size: 42),
                  icon: Icon(Icons.shopping_cart_outlined, color: myWhite, size: 42),
                  label: '',
                ),
              ],
              backgroundColor: myGrey,
              indicatorColor: Colors.transparent,
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: IndexedStack(
            index: _selectedIndex,
            children: const <Widget>[
              /// First Route
              HomeNavigator(),

              /// Second Route
              AccountNavigator(),

              /// Thhird route
              ShopNavigator()
            ],
          ),
        ),
      ),
    );
  }
}