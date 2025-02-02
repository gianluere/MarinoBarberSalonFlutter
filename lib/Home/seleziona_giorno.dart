import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marino_barber_salon_flutter/Home/lista_giorni_view_model.dart';
import 'package:marino_barber_salon_flutter/Home/riepilogo.dart';
import 'package:marino_barber_salon_flutter/app_bar.dart';
import 'package:marino_barber_salon_flutter/my_colors.dart';
import 'package:provider/provider.dart';

import 'lista_servizi_view_model.dart';

class SelezionaGiorno extends StatefulWidget {
  const SelezionaGiorno({super.key});

  @override
  _SelezionaGiornoState createState() => _SelezionaGiornoState();
}

class _SelezionaGiornoState extends State<SelezionaGiorno> {
  int indexGiornoSelezionato = 0;
  int indexOrarioSelezionato = 0;
  //bool bottone = false;
  DateTime dataSelezionata = DateTime.now();
  Map<String, String> orarioInizioFine = {};


  @override
  void initState() {
    super.initState();

    // Inizializza i dati solo una volta
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final servizio = ModalRoute.of(context)?.settings.arguments as Servizio;
      final listaGiorniViewModel = Provider.of<ListaGiorniViewModel>(context, listen: false);

      print(DateTime.now().toString());
      // Chiamata iniziale a initialize
      listaGiorniViewModel.initialize(DateTime.now(), 60, servizio.durata ?? 0);

    });
  }

  @override
  Widget build(BuildContext context) {
    final Servizio servizio = ModalRoute.of(context)?.settings.arguments as Servizio;

    final listaGiorniViewModel = Provider.of<ListaGiorniViewModel>(context);
    var listaGiorni = listaGiorniViewModel.listaGiorniAggiornata;


    return Scaffold(

      appBar: MyAppBar("Scegli un giorno e un orario", true),
      backgroundColor: myGrey,
      body: listaGiorniViewModel.isLoading
      ? Center(child: CircularProgressIndicator(color: myGold,))
      : Column(
        children: [
          // LazyRow equivalente
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
                vertical: 16.0,),
            child: Container(
              decoration: BoxDecoration(color: myYellow),
              child: Row(
                children: List.generate(listaGiorni.length, (index) {
                  final giorno = listaGiorni[index].keys.first;
                  return CardGiorno(
                    giorno: giorno,
                    isSelected: index == indexGiornoSelezionato,
                    index: index,
                    onCardSelected: (selectedIndex) {
                      setState(() {
                        indexGiornoSelezionato = selectedIndex;
                        indexOrarioSelezionato = 0;
                        dataSelezionata = listaGiorni[selectedIndex].keys.first;
                        //bottone = listaGiorni[selectedIndex][giorno]!.isNotEmpty;
                      });
                    },
                  );
                }),
              ),
            )

          ),

          // Lista degli orari disponibili
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: myGold, width: 2.0),
                  borderRadius: BorderRadius.circular(16.0),
                  color: myYellow,
                ),
                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                child: listaGiorni[indexGiornoSelezionato].values.first.isEmpty
                    ? const Center(
                      child: Text(
                        'NESSUN ORARIO DISPONIBILE\nSELEZIONARE UN’ALTRA DATA',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18, color: Colors.black
                        ),
                      ),
                    )
                    : ListView.builder(
                  itemCount: listaGiorni[indexGiornoSelezionato]
                      .values
                      .first
                      .length,
                  itemBuilder: (context, index) {
                    final orario = listaGiorni[
                    indexGiornoSelezionato].values.first[index];

                    if (index == 0){
                      orarioInizioFine = listaGiorni[
                      indexGiornoSelezionato].values.first[indexOrarioSelezionato];
                    }

                    return CardOrario(
                      orario: orario,
                      index : index,
                      isSelected: index == indexOrarioSelezionato,
                      onCardSelected: (selectedIndex) {
                        setState(() {
                          indexOrarioSelezionato = selectedIndex;
                          orarioInizioFine = listaGiorni[
                          indexGiornoSelezionato].values.first[selectedIndex];
                        });
                      },
                    );
                  },
                ),
              ),
            ),
          ),

          // Bottone per procedere
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: listaGiorni[indexGiornoSelezionato].values.first.isNotEmpty
                    ? () {
                  final orarioInizio =
                      orarioInizioFine['inizio'] ?? '';
                  final orarioFine = orarioInizioFine['fine'] ?? '';

                  print("Confermato: $orarioInizio - $orarioFine");
                  print("Giorno sel $dataSelezionata");
                  final DatiRiepilogo dati = DatiRiepilogo(orarioInizio: orarioInizio, orarioFine: orarioFine, servizio: servizio, data: dataSelezionata);

                  Navigator.of(context).pushNamed('/riepilogo', arguments: dati);
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: myBordeaux,
                  disabledBackgroundColor: Color(0xFF708090),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15.0)
                ),
                child: const Text(
                  'PROSEGUI',
                  style: TextStyle(fontSize: 20, color: myGold),
                ),
              ),
            ),
          )
        ],
      ),
        );
  }
}

class CardGiorno extends StatelessWidget {
  final DateTime giorno;
  final bool isSelected;
  final int index;
  final Function(int) onCardSelected;

  const CardGiorno({
    Key? key,
    required this.giorno,
    required this.isSelected,
    required this.index,
    required this.onCardSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final giornoFormatted = DateFormat('d', 'it_IT').format(giorno); // Numero del giorno
    final meseFormatted = DateFormat('MMMM', 'it_IT').format(giorno); // Nome del mese
    final giornoSettimanaFormatted = DateFormat('EEE', 'it_IT').format(giorno); // Giorno della settimana

    return GestureDetector(
      onTap: () => onCardSelected(index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFB4915B) : myGold,
          border: Border.all(
              width: isSelected ? 4.0 : 2.0, color: Colors.black),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              giornoFormatted,
              style: const TextStyle(fontSize: 16,),
            ),
            Text(
              toBeginningOfSentenceCase(meseFormatted).toString(),
              style: const TextStyle(fontSize: 16,),
            ),
            Text(
              giornoSettimanaFormatted.toUpperCase(),
              style: const TextStyle(fontSize: 16,),
            )
          ],
        ),
      ),
    );
  }

}

class CardOrario extends StatelessWidget {
  final Map<String, String> orario;
  final int index;
  final bool isSelected;
  final Function(int) onCardSelected;

  const CardOrario({
    super.key,
    required this.orario,
    required this.index,
    required this.isSelected,
    required this.onCardSelected,
  });

  @override
  Widget build(BuildContext context) {
    final orarioFormatted = "${orario['inizio']} - ${orario['fine']}";

    return GestureDetector(
      onTap: () => onCardSelected(index),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFB4915B) : myGold,
          border: Border.all(
              width: isSelected ? 4.0 : 2.0, color: Colors.black),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Text(
          orarioFormatted,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ),
      ),
    );
  }
}
