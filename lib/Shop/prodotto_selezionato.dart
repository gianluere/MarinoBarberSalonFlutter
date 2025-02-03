import 'package:flutter/material.dart';
import 'package:marino_barber_salon_flutter/Shop/prodotto.dart';
import 'package:marino_barber_salon_flutter/app_bar.dart';
import 'package:marino_barber_salon_flutter/my_colors.dart';
import 'package:provider/provider.dart';

import 'lista_prodotti_view_model.dart';

class ProdottoShop extends StatefulWidget {
  const ProdottoShop({super.key});


  

  @override
  _ProdottoShopState createState() => _ProdottoShopState();
}

class _ProdottoShopState extends State<ProdottoShop> {
  int counter = 1;
  bool showDialogSuccess = false;
  bool showDialogError = false;


  @override
  Widget build(BuildContext context) {

    final prodotto = ModalRoute.of(context)?.settings.arguments as Prodotto;
    final listaProdottiViewModel = Provider.of<ListaProdottiViewModel>(context);
    
    return Scaffold(
      
      appBar: MyAppBar('SHOP', true),
      backgroundColor: myGrey,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(prodotto.nome, style: TextStyle(fontSize: 24, color: myWhite)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal:25),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 250,
                    maxWidth: 300// Imposta l'altezza massima
                  ),
                  child: Container(
                    //width: double.infinity,
                    //height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: myGold, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        height: 250,
                        width: 300,
                        prodotto.immagine,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(child: CircularProgressIndicator(color: myGold));
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset('assets/placeholder.png', fit: BoxFit.cover);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(prodotto.descrizione, style: TextStyle(fontSize: 18, color: myWhite), maxLines: 3, overflow: TextOverflow.ellipsis,),
            const SizedBox(height: 10),
            prodotto.quantita > 0
                ? Row(
              children: [
                Text("Quantità: $counter", style: TextStyle(fontSize: 24, color: myWhite)),
                const SizedBox(width: 15),
                _buildCounterButton(Icons.remove, () {
                  if (counter > 1) setState(() => counter--);
                }),
                _buildCounterButton(Icons.add, () {
                  if (counter < prodotto.quantita) setState(() => counter++);
                }),
              ],
            )
                : Text("Attualmente non disponibile", style: TextStyle(fontSize: 24, color: myWhite)),
            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: prodotto.quantita > 0
                    ? () {
                  listaProdottiViewModel.prenotaProdotto(
                    prodotto,
                    counter,
                    () => setState(() => showDialogSuccess = true),
                    () => setState(() => showDialogError = true),
                  );
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: myBordeaux,
                  disabledBackgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text("PRENOTA", style: TextStyle(fontSize: 25, color: myGold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterButton(IconData icon, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
            borderRadius: icon == Icons.remove ? BorderRadius.horizontal(left: Radius.circular(20)) : BorderRadius.horizontal(right: Radius.circular(20)),
            side: BorderSide(color: myGold, width: 3)
        ),
        backgroundColor: Colors.white,
      ),
      child: Icon(icon, color: Colors.black),
    );
  }
}

class DialogSuccessoProdotto extends StatelessWidget {
  final VoidCallback onDismiss;

  const DialogSuccessoProdotto({Key? key, required this.onDismiss}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildDialog(
      icon: Icons.check_circle,
      text: "Prodotto prenotato \ncon successo",
      onDismiss: onDismiss,
    );
  }
}

class DialogErroreProdotto extends StatelessWidget {
  final VoidCallback onDismiss;

  const DialogErroreProdotto({Key? key, required this.onDismiss}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildDialog(
      icon: Icons.error,
      text: "Errore, verificare la\ndisponibilità del prodotto",
      onDismiss: onDismiss,
    );
  }
}

Widget _buildDialog({required IconData icon, required String text, required VoidCallback onDismiss}) {
  return Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 80, color: Colors.black),
          const SizedBox(height: 10),
          Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 20)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onDismiss,
            child: Text("OK"),
          ),
        ],
      ),
    ),
  );
}
