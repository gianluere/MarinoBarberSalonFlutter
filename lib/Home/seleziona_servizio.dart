import 'package:flutter/material.dart';
import 'package:marino_barber_salon_flutter/app_bar.dart';
import 'package:marino_barber_salon_flutter/my_colors.dart';
import 'package:provider/provider.dart';

import 'lista_servizi_view_model.dart';

class SelezionaServizioPage extends StatelessWidget {
  const SelezionaServizioPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String tipoServizio = ModalRoute.of(context)?.settings.arguments as String;


    return Scaffold(
      appBar: MyAppBar("Prenota un appuntamento", true),
      body: Center(
        child: tipoServizio == 'capelli'
        ? SelezionaServizioCapelli()
        : SelezionaServizioBarba(),
      ),
      backgroundColor: myGrey,
    );
  }
}


class SelezionaServizioCapelli extends StatelessWidget {



  const SelezionaServizioCapelli({
    super.key
  });

  @override
  Widget build(BuildContext context) {

    final listaServiziViewModel = Provider.of<ListaServiziViewModel>(context);

    return listaServiziViewModel.isLoading
      ? Center(child: CircularProgressIndicator(color: myGold,),)
      : Contenuto(
        servizi: listaServiziViewModel.listaServizi.where((s) => s.tipo == "Capelli").toList(),
        titolo: "Capelli",
      );
  }
}

class SelezionaServizioBarba extends StatelessWidget {

  const SelezionaServizioBarba({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    final listaServiziViewModel = Provider.of<ListaServiziViewModel>(context);

    return Contenuto(
      servizi: listaServiziViewModel.listaServizi.where((s) => s.tipo == "Barba").toList(),
      titolo: "Barba",
    );
  }
}

class Contenuto extends StatelessWidget {
  final List<Servizio> servizi;
  final String titolo;

  const Contenuto({
    Key? key,
    required this.servizi,
    required this.titolo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Text(
            "SEZIONE '$titolo'",
            style: const TextStyle(
              fontSize: 27.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
            itemCount: servizi.length,
            itemBuilder: (context, index) {
              return CardAppuntamento(
                servizio: servizi[index],
              );
            },
          ),
        ),
      ],
    );
  }
}

class CardAppuntamento extends StatelessWidget {
  final Servizio servizio;

  const CardAppuntamento({
    super.key,
    required this.servizio,

  });

  @override
  Widget build(BuildContext context) {
    String iconPath;
    if (servizio.tipo == "Barba") {
      iconPath = "assets/barba_icona.png";
    } else if (servizio.nome?.contains("+") == true) {
      iconPath = "assets/barba_e_capelli_512.png";
    } else {
      iconPath = "assets/capelli_icona.png";
    }

    return GestureDetector(
      onTap: () => {Navigator.of(context).pushNamed("/seleziona_giorno", arguments: servizio)},
      child: Card(
        margin: const EdgeInsets.only(bottom: 23.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(17.0),
        ),
        color: myYellow,
        child: Container(
          height: 130.0,
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            border: Border.all(color: myGold, width: 2.0),
            borderRadius: BorderRadius.circular(17.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      servizio.nome ?? "",
                      style: const TextStyle(
                        fontSize: 17.0,
                        color: Colors.black,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 1,
                    ),
                  ),
                  Image.asset(
                    iconPath,
                    height: 23.0,
                    width: 23.0,
                  ),
                ],
              ),
              const Divider(color: Colors.black, thickness: 1.0),
              Text(
                servizio.descrizione ?? "",
                style: const TextStyle(fontSize: 12.0, color: Colors.black),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Durata: ${servizio.durata ?? 0} minuti",
                    style: const TextStyle(fontSize: 14.0, color: Colors.black),
                  ),
                  Text(
                    "${servizio.prezzo?.toStringAsFixed(2) ?? "0.00"}€",
                    style: const TextStyle(fontSize: 14.0, color: Colors.black),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
