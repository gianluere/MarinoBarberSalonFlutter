import 'package:flutter/material.dart';
import 'package:marino_barber_salon_flutter/Account/prodotto_prenotato.dart';
import 'package:marino_barber_salon_flutter/app_bar.dart';
import 'package:marino_barber_salon_flutter/my_colors.dart';
import 'package:provider/provider.dart';

import '../Shop/prodotto.dart';
import '../user_view_model.dart';


class ProdottiPrenotati extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: MyAppBar('PRODOTTI PRENOTATI', true),
      backgroundColor: myGrey,
      body: FutureBuilder(
          future: Provider.of<UserViewModel>(context, listen: false).caricaProdottiPrenotati(),
          builder: (context, snapshot){
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: myGold));
            }
            if (snapshot.hasError) {
              return Center(child: Text("Errore nel caricamento!", style: TextStyle(color: Colors.red)));
            }

            final userViewModel = Provider.of<UserViewModel>(context);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Da ritirare in negozio:",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                Expanded(
                  child: userViewModel.listaProdottiPrenotati.isNotEmpty
                      ? ListView.builder(
                    itemCount: userViewModel.listaProdottiPrenotati.length,
                    itemBuilder: (context, index) {
                      return ProdPrenItem(
                        item: userViewModel.listaProdottiPrenotati[index],
                        onDelete: () {
                          //userViewModel.annullaPrenotazioneProdotto(listaProdottiPrenotati[index].prodottoPrenotato);
                        },
                      );
                    },
                  )
                      : Center(
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.amber, width: 3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "NON CI SONO PRODOTTI PRENOTATI",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            );

          }


      ),
    );
      /*
      Consumer<UserViewModel>(
      builder: (context, userViewModel, child) {
        userViewModel.caricaProdottiPrenotati(); // Carica i prodotti

        final listaProdottiPrenotati = userViewModel.listaProdottiPrenotati;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Da ritirare in negozio:",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            Expanded(
              child: listaProdottiPrenotati.isNotEmpty
                  ? ListView.builder(
                itemCount: listaProdottiPrenotati.length,
                itemBuilder: (context, index) {
                  return ProdPrenItem(
                    item: listaProdottiPrenotati[index],
                    onDelete: () {
                      //userViewModel.annullaPrenotazioneProdotto(listaProdottiPrenotati[index].prodottoPrenotato);
                    },
                  );
                },
              )
                  : Center(
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.amber, width: 3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "NON CI SONO PRODOTTI PRENOTATI",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

       */
  }


}



class ProdPrenItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onDelete;

  const ProdPrenItem({required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {

    final ProdottoPrenotato prodottoPrenotato = item['prodottoPrenotato'];
    final Prodotto prodotto = item['prodotto'];
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: myYellow,
          ),
          child: Row(
            children: [
              // Immagine del prodotto
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  height: 100,
                  width: 100,
                  prodotto.immagine,
                  fit: BoxFit.cover,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset('assets/placeholder.png', fit: BoxFit.cover, height: 100,
                      width: 100,);
                  },
                )
              ),
              SizedBox(width: 16),

              // Nome, Quantità, Prezzo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prodotto.nome,
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Quantità: ${prodottoPrenotato.quantita}"),
                        Text("Prezzo: ${(prodotto.prezzo * prodottoPrenotato.quantita.toDouble()).toStringAsFixed(2)}€"),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16),

              // Bottone elimina
              IconButton(
                icon: Icon(Icons.delete, color: myBordeaux, size: 30),
                onPressed: () => _showDeleteDialog(context),
              ),
            ],
          ),
        ),
        Container(color: myGold,height: 2.0,),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Vuoi annullare la prenotazione?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("No"),
          ),
          TextButton(
            onPressed: () {
              onDelete();
              Navigator.pop(context);
            },
            child: Text("Sì"),
          ),
        ],
      ),
    );
  }
}