import 'package:flutter/material.dart';
import 'package:marino_barber_salon_flutter/app_bar.dart';
import 'package:marino_barber_salon_flutter/my_colors.dart';
import 'package:provider/provider.dart';

import '../user_view_model.dart'; // Importa il tuo ViewModel corretto

class DatiPersonali extends StatefulWidget {
  const DatiPersonali({super.key});

  @override
  _DatiPersonaliState createState() => _DatiPersonaliState();
}

class _DatiPersonaliState extends State<DatiPersonali> {
  bool readOnly = true;
  

  late TextEditingController nomeController;
  late TextEditingController cognomeController;
  late TextEditingController emailController;
  late TextEditingController etaController;
  late TextEditingController telefonoController;

  @override
  void initState() {
    super.initState();
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    nomeController = TextEditingController(text: userViewModel.dati?.nome);
    cognomeController = TextEditingController(text: userViewModel.dati?.cognome);
    emailController = TextEditingController(text: userViewModel.dati?.email);
    etaController = TextEditingController(text: userViewModel.dati?.eta.toString());
    telefonoController = TextEditingController(text: userViewModel.dati?.telefono);
  }

  @override
  void dispose() {
    nomeController.dispose();
    cognomeController.dispose();
    emailController.dispose();
    etaController.dispose();
    telefonoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context);
    return Scaffold(
      appBar: MyAppBar('DATI PERSONALI', true),
      backgroundColor: myGrey,
      body: userViewModel.isLoading
        ? Container(
          color: Colors.black.withOpacity(0.5),
          child: Center(child: CircularProgressIndicator(color: myGold)),
        )
        : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(readOnly ? Icons.edit : Icons.check, color: readOnly ? myBordeaux : Colors.green, size: 30),
                    onPressed: () {
                      if (readOnly) {
                        setState(() {
                          readOnly = false;
                        });
                      } else {

                        userViewModel.updateDati(
                            nomeController.text,
                            cognomeController.text,
                            int.tryParse(etaController.text) ?? 0,
                            telefonoController.text
                        );

                        setState(() {
                          readOnly = true;
                        });
                        /*
                      userViewModel.updateDati(
                        nomeController.text,
                        cognomeController.text,
                        int.tryParse(etaController.text) ?? 0,
                        telefonoController.text,
                            () {
                          setState(() {
                            readOnly = true;
                          });
                        },
                      );

                       */
                      }
                    },
                  ),
                ),
                SizedBox(height: 10),
                buildRigaDato("Nome", nomeController, readOnly),
                buildRigaDato("Cognome", cognomeController, readOnly),
                buildRigaDato("Email", emailController, true),
                buildRigaDato("Età", etaController, readOnly),
                buildRigaDato("Telefono", telefonoController, readOnly),
              ],
            ),
          )
      )

    );
  }

  Widget buildRigaDato(String label, TextEditingController controller, bool readOnly) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 24, color: Colors.white)),
        TextField(
          controller: controller,
          readOnly: readOnly,
          style: TextStyle(fontSize: 18, color: Colors.white),
          decoration: InputDecoration(
            border: InputBorder.none,
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 2)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 2)),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
