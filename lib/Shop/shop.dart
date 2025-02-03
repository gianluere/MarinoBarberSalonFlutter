import 'package:flutter/material.dart';
import 'package:marino_barber_salon_flutter/Shop/lista_prodotti_view_model.dart';
import 'package:marino_barber_salon_flutter/Shop/prodotto.dart';
import 'package:marino_barber_salon_flutter/app_bar.dart';
import 'package:marino_barber_salon_flutter/my_colors.dart';
import 'package:provider/provider.dart';

class Shop extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar("Shop", false),
      body: Center(child: Text('Pagina Shop')),
    );
  }
}


class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  _ShopScreenState createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoria = ModalRoute.of(context)?.settings.arguments as String;
      final listaProdottiViewModel = Provider.of<ListaProdottiViewModel>(context, listen: false);
      listaProdottiViewModel.caricaListaProdotti(categoria);
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: MyAppBar('SHOP', true),
      backgroundColor: myGrey,
      body: Consumer<ListaProdottiViewModel>(
        builder: (context, listaProdottiViewModel, child) {
          return listaProdottiViewModel.isLoading
              ? Center(child: CircularProgressIndicator(color: myGold))
              : Padding(
            padding: const EdgeInsets.all(10.0),
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 0.8,
              ),
              itemCount: listaProdottiViewModel.listaProdotti.length,
              itemBuilder: (context, index) {
                return GridItem(prodotto: listaProdottiViewModel.listaProdotti[index]);
              },
            ),
          );
        },
      ),
    );
  }
}



class GridItem extends StatelessWidget {
  final Prodotto prodotto;

  const GridItem({super.key, required this.prodotto});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: myGold, width: 2),
                color: prodotto.quantita == 0 ? Colors.grey[800] : Colors.grey,
                image: DecorationImage(
                  image: NetworkImage(prodotto.immagine), // L'URL è già in Firestore
                  fit: BoxFit.cover,
                  colorFilter: prodotto.quantita == 0
                      ? const ColorFilter.mode(Colors.grey, BlendMode.saturation) // Scala di grigi se quantità = 0
                      : null,
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            prodotto.nome,
            style: const TextStyle(color: myWhite, fontSize: 18),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            "${prodotto.prezzo.toStringAsFixed(2)}€",
            style: const TextStyle(color: myWhite, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
