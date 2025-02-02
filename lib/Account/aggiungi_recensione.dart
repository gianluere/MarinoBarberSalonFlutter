import 'package:flutter/material.dart';
import 'package:marino_barber_salon_flutter/Account/recensione.dart';
import 'package:marino_barber_salon_flutter/app_bar.dart';
import 'package:marino_barber_salon_flutter/my_colors.dart';
import 'package:provider/provider.dart';

import '../user_view_model.dart';
import 'lista_recensioni_view_model.dart';

class InserisciRecensione extends StatefulWidget {
  const InserisciRecensione({super.key});

  @override
  State<InserisciRecensione> createState() => _InserisciRecensioneState();
}

class _InserisciRecensioneState extends State<InserisciRecensione> {
  String descrizione = "";
  double rating = 0.0;
  bool showDialogSuccess = false;

  @override
  Widget build(BuildContext context) {
    final listaRecensioniViewModel = Provider.of<ListaRecensioniViewModel>(context);
    final userViewModel = Provider.of<UserViewModel>(context);


    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: MyAppBar('INSERISCI RECENSIONE', true),
        backgroundColor: myGrey,
        body: listaRecensioniViewModel.isLoading
            ? Center(child: CircularProgressIndicator(color: myGold,),)
            : showDialogSuccess
              ? DialogSuccessoRecensione(onDismiss: (){
                  Navigator.of(context).pop();
                }
                )
            : Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              /// La parte scrollabile
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: myYellow,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: myGold, width: 2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Inserisci recensione:",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              maxLength: 280,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: "Descrizione",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              onChanged: (value) =>
                                  setState(() => descrizione = value),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: List.generate(5, (index) {
                                    double starValue = index + 1;
                                    bool isFullStar = rating >= starValue;
                                    bool isHalfStar =
                                        rating >= starValue - 0.5 &&
                                            rating < starValue;
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          rating = rating == starValue - 0.5
                                              ? starValue
                                              : starValue - 0.5;
                                        });
                                      },
                                      child: Icon(
                                        isFullStar
                                            ? Icons.star
                                            : isHalfStar
                                            ? Icons.star_half
                                            : Icons.star_border,
                                        color: isFullStar || isHalfStar
                                            ? myGold
                                            : Colors.black,
                                        size: 30,
                                      ),
                                    );
                                  }),
                                ),
                                Text(
                                  rating.toString(),
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),


              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      listaRecensioniViewModel.inserisciRecensione(
                        recensione: Recensione(
                          nome:
                          "${userViewModel.dati?.nome} ${userViewModel.dati?.cognome}",
                          stelle: rating,
                          descrizione: descrizione,
                        ),
                        onCompleted: () {
                          setState(() => showDialogSuccess = true);
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: myBordeaux,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      "CONFERMA",
                      style: TextStyle(color: myGold, fontSize: 20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      )
    );

  }
}

class DialogSuccessoRecensione extends StatelessWidget {
  final Function onDismiss;

  const DialogSuccessoRecensione({Key? key, required this.onDismiss}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: SizedBox(
        width: 300,
        height: 280,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 80, color: Colors.green),
            const SizedBox(height: 10),
            const Text(
              "Recensione inviata con successo",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {onDismiss();},
              child: const Text("OK"),
            ),
          ],
        ),
      ),
    );
  }
}
