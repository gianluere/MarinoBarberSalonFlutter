import 'package:flutter/material.dart';
import 'package:marino_barber_salon_flutter/Home/lista_servizi_view_model.dart';
import 'package:marino_barber_salon_flutter/app_bar.dart';
import 'package:intl/intl.dart';
import 'package:marino_barber_salon_flutter/my_colors.dart';
import 'package:provider/provider.dart';

import '../user_view_model.dart';

//Per passare i dati nella navigazione
class DatiRiepilogo{

  final String orarioInizio;
  final String orarioFine;
  final Servizio servizio;
  final DateTime data;

  DatiRiepilogo(
      {
      required this.orarioInizio,
        required this.orarioFine,
      required this.servizio,
      required this.data
    }
  );

}


class Riepilogo extends StatefulWidget {
  const Riepilogo({super.key});

  
  @override
  _RiepilogoState createState() => _RiepilogoState();
}

class _RiepilogoState extends State<Riepilogo> {
  bool showDialogSuccess = false;
  bool showDialogError = false;

  @override
  Widget build(BuildContext context) {
    final riepilogo = ModalRoute.of(context)?.settings.arguments as DatiRiepilogo;
    final String dataFormatted = DateFormat('dd/MM/yyyy').format(riepilogo.data);
    final userViewModel = Provider.of<UserViewModel>(context);


    return Scaffold(
      appBar: MyAppBar("Riepilogo", true),
      backgroundColor: myGrey,
      body:  userViewModel.isLoading
      ? Center(child: CircularProgressIndicator(color: myGold,))
      : !showDialogError && !showDialogSuccess
          ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Servizio: ${riepilogo.servizio.nome}",
                  style: const TextStyle(
                    fontSize: 20,
                    color: myGold,
                  ),
                ),
                const Divider(thickness: 2, color: myWhite),
                Text(
                  "Durata: ${riepilogo.servizio.durata} minuti",
                  style: const TextStyle(
                    fontSize: 20,
                    color: myGold,
                  ),
                ),
                const Divider(thickness: 2, color: myWhite),
                Text(
                  "Data: $dataFormatted",
                  style: const TextStyle(
                    fontSize: 20,
                    color: myGold,
                  ),
                ),
                const Divider(thickness: 2, color: myWhite),
                Text(
                  "Ora: ${riepilogo.orarioInizio} - ${riepilogo.orarioFine}",
                  style: const TextStyle(
                    fontSize: 20,
                    color: myGold,
                  ),
                ),
                const Divider(thickness: 2, color: myWhite),
                const Spacer(),
                Padding(
                  padding: EdgeInsets.only(bottom: 10.0),
                  child:
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      "Totale: ${NumberFormat('##0.00', 'it_IT').format(riepilogo.servizio.prezzo)}€",
                      style: const TextStyle(
                        fontSize: 20,
                        color: myGold,
                        decoration: TextDecoration.underline,
                        decorationColor: myWhite
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child:
                    ElevatedButton(
                      onPressed: () {

                        userViewModel.aggiungiAppuntamento(
                            servizio: riepilogo.servizio.nome!,
                            orarioInizio: riepilogo.orarioInizio,
                            orarioFine: riepilogo.orarioFine,
                            dataSel: dataFormatted,
                            onSuccess: (){
                              setState(() {
                                showDialogSuccess = true;
                              });
                            },
                            onFailed: () {
                              setState(() {
                                showDialogError = true;
                              });
                            });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: myBordeaux,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                          padding: EdgeInsets.symmetric(vertical: 14.0)
                      ),
                      child: const Text(
                        'PRENOTA',
                        style: TextStyle(
                          fontSize: 20,
                          color: myGold,
                        ),
                      ),
                    ),

                )

              ],
            ),
      )
          : showDialogSuccess
          ? DialogSuccess(
          onDismiss: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
          testo: "Prenotazione effettuata\ncon successo",
          )
          : DialogError(
              onDismiss: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              testo: "Errore, lo slot è già\nstato occupato",
            ),
    );
  }

}

class DialogSuccess extends StatelessWidget {
  final Function onDismiss;
  final String testo;

  const DialogSuccess({required this.onDismiss, required this.testo, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        height: 270,
        width: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 80, color: Colors.green),
            const SizedBox(height: 16),
            Text(
              testo,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () { onDismiss(); },
              style: ElevatedButton.styleFrom(
                backgroundColor: myBordeaux,
              ),
              child: const Text(
                "OK",
                style: TextStyle(color: myWhite),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DialogError extends StatelessWidget {
  final Function onDismiss;
  final String testo;

  const DialogError({required this.onDismiss, required this.testo, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        height: 270,
        width: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              testo,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () { onDismiss(); },
              style: ElevatedButton.styleFrom(
                backgroundColor: myBordeaux,
              ),
              child: const Text(
                "OK",
                style: TextStyle(color: myWhite),
              ),
            ),
          ],
        ),
      ),
    );
  }
}