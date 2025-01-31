import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marino_barber_salon_flutter/app_bar.dart';
import 'package:marino_barber_salon_flutter/my_colors.dart';
import 'package:provider/provider.dart';

import '../Home/appuntamento.dart';
import '../user_view_model.dart';

class Prenotazioni extends StatelessWidget {
  const Prenotazioni({super.key});

  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context);
    final listaPrenotazioni = userViewModel.listaAppuntamenti;

    return Scaffold(
      backgroundColor: myGrey,
      appBar: MyAppBar('PRENOTAZIONi', true),
      body: userViewModel.isLoading
        ? Center(child: CircularProgressIndicator(color: myGold,),)
        : listaPrenotazioni!.isNotEmpty
          ? Padding(
            padding: EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: listaPrenotazioni.length,
              itemBuilder: (context, index) {
                final appuntamento = listaPrenotazioni[index];
                return CardPrenotazione(
                  appuntamento: appuntamento,
                  annulla: () {
                    /*
                    userViewModel.annullaPrenotazione(
                      appuntamento,
                      onSuccess: () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Prenotazione annullata!")));
                      },
                      onError: () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Errore di connessione")));
                      },
                    );

                     */


                  },
                );
              },
            ),
          )
          : Center(
                child: Text(
                  "NON CI SONO PRENOTAZIONI",
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
            ),
    );
  }
}


class CardPrenotazione extends StatelessWidget {
  final Appuntamento appuntamento;
  final VoidCallback annulla;

  const CardPrenotazione({required this.appuntamento, required this.annulla});

  @override
  Widget build(BuildContext context) {
    DateTime oggi = DateTime.now();
    DateTime giornoApp = DateFormat("dd-MM-yyyy").parse(appuntamento.data);
    DateTime oraApp = DateFormat("HH:mm").parse(appuntamento.orarioInizio);

    bool attivo = oggi.isBefore(giornoApp) || (oggi.year == giornoApp.year && oggi.month == giornoApp.month && oggi.day == giornoApp.day && oggi.isBefore(oraApp));

    return Card(
      color: attivo ? myYellow : Colors.grey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(17.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: myGold, width: 2.0),
          borderRadius: BorderRadius.circular(17.0),
        ),
        child: ListTile(
          splashColor: myGold,
          title: Text(appuntamento.servizio, style: TextStyle(fontSize: 20)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(appuntamento.descrizione, style: TextStyle(fontSize: 14)),
              SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(appuntamento.data, style: TextStyle(fontSize: 17)),
                  Text("${appuntamento.orarioInizio} - ${appuntamento.orarioFine}", style: TextStyle(fontSize: 17)),
                  Text("${appuntamento.prezzo.toStringAsFixed(2)}€", style: TextStyle(fontSize: 17)),
                ],
              ),
            ],
          ),
          onLongPress: attivo ? () => showAnnullaDialog(context, annulla) : null,
        ),
      ),
    );
  }
}



void showAnnullaDialog(BuildContext context, VoidCallback annulla) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.grey[900],
    builder: (context) => Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Vuoi annullare la tua prenotazione?", style: TextStyle(fontSize: 24, color: myWhite)),
          SizedBox(height: 90),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                    backgroundColor: myBordeaux,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: EdgeInsets.all(14.0)
                ),
                child: Text("ANNULLA", style: TextStyle(fontSize: 22, color: myGold)),
              ),
              ElevatedButton(
                onPressed: () {
                  annulla();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: myBordeaux,
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: EdgeInsets.all(14.0)
                ),
                child: Text("CONFERMA", style: TextStyle(fontSize: 22, color: myGold)),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
