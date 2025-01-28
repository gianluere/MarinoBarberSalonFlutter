import 'package:flutter/material.dart';
import 'package:marino_barber_salon_flutter/app_bar.dart';

class Shop extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar("Shop", false),
      body: Center(child: Text('Pagina Shop')),
    );
  }
}
