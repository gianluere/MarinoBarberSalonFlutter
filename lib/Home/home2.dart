import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:marino_barber_salon_flutter/user_view_model.dart';


import '../Navigations/home_navigations.dart';
import '../app_bar.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context);

    return Scaffold(
      appBar: MyAppBar("Home", false),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushNamed('/seleziona_servizio');
          },
          child: Text('Vai a Seleziona Servizio e ${userViewModel.currentUser!.email}'),
        ),
      ),
    );
  }
}
