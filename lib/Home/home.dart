import 'package:flutter/material.dart';
import 'package:marino_barber_salon_flutter/app_bar.dart';
import 'package:provider/provider.dart';
import '../user_view_model.dart';
import 'package:marino_barber_salon_flutter/my_colors.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {

    final userViewModel = Provider.of<UserViewModel>(context);

    return Scaffold(
      appBar: (userViewModel.currentUser != null && !userViewModel.isLoading)
          ? MyAppBar('BENTORNATO ${userViewModel.dati?.nome.toUpperCase()}', false)
          : null,
      body: (userViewModel.currentUser == null || userViewModel.isLoading)
          ? const Center(child: CircularProgressIndicator(color: myGold,))
          : Center(child: SelezionaTipo(userViewModel: userViewModel)),
      backgroundColor: myGrey,
    );

  }

}

class SelezionaTipo extends StatelessWidget {
  final UserViewModel userViewModel;


  const SelezionaTipo({
    Key? key,
    required this.userViewModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => {Navigator.of(context).pushNamed('/seleziona_servizio', arguments: 'barba')},
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                width: 290,
                height: 210,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: myGold, width: 3),
                  image: const DecorationImage(
                    image: AssetImage('assets/barba.jpeg'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.grey,
                      BlendMode.saturation,
                    ),
                  ),
                ),
              ),
              RotatedBox(
                quarterTurns: -1,
                child: Text(
                  'BARBA',
                  style: TextStyle(
                    color: myWhite,
                    fontSize: 40,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Box per la selezione dei capelli
        GestureDetector(
          onTap: () => {Navigator.of(context).pushNamed('/seleziona_servizio', arguments: 'capelli')},
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                width: 290,
                height: 210,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: myGold, width: 3),
                  image: const DecorationImage(
                    image: AssetImage('assets/capelli.jpeg'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.grey,
                      BlendMode.saturation,
                    ),
                  ),
                ),
              ),
              RotatedBox(
                quarterTurns: -1,
                child: Text(
                  'CAPELLI',
                  style: TextStyle(
                    color: myWhite,
                    fontSize: 40,
                  ),
                ),
              ),
            ],
          ),
        ),

      ],
    );
  }
}

