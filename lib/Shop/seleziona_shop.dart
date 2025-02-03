import 'package:flutter/material.dart';
import 'package:marino_barber_salon_flutter/app_bar.dart';
import 'package:marino_barber_salon_flutter/my_colors.dart';

class SelezionaShop extends StatelessWidget {
  const SelezionaShop({super.key});
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar("SHOP", false),
      backgroundColor: myGrey,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Seleziona una categoria:",
              style: TextStyle(
                fontSize: 27,
                color: myWhite,
              ),
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _categoriaBox(
                      imagePath: "assets/capelli_icona.png",
                      label: "CAPELLI",
                      onTap:() => Navigator.of(context).pushNamed('/shop', arguments: 'Capelli'),
                    ),
                    _categoriaBox(
                      imagePath: "assets/barba_icona.png",
                      label: "BARBA",
                      onTap: () => Navigator.of(context).pushNamed('/shop', arguments: 'Barba'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _categoriaBox(
                  imagePath: "assets/viso.png",
                  label: "VISO",
                  onTap: () => Navigator.of(context).pushNamed('/shop', arguments: 'Viso'),
                ),
              ],
            ),
          ],
        ),
      ),
    );

  }

  Widget _categoriaBox({
    required String imagePath,
    required String label,
    required VoidCallback onTap
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 150 ,
            height: 150,
            decoration: BoxDecoration(
              color: myWhite,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: myGold, width: 2), // Usa `my_gold`
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Image.asset(imagePath, fit: BoxFit.contain),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 25,
            color: myWhite,
          ),
        ),
      ],
    );
  }
}
