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
                mainAxisSpacing: 15,
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
      onTap: () => {Navigator.of(context).pushNamed('/prodotto_shop', arguments: prodotto)},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 160,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: myGold, width: 2),
                color: prodotto.quantita == 0 ? Colors.grey[800] : Colors.grey,

                /*
                DecorationImage(
                  image: NetworkImage(prodotto.immagine), // L'URL è già in Firestore
                  fit: BoxFit.cover,
                  colorFilter: prodotto.quantita == 0
                      ? const ColorFilter.mode(Colors.grey, BlendMode.saturation) // Scala di grigi se quantità = 0
                      : null,
                ),

                 */
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: 
                  Image.network(
                    prodotto.immagine,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                      return child;
                    }else {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: myGold,
                        ),
                      );
                    }
                  },
                    errorBuilder: (context, exception, stackTrace) {
                      return Image.asset(
                        'assets/placeholder.png',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      );
                    },
                  ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    prodotto.nome,
                    style: const TextStyle(color: myWhite, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 10), // Spazio tra nome e prezzo
                Text(
                  "${prodotto.prezzo.toStringAsFixed(2)}€",
                  style: const TextStyle(color: myWhite, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
