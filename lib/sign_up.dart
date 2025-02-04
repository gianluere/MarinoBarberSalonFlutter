import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:marino_barber_salon_flutter/app_bar.dart';
import 'package:marino_barber_salon_flutter/my_colors.dart';
import 'package:marino_barber_salon_flutter/user_view_model.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {

  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController cognomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController etaController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool passwordVisibility = false;
  //bool isLoading = false;
  

  @override
  Widget build(BuildContext context) {
    
    final userViewModel = Provider.of<UserViewModel>(context);
    
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: MyAppBar('CREA ACCOUNT', true),
        backgroundColor: myGrey,
        body: userViewModel.isLoading
            ? const Center(child: CircularProgressIndicator(color: myGold))
            : Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Inserisci le informazioni di seguito per completare la registrazione",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: myWhite, fontSize: 18),
                ),
                const SizedBox(height: 20),

                // Nome
                _buildTextField(nomeController, "Nome", maxLength: 20),
                const SizedBox(height: 15),

                // Cognome
                _buildTextField(cognomeController, "Cognome", maxLength: 20),
                const SizedBox(height: 15),

                // Email
                _buildTextField(emailController, "Email", keyboardType: TextInputType.emailAddress, maxLength: 50),
                const SizedBox(height: 15),

                // Età
                _buildTextField(etaController, "Età", keyboardType: TextInputType.number, maxLength: 2),
                const SizedBox(height: 15),

                // Telefono
                _buildTextField(telefonoController, "Telefono", keyboardType: TextInputType.phone, maxLength: 10),
                const SizedBox(height: 15),

                // Password
                TextField(
                  controller: passwordController,
                  obscureText: !passwordVisibility,
                  cursorColor: myWhite,
                  style: const TextStyle(color: myGold, fontSize: 17),
                  decoration: InputDecoration(
                    hintText: "Password",
                    hintStyle: const TextStyle(color: myGold, fontSize: 17),
                    enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: myWhite)),
                    focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: myWhite)),
                    suffixIcon: IconButton(
                      icon: Icon(passwordVisibility ? Icons.visibility : Icons.visibility_off, color: myWhite),
                      onPressed: () {
                        setState(() {
                          passwordVisibility = !passwordVisibility;
                        });
                      },
                    ),
                  ),
                ),


                const SizedBox(height: 40),

                // Pulsante di conferma
                ElevatedButton(
                  onPressed: () async{
                    await userViewModel.signup(
                        email: emailController.text,
                        password: passwordController.text,
                        nome: nomeController.text,
                      cognome: cognomeController.text,
                      eta: etaController.text.isEmpty ? 0 : int.parse(etaController.text),
                      telefono: telefonoController.text
                    );

                    if (userViewModel.errorMessage != null){

                      Fluttertoast.showToast(
                        msg: userViewModel.errorMessage ?? 'Errore sconosciuto',  // Testo del messaggio
                        toastLength: Toast.LENGTH_SHORT, // Durata: SHORT o LONG
                        gravity: ToastGravity.BOTTOM, // Posizione: TOP, CENTER, BOTTOM
                        backgroundColor: Colors.black45, // Colore di sfondo
                        textColor: myWhite, // Colore del testo
                        fontSize: 16.0, // Dimensione del testo
                      );

                    }else{
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, '/main');
                    }





                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: myBordeaux,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  child: const Text("CONFERMA", style: TextStyle(color: myGold, fontSize: 18)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText, {TextInputType keyboardType = TextInputType.text, int maxLength = 40}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.next,
      cursorColor: myWhite,
      style: const TextStyle(color: myGold, fontSize: 17),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: myGold, fontSize: 17),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: myWhite)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: myWhite)),
        counterText: "",
      ),
    );
  }


}
