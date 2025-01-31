import 'package:flutter/material.dart';
import 'package:marino_barber_salon_flutter/Navigations/home_navigations.dart';
import 'package:marino_barber_salon_flutter/Navigations/shop_navigations.dart';
import 'package:marino_barber_salon_flutter/app_bar.dart';
import 'package:marino_barber_salon_flutter/main.dart';
import 'package:marino_barber_salon_flutter/my_colors.dart';
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



class AccountScreen extends StatelessWidget {

  final int notifichePrenotazioni;
  final int notificheProdotti;

  const AccountScreen({
    super.key,

    this.notifichePrenotazioni = 0,
    this.notificheProdotti = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar('ACCOUNT', false),
      backgroundColor: myGrey,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 55,
            color: myYellow,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 10),
            child: const Text(
              "PANORAMICA",
              style: TextStyle(fontSize: 22, color: myGrey),
            ),
          ),
          Container(
              color: Colors.grey,
              height: 2.0,
          ),
          _buildRow("Dati personali", (){Navigator.of(context).pushNamed('/dati_personali');}),
          Container(
            color: myGold,
            height: 2.0,
          ),
          _buildRow("Prenotazioni", (){Navigator.of(context).pushNamed('/prenotazioni');}, notifichePrenotazioni),
          Container(
            color: myGold,
            height: 2.0,
          ),
          _buildRow("Acquisti in app", ()=>{}, notificheProdotti),
          Container(
            color: myGold,
            height: 2.0,
          ),
          _buildRow("Rilascia feedback", (){print('Feed');}),
          Container(
            color: myGold,
            height: 2.0,
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String text, VoidCallback onTap, [int notifiche = 0]) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        height: 50,
        color: myYellow,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(text, style: const TextStyle(fontSize: 19, color: myGrey)),
                if (notifiche > 0)
                  Container(
                    margin: const EdgeInsets.only(left: 15),
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: myBordeaux,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      notifiche.toString(),
                      style: const TextStyle(color: myGold, fontSize: 13),
                    ),
                  ),
              ],
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.black),
          ],
        ),
      ),
    );
  }

}

