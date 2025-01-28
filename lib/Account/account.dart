import 'package:flutter/material.dart';
import 'package:marino_barber_salon_flutter/Navigations/home_navigations.dart';
import 'package:marino_barber_salon_flutter/Navigations/shop_navigations.dart';
import 'package:marino_barber_salon_flutter/app_bar.dart';
import 'package:marino_barber_salon_flutter/main.dart';
import 'package:marino_barber_salon_flutter/user_view_model.dart';
import 'package:provider/provider.dart';

import '../Navigations/account_navigations.dart';
import '../login.dart';


class Account extends StatefulWidget {
  const Account({super.key});

  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account>{


  @override
  Widget build(BuildContext context) {

    final userViewModel = Provider.of<UserViewModel>(context);

    return Scaffold(
      appBar: MyAppBar("Account", false),
      body: Center(child:
        ElevatedButton(
        onPressed: () async{
          await userViewModel.logout();


          if (Navigator.of(context) == accountNavigatorKey.currentState) {
            print('Sono nel accountNavigator');
          } else if (Navigator.of(context) == homeNavigatorKey.currentState) {
            print('Sono nel HomeNavigator');
          } else if (Navigator.of(context) == shopNavigatorKey.currentState) {
            print('Sono nel ShopNavigator');
          } else if (Navigator.of(context) == mainNavigatorKey.currentState) {
            print('Sono nel Navigator normale');
          }

          print('Navigatoraaaa: ${Navigator.of(context).toString()}');

          print('Attuale rotta: ${ModalRoute.of(context)?.settings.name}');

          while (homeNavigatorKey.currentState?.canPop() ?? false) {
            homeNavigatorKey.currentState?.pop();
          }
          while (accountNavigatorKey.currentState?.canPop() ?? false) {
            accountNavigatorKey.currentState?.pop();
          }
          while (shopNavigatorKey.currentState?.canPop() ?? false) {
            shopNavigatorKey.currentState?.pop();
          }

          mainNavigatorKey.currentState?.pushNamedAndRemoveUntil(
            '/login', (route) => false, // Rimuove tutte le route precedenti
          );


        },
        child: Text('LOGOUT'),
        )
      )
    );
  }

}
