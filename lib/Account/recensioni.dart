import 'package:flutter/material.dart';
import 'package:marino_barber_salon_flutter/Account/recensione.dart';
import 'package:marino_barber_salon_flutter/app_bar.dart';
import 'package:marino_barber_salon_flutter/my_colors.dart';
import 'package:provider/provider.dart';

import 'lista_recensioni_view_model.dart';



class Recensioni extends StatelessWidget {
  const Recensioni({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar('RECENSIONI', true),
      backgroundColor: myGrey,
      body: FutureBuilder(
        future: Provider.of<ListaRecensioniViewModel>(context, listen: false).caricaListaRecensioni(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: myGold));
          }
          if (snapshot.hasError) {
            return Center(child: Text("Errore nel caricamento!", style: TextStyle(color: Colors.red)));
          }

          final listaRecensioniViewModel = Provider.of<ListaRecensioniViewModel>(context);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20, right: 15, bottom: 10),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed('/inserisci_recensione');
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: myYellow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.add, color: Colors.black, size: 20),
                        SizedBox(width: 5),
                        Text(
                          "Inserisci recensione",
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  itemCount: listaRecensioniViewModel.listaRecensioni.length,
                  itemBuilder: (context, index) {
                    return CardRecensione(recensione: listaRecensioniViewModel.listaRecensioni[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}



class CardRecensione extends StatelessWidget {
  final Recensione recensione;

  const CardRecensione({super.key, required this.recensione});

  @override
  Widget build(BuildContext context) {
    int stellePiene = recensione.stelle.floor();
    bool mezzaStella = (recensione.stelle - stellePiene) >= 0.5;
    int stelleVuote = 5 - stellePiene - (mezzaStella ? 1 : 0);

    return Container(
      decoration: BoxDecoration(
        color: myYellow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 10),
            child: Text(
              recensione.nome,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Row(
              children: [
                // Stelle Piene
                for (int i = 0; i < stellePiene; i++)
                  const Icon(Icons.star, color: myGold, size: 20),

                // Mezza Stella
                if (mezzaStella)
                  const Icon(Icons.star_half, color: myGold, size: 20),

                // Stelle Vuote
                for (int i = 0; i < stelleVuote; i++)
                  const Icon(Icons.star_border, color: Colors.black, size: 20),

                // Valutazione numerica
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    recensione.stelle.toString(),
                    style: const TextStyle(fontSize: 20, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: double.infinity,
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17),
                side: const BorderSide(color: myGold, width: 2),
              ),
              color: myYellow,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  recensione.descrizione,
                  style: const TextStyle(fontSize: 17, color: Colors.black),
                ),
              ),
            )
          ),

          Container(
            color: myGold, // Colore della linea
            height: 2.0,   // Spessore della linea
          ),
        ],
      ),
    );


  }
}